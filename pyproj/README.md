# pyproj: Building and Troubleshooting

This directory contains the Docker configuration and build scripts for the `pyproj` wheel and Docker image. Both are built from the same Python dependencies and PROJ 9.7.1 foundation.

## High-Level Build Process

### Docker Image Build (`docker build . -f pyproj/Dockerfile`)

The Docker image (`ghcr.io/geodetischeinfrastructuur/pyproj:3.7.2-post1`) packages pyproj with NSGI customizations into a ready-to-use container:

1. **Base Stages (multi-stage build):**
   - `proj-source` — Extracts PROJ 9.7.1 libraries, headers, and nl_nsgi grids from `osgeo/proj:9.7.1`
   - `transformations` — Pulls the base transformations image containing NSGI proj.db
   - `uv-source` — Extracts the `uv` package manager binary

2. **Final Stage (Ubuntu 24.04):**
   - Install Python 3.12, build tools (gcc, patchelf), and runtime dependencies (`libsqlite3`, `libtiff6`, `libcurl3t64-gnutls`)
   - Copy PROJ 9.7.1 libraries and headers from `proj-source`
   - Run `uv sync --no-binary-package pyproj` to compile pyproj from source against PROJ 9.7.1
   - Copy NSGI proj databases and grids into pyproj's internal data directory
   - Set `PATH` to expose the venv's binaries

**Result:** A Docker image with pyproj installed and ready to use. The venv is at `/app/.venv`.

### Wheel Build (via Docker container)

The wheel (`pyproj-3.7.2.post1-cp312-cp312-linux_x86_64.whl`) is built inside the Docker image and then patched:

1. **Wheel compilation:**
   - Run `uvx pip wheel --no-deps --no-binary pyproj` inside the pyproj Docker image
   - Outputs a raw `.whl` file with pyproj C extensions compiled against PROJ 9.7.1

2. **Wheel patching (post-processing):**
   - Extract the wheel ZIP archive
   - **Bundle libproj.so.25:** Copy the PROJ 9.7.1 library into `pyproj.libs/` inside the wheel
   - **Patch RPATH:** Use `patchelf` to update all compiled `.so` files to search `pyproj.libs/` first, ensuring they load the bundled PROJ 9.7.1 at runtime
   - **Inject NSGI data:** Copy NSGI proj databases (`proj.db`, `proj.time.dependent.transformations.db`) and grids into `pyproj/proj_dir/share/proj/` inside the wheel
   - **PEP 440 versioning:** If `POST_PATCH` is set, bump the version from `3.7.2` to `3.7.2.post1` in METADATA and the wheel filename
   - **Recalculate RECORD:** Update SHA256 hashes for all files to match the wheel spec

**Result:** A self-contained wheel that bundles pyproj, PROJ 9.7.1, NSGI databases, and grids. No system libproj or environment variables needed after install.

### Key Dependency: libcurl Matching

Both builds must use `libcurl3t64-gnutls` in the Dockerfile. This matches what `osgeo/proj:9.7.1` was built against. If you change the libcurl variant, the prebuilt PROJ binary's soname requirement won't match, causing runtime errors.

**Verify PROJ's libcurl dependency:**
```bash
docker run --rm osgeo/proj:9.7.1 ldd /usr/lib/x86_64-linux-gnu/libproj.so.25 | grep curl
# Output: libcurl-gnutls.so.4 => /lib/x86_64-linux-gnu/libcurl-gnutls.so.4
```

## Troubleshooting

### libcurl runtime dependency mismatch

If the built wheel fails with `ImportError: libcurl-gnutls.so.4: cannot open shared object file: No such file or directory`, the build environment's libcurl version doesn't match what PROJ was compiled against.

**Cause:** `osgeo/proj:${PROJ_VERSION}` is built on Ubuntu 24.04 with `libcurl-gnutls.so.4`. If you changed the Dockerfile to use a different libcurl variant (e.g., `libcurl4`), the prebuilt PROJ binary still links against the original soname.

**Fix:** Verify which libcurl soname PROJ requires:

```bash
docker run --rm osgeo/proj:9.7.1 ldd /usr/lib/x86_64-linux-gnu/libproj.so.25 | grep curl
```

Then install the **exact matching variant** in [Dockerfile](Dockerfile). Do not change the libcurl variant—match what the prebuilt PROJ binary expects.

### Version mismatch between Dockerfiles

If the pyproj image build fails with version mismatches, ensure `PROJ_VERSION` and `POST_PATCH` in the root [../Dockerfile](../Dockerfile) match what's passed to [Dockerfile](Dockerfile). Run the build commands from the repository root, not from subdirectories.

### RPATH patch failures

If `patchelf` fails during wheel patching with "ELF file not found", the pyproj wheel may not have compiled successfully. Check the Docker build output for compilation errors. Ensure `uv sync` completed without errors and that all `.so` files were created in the pyproj package directory.

## Building Locally

See the main [../README.md](../README.md#building-images-locally) for build commands. For quick iteration:

```bash
# Build Docker image
docker build . -f pyproj/Dockerfile \
  --pull=false \
  --build-arg TRANSFORMATION_IMAGE_SOURCE= \
  --build-arg PROJ_VERSION=9.7.1 \
  --build-arg POST_PATCH=1 \
  -t pyproj-local

# Test inside container
docker run --rm pyproj-local python -c "from pyproj import Transformer; print(Transformer.from_crs('EPSG:4258', 'EPSG:28992', always_xy=True).transform(5.387639, 52.156161))"
```

### Building the wheel locally

To build the wheel locally, use the `build-wheel.sh` script from the repository root:

```bash
# Extract versions from Dockerfiles
PYPROJ_VERSION=$(grep -E '^ARG PYPROJ_VERSION=' pyproj/Dockerfile | head -1 | cut -d= -f2)
POST_PATCH=$(grep -E '^ARG POST_PATCH=' Dockerfile | head -1 | cut -d= -f2)
PROJ_VERSION=$(grep -E '^ARG PROJ_VERSION=' Dockerfile | head -1 | cut -d= -f2)

# Build wheel using the local pyproj Docker image
chmod +x pyproj/build-wheel.sh
pyproj/build-wheel.sh pyproj-local "$PYPROJ_VERSION" "$POST_PATCH" "$PROJ_VERSION" ../dist

# Wheel is now in ./dist/
ls -lh dist/pyproj*.whl
```

**Note:** The `build-wheel.sh` script requires:
- Docker (with the pyproj image already built or accessible)
- `patchelf` available inside the Docker container (it is in the pyproj image)
- Write access to the output directory

For development/testing, you can also build the wheel directly without patching:

```bash
# Just build raw wheel (without NSGI data or PROJ bundling)
docker run --rm \
  -e PROJ_DIR=/usr \
  -e PROJ_VERSION=9.7.1 \
  -v "$PWD/dist:/dist" \
  pyproj-local \
  sh -c "uvx pip wheel --no-deps --no-binary pyproj --wheel-dir /dist pyproj==$PYPROJ_VERSION"

# Then test it (Python 3.12 required)
pip install dist/pyproj-*.whl --force-reinstall
python -c "from pyproj import Transformer; print(Transformer.from_crs('EPSG:4258', 'EPSG:28992', always_xy=True).transform(5.387639, 52.156161))"
```
