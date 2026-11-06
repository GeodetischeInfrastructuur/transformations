# Transformations

[![GitHub license](https://img.shields.io/github/license/GeodetischeInfrastructuur/Transformations)](https://github.com/GeodetischeInfrastructuur/Transformations/blob/main/LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/GeodetischeInfrastructuur/transformations)](https://github.com/GeodetischeInfrastructuur/transformations/releases)
[![Transformations](https://img.shields.io/badge/Transformations-2.2.0--proj9.7.1-blue)](https://github.com/geodetischeinfrastructuur/transformations/pkgs/container/transformations)
[![pyproj](https://img.shields.io/badge/pyproj-3.7.2--nsgi2.2.0-blue)](https://github.com/geodetischeinfrastructuur/transformations/pkgs/container/pyproj)

This repository contains a modified proj.db that implements the following
transformations according to the recommendations of the NSGI (see image below).

![transformations](supported-transformations-nsgi.drawio.svg)

1. SQL which adds to the [PROJ](https://proj.org/en/stable/) proj.db:
   * added NSGI to authority references
   * added extents of NSGI transformations
   * added additional NL datum (AGRS.NL)
   * added additional NL CRSs
   * added additional NSGI transformations

2. A Dockerfile with [PROJ](https://proj.org/en/stable/) configured to use this
   NSGI authority as a base (published on [ghcr.io/geodetischeinfrastructuur/transformations](https://ghcr.io/geodetischeinfrastructuur/transformations))

These will form the base for the transformations that are defined or recommended by
[NSGI](https://www.nsgi.nl/) (Nederlandse Samenwerkingsverband Geodetische
Infrastructuur). In the future additional transformations might be added to this
repository.

> :warning: this repository contains 2 proj.db. The first (the default)
> `proj.db` has the sql scripts `default/nl_nsgi_00...` till `default/nl_nsgi_05...` applied. The
> second `proj.time.dependent.transformations.db` has the sql script
> `time_dependent/nl_nsgi_00_time_dependent_transformations.sql` applied for adding time
> dependent transformations. For this second proj.db, a input epoch should be
> provided (when applicable), to prevent the use of the default reference epoch
> of the transformation. When one wants to use this second proj.db this can be done
> in the following ways.
>
> Through a move command
>
> ```bash
> mv proj.db proj.db.bak
> mv proj.time.dependent.transformations.db proj.db
> ```
>
> or through the creating of a symbolic link
>
> ```bash
> ln -s proj.time.dependent.transformations.db proj.db
> ```

## Versioning

The GitHub release and `transformations` image tag lead with the NSGI
transformations semver: `{TRANSFORMATIONS_VERSION}[-rcN]-proj{PROJ_VERSION}`.
For example, `2.2.0-rc1-proj9.7.1` is an RC and `2.2.0-proj9.7.1` is its final
release. The `pyproj` image tag remains based on the upstream pyproj version and
includes the NSGI version and optional RC suffix.

| Artifact | Example tag / filename | Versioned by |
| :--- | :--- | :--- |
| GitHub release / `ghcr.io/geodetischeinfrastructuur/transformations` | `2.2.0-proj9.7.1` (RC: `2.2.0-rc1-proj9.7.1`) | NSGI semver + PROJ version |
| ↳ `proj.db` (GitHub release asset) | `proj.db` | same as above |
| ↳ `proj.time.dependent.transformations.db` (GitHub release asset) | `proj.time.dependent.transformations.db` | same as above |
| `ghcr.io/geodetischeinfrastructuur/pyproj` | `3.7.2-nsgi2.2.0` | pyproj version + NSGI semver |
| ↳ `pyproj` wheel (GitHub release asset) | `pyproj-3.7.2+nsgi2.2.0-cp312-cp312-manylinux_2_28_x86_64.whl` | same as above |

The wheel encodes the NSGI semver as a PEP 440 **local version** (`3.7.2+nsgi2.2.0`): it keeps the upstream public version `3.7.2` (so `pyproj==3.7.2` still matches) while recording the NSGI generation. RC wheels include the RC marker in that local version, e.g. `3.7.2+nsgi2.2.0rc1`; the final wheel is `3.7.2+nsgi2.2.0`. One wheel is published per supported CPython (`cp312`–`cp315`), and each wheel includes both databases. The standard database is in pyproj's default data directory; the time-dependent database is in the sibling `proj_time_dependent` directory.

**Bumping rules** — `TRANSFORMATIONS_VERSION` follows semver:

- NSGI config change → bump `TRANSFORMATIONS_VERSION` (new transformation/CRS → minor `2.1.0-proj9.7.1`; no-result fix → patch `2.0.1-proj9.7.1`; breaking change → major `3.0.0-proj9.7.1`)
- PROJ version update → bump `PROJ_VERSION` (e.g. `2.0.0-proj9.7.2`)
- pyproj version update → bump `PYPROJ_VERSION` (e.g. pyproj image `3.7.3-nsgi2.0.0`)

Both images are always released together from a single GitHub release. The release tag leads with the NSGI semver and includes the PROJ version (`2.2.0-rc1-proj9.7.1` for an RC; `2.2.0-proj9.7.1` for final).

> **To create a new release:**
> 1. Edit as needed:
>    - [`Dockerfile`](Dockerfile) — for NSGI config changes or PROJ version updates: bump `ARG PROJ_VERSION` and/or `ARG TRANSFORMATIONS_VERSION`
>    - [`pyproj/Dockerfile`](pyproj/Dockerfile) — only for pyproj version updates: bump `ARG PYPROJ_VERSION`
> 2. Create and publish a GitHub release with tag matching `{TRANSFORMATIONS_VERSION}[-rcN]-proj{PROJ_VERSION}` (e.g. `2.1.0-proj9.7.1` or `2.2.0-rc1-proj9.7.1`). Mark RC releases as prereleases in GitHub.
>
> The release workflow:
> - Reads `PROJ_VERSION` and `TRANSFORMATIONS_VERSION` from the root `Dockerfile`
> - Reads `PYPROJ_VERSION` from `pyproj/Dockerfile`
> - Builds the transformations image (using root Dockerfile values)
> - Passes PROJ version strings to pyproj build
> - Uses the release tag for the transformations image and derives pyproj image tags from the Dockerfile versions
> - Includes `rcN` in prerelease wheel versions and filenames (e.g. `+nsgi2.2.0rc1`)

## Integration

There are three options to use the NSGI-configured PROJ in your own environment.

### 1. Use the transformations Docker image

Use `ghcr.io/geodetischeinfrastructuur/transformations:latest` as a base image or run it directly. This gives you a fully configured `libproj` with the NSGI `proj.db`. Suitable for:

- **C/C++ applications** that link against `libproj`
- **OSGEO command-line tools** that use `libproj` under the hood: `cs2cs`, `projinfo`, `gdal`, `ogr2ogr`, etc.

```bash
# Example: transform a coordinate with cs2cs
docker run --rm ghcr.io/geodetischeinfrastructuur/transformations:latest \
  sh -c 'echo "52.115330444 7.684748554 41.4160" | cs2cs -f "%.4f" EPSG:7931 EPSG:7415'
```

> **NOTE:** for prod environments it is recommended to pin the docker image to a specific version, see [pkgs/container/transformations](https://github.com/GeodetischeInfrastructuur/transformations/pkgs/container/transformations).

```dockerfile
# Example: use as base image
FROM ghcr.io/geodetischeinfrastructuur/transformations:latest
RUN apt-get install -y my-libproj-dependent-app
```

### 2. Install the published custom pyproj wheel with uv

The release workflow publishes a custom `pyproj` wheel as a GitHub release asset. This is a pre-compiled wheel that bundles pyproj with NSGI transformations, custom PROJ databases, and grid files. Wheels are built for Linux `amd64` (`x86_64`, `manylinux_2_28`, so glibc 2.28 or newer) and CPython `3.12`–`3.15`.

The wheel contains the Python package, compiled extension, both NSGI custom PROJ data directories, and the `nl_nsgi` grid files. It is self-contained — no extra grid downloads, environment variables, or system libproj dependencies are needed after install.

The standard database is selected by default. To use the time-dependent database,
point pyproj at the packaged sibling directory before constructing transformers:

```python
from pathlib import Path
import pyproj

time_dependent_dir = Path(pyproj.__file__).parent / "proj_dir/share/proj_time_dependent"
pyproj.datadir.set_data_dir(str(time_dependent_dir))
```

If you use `uv`, point your project at the published wheel with a direct URL dependency. The simplest form is to replace the PyPI dependency with the release asset URL:

```toml
[project]
dependencies = [
  "pyproj @ https://github.com/GeodetischeInfrastructuur/transformations/releases/download/2.2.0-proj9.7.1/pyproj-3.7.2+nsgi2.2.0-cp312-cp312-manylinux_2_28_x86_64.whl",
]
```

If you want to keep the dependency name separate from the wheel location, use a `tool.uv.sources` override instead:

```toml
[project]
dependencies = [
  "pyproj==3.7.2",
]

[tool.uv.sources]
pyproj = { url = "https://github.com/GeodetischeInfrastructuur/transformations/releases/download/2.2.0-proj9.7.1/pyproj-3.7.2+nsgi2.2.0-cp312-cp312-manylinux_2_28_x86_64.whl" }
```

After updating `pyproject.toml`, run `uv lock` and `uv sync`.

This wheel is intended for local Python environments and Docker images that run on Linux `amd64` with Python `3.12`–`3.15`. For other platforms or Python versions, use the Docker image or build from source instead.

### 3. Manual setup for local Python environments

If Docker is unavailable, configure pyproj manually. This requires cloning this repository.

```sh
proj_dir=$(python -c 'import pyproj;print(pyproj.datadir.get_data_dir())')
./configure-proj.sh "$proj_dir" ./sql 2.0.0
# Download grids for NSGI transformations
projsync --source-id nl_nsgi --target-dir "$proj_dir"
# or use --all (+700 MB) to download all grids
# projsync --all --target-dir "$proj_dir"
# or enable on-demand grid downloads via network
export PROJ_NETWORK=ON
```

## For Developers

This section covers building the artifacts in this repository locally. The repository produces two Docker images and one Python wheel:

- **`transformations` image** — Built from the root [`Dockerfile`](Dockerfile). Contains the NSGI-customized `proj.db` on top of `osgeo/proj`.
- **`pyproj` image** — Built from [`pyproj/Dockerfile`](pyproj/Dockerfile). Adds pyproj compiled against PROJ 9.7.1 with NSGI data baked in.
- **`pyproj` wheel** — Built via [`pyproj/build-wheel.sh`](pyproj/build-wheel.sh) from inside the pyproj image. One self-contained wheel with bundled PROJ, both NSGI database directories, and grids.

> For details on the pyproj image multi-stage build, wheel patching, RPATH manipulation, libcurl troubleshooting, and version coordination, see [pyproj/README.md](pyproj/README.md).

### Build the transformations image

The root [`Dockerfile`](Dockerfile) builds the `transformations` image. It applies the SQL scripts under [`sql/`](sql/) to the PROJ database from `osgeo/proj:${PROJ_VERSION}` and produces both `proj.db` (default) and `proj.time.dependent.transformations.db` (time-dependent variant).

Build with default versions (read from [`Dockerfile`](Dockerfile) `ARG` defaults):

```bash
docker build -t transformations:2.2.0-proj9.7.1 -t transformations .
```

Override `PROJ_VERSION` or `TRANSFORMATIONS_VERSION` via build args:

```bash
docker build -t transformations:2.2.0-proj9.7.1 . \
  --build-arg PROJ_VERSION=9.7.1 \
  --build-arg TRANSFORMATIONS_VERSION=2.2.0
```

Verify the build with `cs2cs`:

```bash
docker run --rm transformations:2.2.0-proj9.7.1 \
  sh -c 'echo "52.115330444 7.684748554 41.4160" | cs2cs -f "%.4f" EPSG:7931 EPSG:7415'
# Expected: 312352.6004 461058.5812 -2.5206
```

### Build the pyproj image

The [`pyproj/Dockerfile`](pyproj/Dockerfile) builds on top of the `transformations` image and compiles pyproj from source against PROJ 9.7.1. **The build must run from the repository root** (not from `pyproj/`) to access the validation scripts.

> **libcurl note:** PROJ is built from source in the pyproj image, so it does not need to match the libcurl of `osgeo/proj`. The image uses `libcurl-minimal` (TLS via OpenSSL); see [pyproj/README.md#key-dependency-libcurl](pyproj/README.md#key-dependency-libcurl).

Build against a local `transformations` image (built in the previous step), reading versions from the root [`Dockerfile`](Dockerfile):

```bash
docker build . -f pyproj/Dockerfile \
  --build-arg TRANSFORMATION_IMAGE_SOURCE= \
  --build-arg PROJ_VERSION=$(grep -E '^ARG PROJ_VERSION=' Dockerfile | head -1 | cut -d= -f2) \
  --build-arg TRANSFORMATIONS_VERSION=$(grep -E '^ARG TRANSFORMATIONS_VERSION=' Dockerfile | head -1 | cut -d= -f2) \
  -t pyproj
```

Or with explicit values:

```bash
docker build . -f pyproj/Dockerfile \
  --build-arg TRANSFORMATION_IMAGE_SOURCE= \
  --build-arg PROJ_VERSION=9.7.1 \
  --build-arg TRANSFORMATIONS_VERSION=2.2.0 \
  --build-arg TRANSFORMATION_IMAGE_TAG=2.2.0-proj9.7.1 \
  -t pyproj:3.7.2-nsgi2.2.0
```

Build against the registry (no local `transformations` image needed):

```bash
docker build . -f pyproj/Dockerfile \
  --build-arg TRANSFORMATION_IMAGE_SOURCE=ghcr.io/geodetischeinfrastructuur/ \
  --build-arg PROJ_VERSION=$(grep -E '^ARG PROJ_VERSION=' Dockerfile | head -1 | cut -d= -f2) \
  --build-arg TRANSFORMATIONS_VERSION=$(grep -E '^ARG TRANSFORMATIONS_VERSION=' Dockerfile | head -1 | cut -d= -f2) \
  -t pyproj
```

### Build the pyproj wheel

Use [`pyproj/build-wheel.sh`](pyproj/build-wheel.sh) as the single supported entry point for building the distributable wheel. The Dockerfile prepares the build image but does not export the final wheel. The script compiles the raw wheel, injects both NSGI data directories and the PEP 440 local version (`+nsgi<version>`), then runs `uvx --from auditwheel auditwheel repair` for `manylinux_2_28_x86_64`. Repair bundles PROJ and its required non-policy shared libraries, including TIFF, and patches library references and search paths. Publish only the final repaired wheel, not a raw `pip wheel` output.

```bash
# Prerequisites: pyproj image built locally (see previous section)
chmod +x pyproj/build-wheel.sh
pyproj/build-wheel.sh pyproj 3.7.2 2.2.0 9.7.1 ../dist

# Output:
ls -lh dist/pyproj*.whl
```

Arguments: `<image-tag> <pyproj-version> <transformations-version> <proj-version> [output-dir]`.
Versions must match the build image; its `PYTHON_VERSION` build argument determines the wheel's Python ABI. Relative output paths are resolved against `pyproj/`, so `../dist` means the repository-root `dist/` directory. **The script deletes existing `pyproj-*.whl` files in the output directory**; use separate directories to retain wheels for multiple Python versions.

For a release candidate, set `TRANSFORMATIONS_PRERELEASE_SUFFIX=-rc1` when
running the script; the wheel's local version will end in `rc1` (for example,
`pyproj-3.7.2+nsgi2.2.0rc1-cp312-...whl`).

For the technical details of wheel patching (RPATH fixes, RECORD hashing, NSGI data injection), see [pyproj/README.md](pyproj/README.md#wheel-build-via-docker-container).
Before publishing, [test the repaired wheel in a clean runtime container](pyproj/README.md#step-3-test-the-repaired-wheel-in-a-clean-runtime), not only the build image: installed build dependencies can hide missing bundled libraries.


## Validation

### Manual validation transformations PROJ

To verify that NSGI transformations are correctly installed in the  PROJ environment, you can use the `cs2cs` command to transform coordinates:

```bash
docker build -t transformations:2.0.0-proj9.7.1 -t transformations .
docker run --rm transformations sh -c 'echo "52.115330444 7.684748554 41.4160" | cs2cs -f "%.4f" EPSG:7931 EPSG:7415'
```

Expected output:

```txt
312352.6004 461058.5812 -2.5206
```


### Manual validation transformations pyproj

To verify that NSGI transformations are correctly installed via the published wheel, run the following command (requires Linux `amd64` and Python `3.12`):

```bash
# Fetch the latest wheel URL from GitHub releases (or pin a specific version)
WHEEL_URL=$(curl -s https://api.github.com/repos/geodetischeinfrastructuur/transformations/releases | jq -r '.[0].assets[] | select(.name | endswith("cp312-cp312-manylinux_2_28_x86_64.whl")) | .browser_download_url')
PROJ_NETWORK=ON uv run --python 3.12 --with "pyproj @ $WHEEL_URL" python -c '
from pyproj import transformer
etrf = transformer.TransformerGroup("EPSG:7931", "EPSG:7415")
result = etrf.transformers[0].transform(52.115330444, 7.684748554, 41.4160)
print("{0[0]:.4f} {0[1]:.4f} {0[2]:.4f}".format(result))
'
```

> **Note:** `PROJ_NETWORK=ON` is _not_ required for this specific transformation — the `nl_nsgi` grids are bundled in the wheel. It is included here for completeness. However, you may need `PROJ_NETWORK=ON` if using other transformations that require grids not included in the wheel (e.g., transformations that use global or regional grids from PROJ's CDN).

Expected output:

```txt
312352.6004 461058.5812 -2.5206
```

### Validate transformation accuracy with NSGI validation service

Use the [NSGI validation service](https://www.nsgi.nl/coordinatenstelsels-en-transformaties/tools/validatieservice) to verify transformation accuracy. The service tests transformations between EPSG:7931 (ETRS89) and EPSG:7415 (RDNAP) and returns an accuracy score. The transformation direction is determined automatically based on feature IDs in the input dataset:

| first feature fid | source crs | target crs |
| :--- | :--- | :--- |
| 20020000 | EPSG:7931 | EPSG:7415 |
| 10020000 | EPSG:7415 | EPSG:7931 |

Download the test datasets, transform them with this tool, and upload the results:

```sh
(
    cd validation/data
    curl -o 002_RDNAP.txt 'https://www.nsgi.nl/documents/1888506/1945213/002_RDNAP.txt/5d6dc6b8-a59d-40d0-0363-8a9b59e51c62?t=1574879689583'
    curl -o 002_ETRS89.txt 'https://www.nsgi.nl/documents/1888506/1944539/002_ETRS89.txt/6aa954da-d345-de97-386a-4fbd956edf52?t=1574879755720'
)

# Fetch the latest wheel URL from GitHub releases
WHEEL_URL=$(curl -s https://api.github.com/repos/geodetischeinfrastructuur/transformations/releases | jq -r '.[0].assets[] | select(.name | endswith("cp312-cp312-manylinux_2_28_x86_64.whl")) | .browser_download_url')
uv run --with "pyproj @ $WHEEL_URL" \
  python validation/transform_csv.py validation/data/002_ETRS89.txt validation/data/002_ETRS89_transformed.txt
uv run --with "pyproj @ $WHEEL_URL" \
  python validation/transform_csv.py validation/data/002_RDNAP.txt validation/data/002_RDNAP_transformed.txt
```

Upload the generated files to the [validation service](https://www.nsgi.nl/coordinatenstelsels-en-transformaties/tools/validatieservice). The score must be 100% for *Netherlands+EEZ*.

### Validate transformation accuracy with reference coordinates

Validate transformation accuracy against reference coordinates. The file `Z001_ETRS89andRDNAP.txt` contains verified coordinate pairs in both ETRS89 and RDNAP. The script transforms each set and calculates deviation from the known values—measuring transformation accuracy.

```bash
# Fetch the latest wheel URL from GitHub releases
WHEEL_URL=$(curl -s https://api.github.com/repos/geodetischeinfrastructuur/transformations/releases | jq -r '.[0].assets[] | select(.name | endswith("cp312-cp312-manylinux_2_28_x86_64.whl")) | .browser_download_url')
uv run --with "pyproj @ $WHEEL_URL" \
  python validation/validate.py validation/data/Z001_ETRS89andRDNAP.txt /tmp/Z001_ETRS89andRDNAP_transformed.csv
```

This outputs `/tmp/Z001_ETRS89andRDNAP_transformed.csv`. If correct, the transformed coordinates will have minimal deviation from the known coordinates.

<!-- TODO: add check to verify if deviations are within a certain threshold. -->

## LICENSE

The SQL used in this repository is licensed under a [CC-BY license](./LICENSE).

All other code in this repository is licensed under the [MIT
license](./LICENSE-CODE).
