#!/bin/bash
# Build a custom pyproj wheel with NSGI transformations and bundled PROJ.
#
# Usage:
#   [TRANSFORMATIONS_PRERELEASE_SUFFIX=-rcN] [TRANSFORMATIONS_BUILD_SUFFIX=-buildN] \
#     pyproj/build-wheel.sh <pyproj-image-tag> <pyproj-version> <transformations-version> <proj-version> [output-dir]
#
# Example:
#   pyproj/build-wheel.sh ghcr.io/geodetischeinfrastructuur/pyproj:3.7.2-nsgi2.0.0 3.7.2 2.0.0 9.7.1 ../dist
#   TRANSFORMATIONS_BUILD_SUFFIX=-build1 pyproj/build-wheel.sh ghcr.io/geodetischeinfrastructuur/pyproj:3.7.2-nsgi2.0.0-build1 3.7.2 2.0.0 9.7.1 ../dist

set -euo pipefail

if [[ $# -lt 4 ]]; then
    echo "Usage: $0 <pyproj-image-tag> <pyproj-version> <transformations-version> <proj-version> [output-dir]"
    echo ""
    echo "Arguments:"
    echo "  pyproj-image-tag        Docker image tag to use for wheel building (e.g., ghcr.io/geodetischeinfrastructuur/pyproj:3.7.2-nsgi2.0.0)"
    echo "  pyproj-version          PyProj version without local-version suffix (e.g., 3.7.2)"
    echo "  transformations-version NSGI transformations semver, becomes the +nsgi local version (e.g., 2.0.0)"
    echo "  proj-version            PROJ version to bundle and use (e.g., 9.7.1)"
    echo "  output-dir              Output directory for wheel (default: ../dist)"
    echo ""
    echo "Environment:"
    echo "  TRANSFORMATIONS_PRERELEASE_SUFFIX  Optional RC suffix, e.g. -rc1 (wheel version gets rc1)"
    echo "  TRANSFORMATIONS_BUILD_SUFFIX       Optional build suffix, e.g. -build1 (wheel version gets .build1)"
    exit 1
fi

PYPROJ_IMAGE_TAG="$1"
PYPROJ_VERSION="$2"
TRANSFORMATIONS_VERSION="$3"
PROJ_VERSION="$4"
OUTPUT_DIR="${5:-../dist}"
TRANSFORMATIONS_PRERELEASE_SUFFIX="${TRANSFORMATIONS_PRERELEASE_SUFFIX:-}"
TRANSFORMATIONS_BUILD_SUFFIX="${TRANSFORMATIONS_BUILD_SUFFIX:-}"
WHEEL_PRERELEASE_SUFFIX="${TRANSFORMATIONS_PRERELEASE_SUFFIX#-}"
# -build1 -> .build1 (PEP 440 local version segments are dot-separated)
BUILD_SUFFIX=""
[[ -n "$TRANSFORMATIONS_BUILD_SUFFIX" ]] && BUILD_SUFFIX=".${TRANSFORMATIONS_BUILD_SUFFIX#-}"
WHEEL_VERSION_SUFFIX="+nsgi${TRANSFORMATIONS_VERSION}${WHEEL_PRERELEASE_SUFFIX}${BUILD_SUFFIX}"

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
echo "  Transformations Version: $TRANSFORMATIONS_VERSION"
echo "  Prerelease Suffix: ${TRANSFORMATIONS_PRERELEASE_SUFFIX:-none}"
echo "  Build Suffix: ${BUILD_SUFFIX:-none}"
echo "  Output: $ABS_OUTPUT_DIR"
echo ""

# Step 1: Build raw wheel
echo "Step 1/2: Building raw pyproj wheel from source..."

# Remove previous wheels so the repair step below sees only this build
rm -f "$ABS_OUTPUT_DIR"/pyproj-*.whl 2>/dev/null || true

docker run --rm \
  -e PROJ_DIR=/usr/local \
  -e PROJ_VERSION="$PROJ_VERSION" \
  -v "$ABS_OUTPUT_DIR:/dist" \
  "$PYPROJ_IMAGE_TAG" \
  sh -c "uvx pip wheel --no-deps --no-binary pyproj --wheel-dir /dist \"pyproj==$PYPROJ_VERSION\""

# Verify raw wheel was created
echo "Verifying raw wheel was created..."
RAW_WHEELS=""
for whl in "$ABS_OUTPUT_DIR"/pyproj-[0-9]*.whl; do
  [[ -f "$whl" ]] || continue
  [[ "$whl" == *"+nsgi"* ]] && continue
  RAW_WHEELS+="$whl"$'\n'
done
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
#   1. Leaves bundling to auditwheel repair, which runs after this script.
#   2. Injects both NSGI data directories: the default database at
#      pyproj/proj_dir/share/proj/ and the time-dependent database at
#      pyproj/proj_dir/share/proj_time_dependent/.
#   3. When TRANSFORMATIONS_VERSION is set, applies a PEP 440 local-version label
#      (e.g. 3.7.2 -> 3.7.2+nsgi2.0.0, or 3.7.2+nsgi2.0.0rc1 for an RC) to
#      METADATA, the dist-info directory name,
#      and the wheel filename, recording the NSGI transformations semver while
#      keeping the upstream 3.7.2 public version (so `pyproj==3.7.2` pins still
#      match). The `rcN` label distinguishes prerelease wheels from final wheels.
import base64, hashlib, os, re, shutil, tempfile, zipfile
from pathlib import Path

# Find the raw wheel (without a +nsgi local version in the filename).
# After Step 1, the raw wheel will be: pyproj-3.7.2-cp312-...whl (no +nsgi suffix)
# Exclude any already-patched wheels, which have a +nsgi local version.
all_wheels = list(Path("/dist").glob("pyproj-*.whl"))
raw_wheels = [w for w in all_wheels if "+nsgi" not in w.name]
print(f"[DEBUG] All wheels found: {[w.name for w in all_wheels]}", flush=True)
print(f"[DEBUG] Raw wheels found: {[w.name for w in raw_wheels]}", flush=True)
if not raw_wheels:
    raise FileNotFoundError(f"No raw pyproj wheel found in /dist. Found: {[w.name for w in all_wheels]}")
wheel = raw_wheels[-1]  # Use the most recent one if multiple exist
# Auto-detect the interpreter's site-packages so this works for any CPython
# version (python3.12/3.13/3.14/3.15) without hardcoding a minor version.
venv_lib = Path("/app/.venv/lib")
py_dirs = sorted(venv_lib.glob("python3.*"))
if not py_dirs:
    raise FileNotFoundError(f"No python3.* lib dir found under {venv_lib}")
data_src = py_dirs[0] / "site-packages/pyproj/proj_dir/share/proj"
transformations_version = os.environ.get("TRANSFORMATIONS_VERSION", "")
prerelease_suffix = os.environ.get("TRANSFORMATIONS_PRERELEASE_SUFFIX", "").removeprefix("-")
build_suffix = os.environ.get("BUILD_SUFFIX", "")
print(f"[DEBUG] Processing raw wheel: {wheel.name}", flush=True)
print(f"[DEBUG] TRANSFORMATIONS_VERSION={transformations_version}, PRERELEASE_SUFFIX={prerelease_suffix}, BUILD_SUFFIX={build_suffix}", flush=True)

with tempfile.TemporaryDirectory() as tmp:
    tmp = Path(tmp)
    with zipfile.ZipFile(wheel, "r") as zf:
        zf.extractall(tmp)

    # Keep the regular database at pyproj's default data directory.
    dest = tmp / "pyproj" / "proj_dir" / "share" / "proj"
    dest.mkdir(parents=True, exist_ok=True)
    standard_db = data_src / "proj.db"
    time_dependent_db = data_src / "proj.time.dependent.transformations.db"
    if not standard_db.is_file():
      raise FileNotFoundError(f"Standard PROJ database not found: {standard_db}")
    if not time_dependent_db.is_file():
      raise FileNotFoundError(f"Time-dependent PROJ database not found: {time_dependent_db}")

    for fname in ("proj.db", "proj.time.dependent.transformations.db", "proj.ini"):
      src = data_src / fname
      if src.is_file():
        shutil.copy2(src, dest / fname)
    for grid in data_src.glob("nl_nsgi_*"):
      shutil.copy2(grid, dest / grid.name)

    # Clone all grids/configuration and make the TD database the active proj.db.
    td_dest = dest.with_name(f"{dest.name}_time_dependent")
    shutil.copytree(dest, td_dest)
    shutil.copy2(time_dependent_db, td_dest / "proj.db")

    


    dist_info = next(tmp.glob("pyproj-*.dist-info"))

    # Append the NSGI version to the upstream version in wheel metadata and filename.
    filename_suffix = ""
    if transformations_version:
        filename_suffix += f"+nsgi{transformations_version}{prerelease_suffix}"
    # Optionally append build suffix (e.g., .build1) after NSGI version
    if build_suffix:
        filename_suffix += build_suffix

    # Always update METADATA and dist-info when we have a transformations version
    if transformations_version:
        # PEP 440 local version for METADATA and wheel: 3.7.2+nsgi2.0.0[rcN][.buildN].
        # Keep the upstream public version and encode NSGI build identity locally.
        pep440_suffix = f"+nsgi{transformations_version}{prerelease_suffix}"
        # Optionally append build suffix after the NSGI version
        if build_suffix:
            pep440_suffix += build_suffix

        # Append the local version to Version: in METADATA.
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

    # Repack the wheel with the local-version suffix.
    wheel.unlink()
    if filename_suffix:
        parts = wheel.name.split("-")
        # Format: pyproj-{version}-{python}-{abi}-{platform}.whl
        # Original parts: ["pyproj", "3.7.2", "cp312", "cp312", "linux_x86_64.whl"]
        # With +nsgi2.0.0: ["pyproj", "3.7.2+nsgi2.0.0", "cp312", "cp312", "linux_x86_64.whl"]
        
        if filename_suffix:
            parts[1] = f"{parts[1]}{filename_suffix}"
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
  -e TRANSFORMATIONS_VERSION="$TRANSFORMATIONS_VERSION" \
  -e TRANSFORMATIONS_PRERELEASE_SUFFIX="$TRANSFORMATIONS_PRERELEASE_SUFFIX" \
  -e BUILD_SUFFIX="$BUILD_SUFFIX" \
  -v "$ABS_OUTPUT_DIR:/dist" \
  -v "/tmp/inject_proj_data.py:/inject_proj_data.py:ro" \
  "$PYPROJ_IMAGE_TAG" \
  sh -ec '
    # Inject NSGI data and update the package version.
    python3 /inject_proj_data.py

    # Bundle PROJ and its non-manylinux-policy dependencies, including TIFF.
    uvx --from auditwheel auditwheel repair \
      --plat manylinux_2_28_x86_64 \
      --wheel-dir /dist/repaired \
      /dist/pyproj-*+nsgi*.whl

    # Publish only the repaired wheel.
    rm -f /dist/pyproj-*+nsgi*.whl
    mv /dist/repaired/*.whl /dist/
    rmdir /dist/repaired
  ' || {
  echo "ERROR: Wheel injection or auditwheel repair failed!"
  echo "Wheels in $ABS_OUTPUT_DIR:"
  ls -lh "$ABS_OUTPUT_DIR"/pyproj*.whl 2>/dev/null || echo "No wheels found"
  exit 1
}

echo ""
echo "✓ Patching complete!"

# Verify the single combined wheel was created.
CREATED_WHEELS=0
for whl in "$ABS_OUTPUT_DIR"/pyproj*"${WHEEL_VERSION_SUFFIX}"-cp*.whl; do
  [[ -f "$whl" ]] || continue
  CREATED_WHEELS=$((CREATED_WHEELS + 1))
done
if [[ "$CREATED_WHEELS" -ne 1 ]]; then
  echo "ERROR: Expected exactly one combined wheel with version suffix '${WHEEL_VERSION_SUFFIX}', found $CREATED_WHEELS"
  echo "Wheels in $ABS_OUTPUT_DIR:"
  ls -lh "$ABS_OUTPUT_DIR"/pyproj*.whl 2>/dev/null || echo "No wheels found"
  exit 1
fi

echo ""
echo "✓ Wheel build complete!"
echo "Final wheels in $ABS_OUTPUT_DIR:"
ls -lh "$ABS_OUTPUT_DIR"/pyproj*.whl
