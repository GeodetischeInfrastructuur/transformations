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

Use [`build-wheel.sh`](build-wheel.sh) as the single supported entry point for building the distributable wheel. The Dockerfile prepares the prerequisite image; it does not export a distributable wheel. The script runs these steps inside that image:

1. **Wheel compilation:**
   - Run `uvx pip wheel --no-deps --no-binary pyproj` inside the pyproj Docker image
   - Outputs a raw `.whl` file with pyproj C extensions compiled against PROJ 9.7.1

2. **Wheel patching and repair (post-processing):**
   - Extract the wheel ZIP archive
   - **Inject NSGI data:** Put the standard database and grids in `pyproj/proj_dir/share/proj/`; copy that directory to `pyproj/proj_dir/share/proj_time_dependent/` and replace its `proj.db` with the time-dependent database
   - **PEP 440 versioning:** Append a local version from `3.7.2` to `3.7.2+nsgi2.2.0`; for an RC, include its suffix, e.g. `3.7.2+nsgi2.2.0rc1`, in METADATA, the `.dist-info` directory, and the wheel filename
   - **Recalculate RECORD:** Update SHA256 hashes for all files to match the wheel spec
   - **Repair with auditwheel:** `uvx --from auditwheel auditwheel repair --plat manylinux_2_28_x86_64` bundles libproj and its required non-policy dependencies (including TIFF and applicable transitive dependencies) into `pyproj.libs/`, patches ELF dependency references and library search paths, and updates platform tags and metadata. Libraries on auditwheel's manylinux policy list, such as glibc, are not bundled. The script replaces the patched wheel with the repaired output; only that final wheel should be published

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

Read the repair error first: possible causes include a dependency that cannot be located, missing `patchelf`, or symbol versions incompatible with the requested manylinux policy. Run repair inside the build image, where PROJ and its dependencies are installed. Repair cannot lower a binary's glibc requirements. Additional compatible platform tags in a repaired wheel's filename are not themselves an error.

### Missing libtiff in the runtime image

An import error such as `ImportError: libtiff.so.6: cannot open shared object file` means a native dependency cannot be loaded. Installing `libtiff-devel` in the build image does not put TIFF into a raw wheel. The script's `auditwheel repair` step bundles the linked TIFF library and patches references to use the bundled copy. Rebuild, publish, and reinstall the repaired wheel; an existing release artifact is not changed by updating the script. Test outside the build image, whose installed libraries could hide missing wheel dependencies.

## Building Locally

Building a distributable wheel requires two steps: first prepare the Docker build image, then run `build-wheel.sh` using that image. Run all commands below from the repository root. See the main [../README.md](../README.md#building-images-locally) for the prerequisite transformations image build commands.

### Step 1: Prepare the Docker build image

This example uses a locally built transformations image (`TRANSFORMATION_IMAGE_SOURCE=`). To use the published transformations image instead, omit that build argument.
The pyproj Dockerfile intentionally requires `PROJ_VERSION` and `TRANSFORMATIONS_VERSION` from the caller rather than duplicating their defaults. It skips Docker's `InvalidDefaultArgInFrom` check for those required arguments; the values passed below still need to refer to valid images.

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

### Step 2: Build the distributable wheel

Use the image from step 1 with `build-wheel.sh`. This exports the repaired wheel to the host; building the Docker image alone does not:

```bash
# Extract versions from Dockerfiles
PYPROJ_VERSION=$(grep -E '^ARG PYPROJ_VERSION=' pyproj/Dockerfile | head -1 | cut -d= -f2)
TRANSFORMATIONS_VERSION=$(grep -E '^ARG TRANSFORMATIONS_VERSION=' Dockerfile | head -1 | cut -d= -f2)
PROJ_VERSION=$(grep -E '^ARG PROJ_VERSION=' Dockerfile | head -1 | cut -d= -f2)

# Build wheel using the local pyproj Docker image
bash pyproj/build-wheel.sh pyproj-local "$PYPROJ_VERSION" "$TRANSFORMATIONS_VERSION" "$PROJ_VERSION" ../dist

# Wheel is now in ./dist/
ls -lh dist/pyproj*.whl
```

**Note:** The `build-wheel.sh` script requires:

- Docker (with the pyproj image already built or accessible)
- `uvx` available inside the pyproj image (it runs `auditwheel` for the repair step)
- `patchelf` available inside the pyproj image (required by `auditwheel repair`)
- Write access to the output directory

Arguments are `<image-tag> <pyproj-version> <transformations-version> <proj-version> [output-dir]`. Versions must match the build image. The Python ABI is selected when building the image with `--build-arg PYTHON_VERSION=...`, not by the script arguments.

Relative output paths are resolved against `pyproj/`, so the default `../dist` is the repository-root `dist/` directory. **The script deletes existing `pyproj-*.whl` files from that output directory before building.** Use separate output directories to retain wheels for multiple Python versions.

For a release candidate, use a matching prerelease build image and set `TRANSFORMATIONS_PRERELEASE_SUFFIX=-rc1` when running the script. The resulting local version ends in `rc1`, for example `3.7.2+nsgi2.2.0rc1`.

Do not use a raw `pip wheel` output as the distributable artifact: it lacks the script's NSGI data injection, version changes, and native-library repair.

### Step 3: Test the repaired wheel in a clean runtime

Run from the repository root, using the Python version selected for the build image (3.12 by default):

```bash
docker run --rm \
   --platform linux/amd64 \
   -v "$PWD/dist:/wheels:ro" \
   python:3.12-slim \
   sh -ec '
      python -m pip install --no-cache-dir /wheels/pyproj-*.whl
      python -c "import pyproj; pyproj.show_versions()"
      python -c "from pyproj import Transformer; print(Transformer.from_crs(4258, 28992, always_xy=True).transform(5.387639, 52.156161))"
   '
```

The wheel requires Linux x86-64, the matching CPython ABI, and glibc 2.28 or newer. Also test it in the actual application runtime image before publishing.
