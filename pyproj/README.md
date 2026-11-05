# pyproj: Building and Troubleshooting

This directory contains the Docker configuration and build scripts for the `pyproj` wheel and Docker image. Both are built from the same Python dependencies and PROJ 9.7.1 foundation.

## High-Level Build Process

### Docker Image Build (`docker build . -f pyproj/Dockerfile`)

The Docker image (`ghcr.io/geodetischeinfrastructuur/pyproj:3.7.2-nsgi2.2.0`) packages pyproj with NSGI customizations into a ready-to-use container:

1. **Base Stages (multi-stage build):**
   - `proj-source` — Downloads the nl_nsgi grids with `projsync` from `osgeo/proj:9.7.1`
   - `transformations` — Pulls the base transformations image containing NSGI proj.db
   - `uv-source` — Extracts the `uv` package manager binary

2. **Final Stage (`quay.io/pypa/manylinux_2_28_x86_64`, AlmaLinux 8, glibc 2.28):**
   - Build PROJ 9.7.1 from source with CMake into `/usr/local`, with curl and TIFF support and libstdc++/libgcc linked statically
   - Swap the base image's full `libcurl` for `libcurl-minimal` (TLS via OpenSSL) and install `libcurl-devel` for headers; the CPython interpreter (3.12–3.15, selected by `PYTHON_VERSION`) is provided by uv (`UV_PYTHON`)
   - Run `uv sync --no-binary-package pyproj` to compile pyproj from source against that PROJ build
   - Copy NSGI proj databases and grids into pyproj's internal data directory
   - Set `PATH` to expose the venv's binaries

**Result:** A Docker image with pyproj installed and ready to use. The venv is at `/app/.venv`.

### Wheel Build (via Docker container)

The wheel (`pyproj-3.7.2+nsgi2.2.0-cp312-cp312-manylinux_2_28_x86_64.whl`) is built inside the Docker image and then repaired:

1. **Wheel compilation:**
   - Run `uvx pip wheel --no-deps --no-binary pyproj` inside the pyproj Docker image
   - Outputs a raw `.whl` file with pyproj C extensions compiled against PROJ 9.7.1

2. **Wheel patching and repair (post-processing):**
   - Extract the wheel ZIP archive
   - **Inject NSGI data:** Put the standard database and grids in `pyproj/proj_dir/share/proj/`; copy that directory to `pyproj/proj_dir/share/proj_time_dependent/` and replace its `proj.db` with the time-dependent database
   - **PEP 440 versioning:** Append a local version from `3.7.2` to `3.7.2+nsgi2.2.0`; for an RC, include its suffix, e.g. `3.7.2+nsgi2.2.0rc1`, in METADATA, the `.dist-info` directory, and the wheel filename
   - **Recalculate RECORD:** Update SHA256 hashes for all files to match the wheel spec
   - **Repair with auditwheel:** `auditwheel repair --plat manylinux_2_28_x86_64` bundles libproj and its dependencies (18 libraries, including libcurl, OpenSSL, libsqlite3, and libtiff) into `pyproj.libs/`, sets RPATHs, and tags the wheel `manylinux_2_28_x86_64`. Libraries on auditwheel's manylinux policy list, such as glibc, are not bundled

**Result:** One self-contained wheel that bundles pyproj, PROJ, both NSGI data directories, and grids. The standard directory is active by default; applications can select `proj_time_dependent` with `pyproj.datadir.set_data_dir()` before creating transformers.

```python
from pathlib import Path
import pyproj

time_dependent_dir = Path(pyproj.__file__).parent / "proj_dir/share/proj_time_dependent"
pyproj.datadir.set_data_dir(str(time_dependent_dir))
```

### Key Dependency: libcurl

PROJ is built from source in the pyproj image, so it is not tied to the libcurl that `osgeo/proj` was built against. The base image ships the full `libcurl` with LDAP, SSH, and libpsl support. The Dockerfile replaces it with `libcurl-minimal`, which keeps TLS through OpenSSL; `libcurl-devel` supplies the headers. This removes libssh, libldap, libsasl2, libpsl, libidn2, and brotli from the bundled set.

**Verify the libcurl build in the image:**
```bash
docker run --rm pyproj:3.7.2-nsgi2.2.0 sh -c 'rpm -q libcurl-minimal; ldd /usr/lib64/libcurl.so.4 | grep -E "ssl|ldap|ssh"'
# Expected: libssl.so.1.1 is listed; no libldap or libssh
```

`curl-config --features` still lists LDAP and SSH, because it reads build metadata from `libcurl-devel`. The shipped library does not link them.

## Troubleshooting

### libcurl without TLS support

If PROJ cannot fetch grids over HTTPS, check that the image uses `libcurl-minimal` and that it is linked against OpenSSL:

```bash
docker run --rm pyproj:3.7.2-nsgi2.2.0 sh -c 'rpm -q libcurl libcurl-minimal; ldd /usr/lib64/libcurl.so.4 | grep ssl'
```

`rpm -q libcurl` should report that the package is not installed. Do not install the full `libcurl` next to `libcurl-minimal`; the two conflict. The Dockerfile's `yum -y swap` removes the full library.

### Version mismatch between Dockerfiles

If the pyproj image build fails with version mismatches, ensure `PROJ_VERSION` and `TRANSFORMATIONS_VERSION` in the root [../Dockerfile](../Dockerfile) match what's passed to [Dockerfile](Dockerfile). Run the build commands from the repository root, not from subdirectories.

### auditwheel repair failures

If `auditwheel repair` fails, or `auditwheel show` reports a tag other than `manylinux_2_28_x86_64`, a bundled library needs a newer glibc or a symbol version above 2.28. Check the Docker build output for compilation errors, and confirm `uv sync` produced the `.so` files in the pyproj package directory.

## Building Locally

See the main [../README.md](../README.md#building-images-locally) for build commands. For quick iteration:

```bash
# Build Docker image
docker build . -f pyproj/Dockerfile \
  --pull=false \
  --build-arg TRANSFORMATION_IMAGE_SOURCE= \
   --build-arg PROJ_VERSION=$(grep -E '^ARG PROJ_VERSION=' Dockerfile | head -1 | cut -d= -f2) \
   --build-arg TRANSFORMATIONS_VERSION=$(grep -E '^ARG TRANSFORMATIONS_VERSION=' Dockerfile | head -1 | cut -d= -f2) \
  -t pyproj-local

# Test inside container
docker run --rm pyproj-local python -c "from pyproj import Transformer; print(Transformer.from_crs('EPSG:4258', 'EPSG:28992', always_xy=True).transform(5.387639, 52.156161))"
```

### Building the wheel locally

To build the wheel locally, use the `build-wheel.sh` script from the repository root:

```bash
# Extract versions from Dockerfiles
PYPROJ_VERSION=$(grep -E '^ARG PYPROJ_VERSION=' pyproj/Dockerfile | head -1 | cut -d= -f2)
TRANSFORMATIONS_VERSION=$(grep -E '^ARG TRANSFORMATIONS_VERSION=' Dockerfile | head -1 | cut -d= -f2)
PROJ_VERSION=$(grep -E '^ARG PROJ_VERSION=' Dockerfile | head -1 | cut -d= -f2)

# Build wheel using the local pyproj Docker image
chmod +x pyproj/build-wheel.sh
pyproj/build-wheel.sh pyproj-local "$PYPROJ_VERSION" "$TRANSFORMATIONS_VERSION" "$PROJ_VERSION" ../dist

# Wheel is now in ./dist/
ls -lh dist/pyproj*.whl
```

**Note:** The `build-wheel.sh` script requires:
- Docker (with the pyproj image already built or accessible)
- `uvx` available inside the pyproj image (it runs `auditwheel` for the repair step)
- Write access to the output directory

For development/testing, you can also build the wheel directly without patching:

```bash
# Just build raw wheel (without NSGI data or PROJ bundling)
docker run --rm \
  -e PROJ_DIR=/usr/local \
   -e PROJ_VERSION=$(grep -E '^ARG PROJ_VERSION=' Dockerfile | head -1 | cut -d= -f2) \
  -v "$PWD/dist:/dist" \
  pyproj-local \
  sh -c "uvx pip wheel --no-deps --no-binary pyproj --wheel-dir /dist pyproj==$PYPROJ_VERSION"

# Then test it (Python 3.12 required)
pip install dist/pyproj-*.whl --force-reinstall
python -c "from pyproj import Transformer; print(Transformer.from_crs('EPSG:4258', 'EPSG:28992', always_xy=True).transform(5.387639, 52.156161))"
```
