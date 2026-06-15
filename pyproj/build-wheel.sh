#!/bin/bash
# Build a custom pyproj wheel with NSGI transformations and bundled PROJ.
#
# Usage:
#   pyproj/build-wheel.sh <pyproj-image-tag> <pyproj-version> <post-patch> <proj-version> [output-dir]
#
# Example:
#   pyproj/build-wheel.sh ghcr.io/geodetischeinfrastructuur/pyproj:3.7.2-post1 3.7.2 1 9.7.1 ../dist

set -euo pipefail

if [[ $# -lt 4 ]]; then
    echo "Usage: $0 <pyproj-image-tag> <pyproj-version> <post-patch> <proj-version> [output-dir]"
    echo ""
    echo "Arguments:"
    echo "  pyproj-image-tag   Docker image tag to use for wheel building (e.g., ghcr.io/geodetischeinfrastructuur/pyproj:3.7.2-post1)"
    echo "  pyproj-version     PyProj version without post suffix (e.g., 3.7.2)"
    echo "  post-patch         POST_PATCH version number (e.g., 1)"
    echo "  proj-version       PROJ version to bundle and use (e.g., 9.7.1)"
    echo "  output-dir         Output directory for wheel (default: ../dist)"
    exit 1
fi

PYPROJ_IMAGE_TAG="$1"
PYPROJ_VERSION="$2"
POST_PATCH="$3"
PROJ_VERSION="$4"
OUTPUT_DIR="${5:-../dist}"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Calculate absolute path to output directory
if [[ "$OUTPUT_DIR" = /* ]]; then
  ABS_OUTPUT_DIR="$OUTPUT_DIR"
else
  ABS_OUTPUT_DIR="$(cd "$SCRIPT_DIR" && cd "$OUTPUT_DIR" 2>/dev/null && pwd || mkdir -p "$SCRIPT_DIR/$OUTPUT_DIR" && cd "$SCRIPT_DIR/$OUTPUT_DIR" && pwd)"
fi

mkdir -p "$ABS_OUTPUT_DIR"

echo "Building pyproj wheel..."
echo "  Image: $PYPROJ_IMAGE_TAG"
echo "  PyProj Version: $PYPROJ_VERSION"
echo "  Post Patch: $POST_PATCH"
echo "  Output: $ABS_OUTPUT_DIR"
echo ""

# Step 1: Build raw wheel
echo "Step 1/2: Building raw pyproj wheel from source..."
docker run --rm \
  -e PROJ_DIR=/usr \
  -e PROJ_VERSION="$PROJ_VERSION" \
  -v "$ABS_OUTPUT_DIR:/dist" \
  "$PYPROJ_IMAGE_TAG" \
  sh -c "uvx pip wheel --no-deps --no-binary pyproj --wheel-dir /dist \"pyproj==$PYPROJ_VERSION\""

# Step 2: Patch wheel (inject NSGI data, bundle libproj, version bump)
echo "Step 2/2: Patching wheel with NSGI data and PROJ bundling..."

cat > /tmp/inject_proj_data.py << 'PYEOF'
# Patches a pyproj wheel built from PyPI source with three changes:
#   1. Bundles libproj.so.25 (PROJ 9.7.1) into pyproj.libs/ and patches the RPATH
#      of all extension .so files so the correct PROJ version is loaded at runtime,
#      regardless of what libproj is installed on the host.
#   2. Injects the NSGI custom PROJ data (proj.db, proj.ini, nl_nsgi grids) into
#      pyproj/proj_dir/share/proj/ inside the wheel, so the wheel is
#      self-contained — no separate data-directory setup required after install.
#   3. When POST_PATCH is set, applies a PEP 440 post-release version bump
#      (e.g. 3.7.2 -> 3.7.2.post1) to METADATA, the dist-info directory name,
#      and the wheel filename, signalling that the NSGI data has been customised.
#      Prerelease status is indicated by GitHub's release.prerelease flag, not
#      in the wheel version itself. This keeps wheel filenames simple and valid.
import base64, hashlib, os, re, shutil, subprocess, tempfile, zipfile
from pathlib import Path

wheel = next(Path("/dist").glob("pyproj-*.whl"))
data_src = Path("/app/.venv/lib/python3.12/site-packages/pyproj/proj_dir/share/proj")
post_patch = os.environ.get("POST_PATCH", "")

with tempfile.TemporaryDirectory() as tmp:
    tmp = Path(tmp)
    with zipfile.ZipFile(wheel, "r") as zf:
        zf.extractall(tmp)

    # Copy NSGI proj databases, proj.ini, and nl_nsgi grids into the wheel tree.
    dest = tmp / "pyproj" / "proj_dir" / "share" / "proj"
    dest.mkdir(parents=True, exist_ok=True)
    for fname in ['proj.db', 'proj.time.dependent.transformations.db', 'proj.ini']:
        src = data_src / fname
        if src.exists():
            shutil.copy2(src, dest / fname)
    for grid in data_src.glob('nl_nsgi_*'):
        shutil.copy2(grid, dest / grid.name)

    # Bundle libproj.so.25 (PROJ 9.7.1) so the extension loads the correct version
    # at runtime regardless of what libproj is installed on the host system.
    # Patch RPATH of every extension .so to look in pyproj.libs/ before system paths.
    libs_dir = tmp / "pyproj.libs"
    libs_dir.mkdir(exist_ok=True)
    libproj = Path("/usr/lib/x86_64-linux-gnu/libproj.so.25")
    if libproj.exists():
        shutil.copy2(libproj, libs_dir / "libproj.so.25")
        for so in sorted((tmp / "pyproj").glob("*.so")):
            subprocess.check_call(["patchelf", "--add-rpath", "$ORIGIN/../pyproj.libs", str(so)])

    dist_info = next(tmp.glob("pyproj-*.dist-info"))

    if post_patch:
        # PEP 440 version for METADATA and wheel: 3.7.2.post1 (post-release only, no local version)
        # Prerelease status is indicated by GitHub's release.prerelease flag, not in the wheel version
        pep440_suffix = f".post{post_patch}"
        filename_suffix = f".post{post_patch}"

        # Bump Version: in METADATA.
        metadata = dist_info / "METADATA"
        metadata.write_text(re.sub(
            r'^(Version: )(.+)$',
            lambda m: f"{m.group(1)}{m.group(2)}{pep440_suffix}",
            metadata.read_text(), flags=re.MULTILINE,
        ))
        # Rename dist-info dir to match the new filename version.
        old_ver = dist_info.name.removeprefix("pyproj-").removesuffix(".dist-info")
        dist_info = dist_info.rename(dist_info.parent / f"pyproj-{old_ver}{filename_suffix}.dist-info")

    # Recompute RECORD — sha256 hash and byte size for every file in the wheel.
    # RECORD itself is listed last with empty hash/size fields per the wheel spec.
    record = dist_info / "RECORD"
    def digest(p):
        h = hashlib.sha256(p.read_bytes()).digest()
        return base64.urlsafe_b64encode(h).rstrip(b"=").decode()
    rows = [
        f"{f.relative_to(tmp)},sha256={digest(f)},{f.stat().st_size}"
        for f in sorted(tmp.rglob("*")) if f.is_file() and f != record
    ]
    rows.append(f"{record.relative_to(tmp)},,")
    record.write_text("\n".join(rows) + "\n")

    # Repack the wheel, renaming the file when a version suffix is applied.
    wheel.unlink()
    if post_patch:
        parts = wheel.name.split("-")
        parts[1] = f"{parts[1]}{filename_suffix}"
        new_wheel = wheel.parent / "-".join(parts)
    else:
        new_wheel = wheel
    with zipfile.ZipFile(new_wheel, "w", zipfile.ZIP_DEFLATED) as zf:
        for f in sorted(tmp.rglob("*")):
            if f.is_file():
                zf.write(f, f.relative_to(tmp))
PYEOF

docker run --rm \
  -e POST_PATCH="$POST_PATCH" \
  -v "$ABS_OUTPUT_DIR:/dist" \
  -v "/tmp/inject_proj_data.py:/inject_proj_data.py:ro" \
  "$PYPROJ_IMAGE_TAG" \
  python3 /inject_proj_data.py

echo ""
echo "✓ Wheel build complete!"
ls -lh "$ABS_OUTPUT_DIR"/pyproj*.whl
