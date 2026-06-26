#!/bin/bash
# Build a custom pyproj wheel with NSGI transformations and bundled PROJ.
#
# Usage:
#   pyproj/build-wheel.sh <pyproj-image-tag> <pyproj-version> <post-patch> <proj-version> [output-dir] [--time-dependent]
#
# Example:
#   pyproj/build-wheel.sh ghcr.io/geodetischeinfrastructuur/pyproj:3.7.2-post1 3.7.2 1 9.7.1 ../dist
#   pyproj/build-wheel.sh ghcr.io/geodetischeinfrastructuur/pyproj:3.7.2-post1 3.7.2 1 9.7.1 ../dist --time-dependent

set -euo pipefail

if [[ $# -lt 4 ]]; then
    echo "Usage: $0 <pyproj-image-tag> <pyproj-version> <post-patch> <proj-version> [output-dir] [--time-dependent]"
    echo ""
    echo "Arguments:"
    echo "  pyproj-image-tag   Docker image tag to use for wheel building (e.g., ghcr.io/geodetischeinfrastructuur/pyproj:3.7.2-post1)"
    echo "  pyproj-version     PyProj version without post suffix (e.g., 3.7.2)"
    echo "  post-patch         POST_PATCH version number (e.g., 1)"
    echo "  proj-version       PROJ version to bundle and use (e.g., 9.7.1)"
    echo "  output-dir         Output directory for wheel (default: ../dist)"
    echo "  --time-dependent   Build a time-dependent variant (uses proj.time.dependent.transformations.db as proj.db)"
    exit 1
fi

PYPROJ_IMAGE_TAG="$1"
PYPROJ_VERSION="$2"
POST_PATCH="$3"
PROJ_VERSION="$4"
OUTPUT_DIR="${5:-../dist}"
TIME_DEPENDENT="${6:-}"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Calculate absolute path to output directory
if [[ "$OUTPUT_DIR" = /* ]]; then
  ABS_OUTPUT_DIR="$OUTPUT_DIR"
else
  mkdir -p "$SCRIPT_DIR/$OUTPUT_DIR"
  ABS_OUTPUT_DIR="$(cd "$SCRIPT_DIR/$OUTPUT_DIR" && pwd)"
fi

mkdir -p "$ABS_OUTPUT_DIR"

echo "Building pyproj wheel..."
echo "  Image: $PYPROJ_IMAGE_TAG"
echo "  PyProj Version: $PYPROJ_VERSION"
echo "  Post Patch: $POST_PATCH"
echo "  Time Dependent: ${TIME_DEPENDENT:---no}"
echo "  Output: $ABS_OUTPUT_DIR"
echo ""

# Step 1: Build raw wheel
echo "Step 1/2: Building raw pyproj wheel from source..."

# Clean up any previous raw wheels to ensure a fresh build
rm -f "$ABS_OUTPUT_DIR"/pyproj-*.dist-info 2>/dev/null || true
for whl in "$ABS_OUTPUT_DIR"/pyproj-[0-9]*.whl; do
  if [[ -f "$whl" ]] && [[ "$whl" != *".post"* ]] && [[ "$whl" != *"-td"* ]]; then
    echo "Cleaning up previous raw wheel: $(basename "$whl")"
    rm -f "$whl"
  fi
done

docker run --rm \
  -e PROJ_DIR=/usr \
  -e PROJ_VERSION="$PROJ_VERSION" \
  -v "$ABS_OUTPUT_DIR:/dist" \
  "$PYPROJ_IMAGE_TAG" \
  sh -c "uvx pip wheel --no-deps --no-binary pyproj --wheel-dir /dist \"pyproj==$PYPROJ_VERSION\""

# Verify raw wheel was created
echo "Verifying raw wheel was created..."
RAW_WHEELS=$(ls -1 "$ABS_OUTPUT_DIR"/pyproj-[0-9]*.whl 2>/dev/null | grep -v "\.post" | grep -v "\-td" || echo "")
if [[ -z "$RAW_WHEELS" ]]; then
  echo "ERROR: No raw wheel created in Step 1!"
  ls -lh "$ABS_OUTPUT_DIR"/pyproj*.whl 2>/dev/null || echo "No wheels in $ABS_OUTPUT_DIR"
  exit 1
fi
echo "✓ Raw wheel(s) found: $RAW_WHEELS"

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
#   4. When TIME_DEPENDENT is set, uses proj.time.dependent.transformations.db as
#      the primary proj.db in the wheel and adds a "-td" suffix to the wheel filename.
import base64, hashlib, os, re, shutil, subprocess, tempfile, zipfile
from pathlib import Path

# Find the raw wheel (without .post in the filename).
# After Step 1, the raw wheel will be: pyproj-3.7.2-cp312-...whl (no .post suffix)
# We need to exclude any already-patched wheels (which have .post or -td in the name)
all_wheels = list(Path("/dist").glob("pyproj-*.whl"))
raw_wheels = [w for w in all_wheels if ".post" not in w.name and "-td" not in w.name]
print(f"[DEBUG] All wheels found: {[w.name for w in all_wheels]}", flush=True)
print(f"[DEBUG] Raw wheels found: {[w.name for w in raw_wheels]}", flush=True)
if not raw_wheels:
    raise FileNotFoundError(f"No raw pyproj wheel found in /dist. Found: {[w.name for w in all_wheels]}")
wheel = raw_wheels[-1]  # Use the most recent one if multiple exist
data_src = Path("/app/.venv/lib/python3.12/site-packages/pyproj/proj_dir/share/proj")
post_patch = os.environ.get("POST_PATCH", "")
time_dependent = os.environ.get("TIME_DEPENDENT", "")
print(f"[DEBUG] Processing raw wheel: {wheel.name}", flush=True)
print(f"[DEBUG] TIME_DEPENDENT={time_dependent}, POST_PATCH={post_patch}", flush=True)

with tempfile.TemporaryDirectory() as tmp:
    tmp = Path(tmp)
    with zipfile.ZipFile(wheel, "r") as zf:
        zf.extractall(tmp)

    # Copy NSGI proj databases, proj.ini, and nl_nsgi grids into the wheel tree.
    dest = tmp / "pyproj" / "proj_dir" / "share" / "proj"
    dest.mkdir(parents=True, exist_ok=True)
    
    # When building the time-dependent variant, use proj.time.dependent.transformations.db
    # as the primary proj.db; otherwise use the standard proj.db
    if time_dependent:
        src = data_src / 'proj.time.dependent.transformations.db'
        if src.exists():
            shutil.copy2(src, dest / 'proj.db')
        # Also copy the standard proj.db for reference if it exists
        src = data_src / 'proj.db'
        if src.exists():
            shutil.copy2(src, dest / 'proj.standard.db')
    else:
        src = data_src / 'proj.db'
        if src.exists():
            shutil.copy2(src, dest / 'proj.db')
        # Also copy the time-dependent one for reference if it exists
        src = data_src / 'proj.time.dependent.transformations.db'
        if src.exists():
            shutil.copy2(src, dest / 'proj.time.dependent.transformations.db')
    
    # Always copy proj.ini and grids
    for fname in ['proj.ini']:
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

    # Build the filename suffix based on post-patch and time-dependent flags
    filename_suffix = ""
    if post_patch:
        filename_suffix += f".post{post_patch}"
    if time_dependent:
        filename_suffix += ".td"

    # Always update METADATA and dist-info when we have a post_patch version
    if post_patch:
        # PEP 440 version for METADATA and wheel: 3.7.2.post1 (post-release only, no local version)
        # Prerelease status is indicated by GitHub's release.prerelease flag, not in the wheel version
        # The .td suffix appears only in the filename, not in the internal version
        pep440_suffix = f".post{post_patch}"

        # Bump Version: in METADATA.
        metadata = dist_info / "METADATA"
        metadata.write_text(re.sub(
            r'^(Version: )(.+)$',
            lambda m: f"{m.group(1)}{m.group(2)}{pep440_suffix}",
            metadata.read_text(), flags=re.MULTILINE,
        ))
        # Rename dist-info dir to match the new filename version.
        old_ver = dist_info.name.removeprefix("pyproj-").removesuffix(".dist-info")
        dist_info = dist_info.rename(dist_info.parent / f"pyproj-{old_ver}{pep440_suffix}.dist-info")

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

    # Repack the wheel, renaming the file when a version/variant suffix is applied.
    wheel.unlink()
    if filename_suffix:
        parts = wheel.name.split("-")
        if post_patch and time_dependent:
            # Insert .post and .td suffix in version
            # e.g., ["pyproj", "3.7.2", "cp312", "cp312", "linux_x86_64.whl"]
            # We want: ["pyproj", "3.7.2.post1.td", "cp312", "cp312", "linux_x86_64.whl"]
            parts[1] = f"{parts[1]}.post{post_patch}.td"
        elif post_patch:
            parts[1] = f"{parts[1]}.post{post_patch}"
        elif time_dependent:
            parts[1] = f"{parts[1]}.td"
        new_wheel = wheel.parent / "-".join(parts)
    else:
        new_wheel = wheel
    
    print(f"[DEBUG] Repacking wheel as: {new_wheel.name}", flush=True)
    with zipfile.ZipFile(new_wheel, "w", zipfile.ZIP_DEFLATED) as zf:
        for f in sorted(tmp.rglob("*")):
            if f.is_file():
                zf.write(f, f.relative_to(tmp))
    
    # Verify the wheel was created
    if new_wheel.exists():
        print(f"[DEBUG] ✓ Wheel created successfully: {new_wheel.name} ({new_wheel.stat().st_size} bytes)", flush=True)
    else:
        raise FileNotFoundError(f"Failed to create wheel: {new_wheel}")
PYEOF

docker run --rm \
  -e POST_PATCH="$POST_PATCH" \
  -e TIME_DEPENDENT="$TIME_DEPENDENT" \
  -v "$ABS_OUTPUT_DIR:/dist" \
  -v "/tmp/inject_proj_data.py:/inject_proj_data.py:ro" \
  "$PYPROJ_IMAGE_TAG" \
  python3 /inject_proj_data.py || {
  echo "ERROR: Python injection script failed!"
  echo "Wheels in $ABS_OUTPUT_DIR:"
  ls -lh "$ABS_OUTPUT_DIR"/pyproj*.whl 2>/dev/null || echo "No wheels found"
  exit 1
}

echo ""
echo "✓ Patching complete!"

# Verify the final wheel was created
EXPECTED_SUFFIX=""
[[ -n "$POST_PATCH" ]] && EXPECTED_SUFFIX=".post${POST_PATCH}"
[[ -n "$TIME_DEPENDENT" ]] && EXPECTED_SUFFIX="${EXPECTED_SUFFIX}-td"

if [[ -n "$EXPECTED_SUFFIX" ]]; then
  # Count wheels with the expected suffix
  CREATED_WHEELS=$(ls -1 "$ABS_OUTPUT_DIR"/pyproj*${EXPECTED_SUFFIX}* 2>/dev/null | wc -l)
  if [[ "$CREATED_WHEELS" -eq 0 ]]; then
    echo "ERROR: No wheel with suffix '$EXPECTED_SUFFIX' was created!"
    echo "Wheels in $ABS_OUTPUT_DIR:"
    ls -lh "$ABS_OUTPUT_DIR"/pyproj*.whl 2>/dev/null || echo "No wheels found"
    exit 1
  fi
fi

echo ""
echo "✓ Wheel build complete!"
echo "Final wheels in $ABS_OUTPUT_DIR:"
ls -lh "$ABS_OUTPUT_DIR"/pyproj*.whl
