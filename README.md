# Transformations

[![GitHub license](https://img.shields.io/github/license/GeodetischeInfrastructuur/Transformations)](https://github.com/GeodetischeInfrastructuur/Transformations/blob/main/LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/GeodetischeInfrastructuur/transformations)](https://github.com/GeodetischeInfrastructuur/transformations/releases)
[![PROJ](https://img.shields.io/badge/PROJ-9.7.1--post1-blue)](https://github.com/geodetischeinfrastructuur/transformations/pkgs/container/transformations)
[![pyproj](https://img.shields.io/badge/pyproj-3.7.2--post1-blue)](https://github.com/geodetischeinfrastructuur/transformations/pkgs/container/pyproj)

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

Both Docker images use a `BASE_VERSION-postN` tag scheme, where `N` is incremented for NSGI configuration changes.
For `ghcr.io/geodetischeinfrastructuur/transformations`, `BASE_VERSION` is the PROJ version.
For `ghcr.io/geodetischeinfrastructuur/pyproj`, `BASE_VERSION` is the pyproj version.

| Artifact | Example tag / filename | Versioned by |
| :--- | :--- | :--- |
| `ghcr.io/geodetischeinfrastructuur/transformations` | `9.7.1-post1` | PROJ version |
| ↳ `proj.db` (GitHub release asset) | `proj.db` | same as above |
| ↳ `proj.time.dependent.transformations.db` (GitHub release asset) | `proj.time.dependent.transformations.db` | same as above |
| `ghcr.io/geodetischeinfrastructuur/pyproj` | `3.7.2-post1` | pyproj version |
| ↳ `pyproj` wheel (GitHub release asset) | `pyproj-3.7.2.post1-cp312-cp312-linux_x86_64.whl` | same as above |

**Bumping rules** — `N` is always incremented, never reset:

- NSGI config change → increment `N` (e.g. `9.7.1-post1` → `9.7.1-post2`)
- PROJ version update → bump `PROJ_VERSION`, increment `N` (e.g. `9.7.2-post3`)
- pyproj version update → bump `PYPROJ_VERSION`, increment `N` (e.g. `3.7.3-post4`)

Both images are always released together from a single GitHub release. The release tag encodes the PROJ version because that is the shared base both images are built on — the `transformations` tag answers "which PROJ version?" for both images. `N` is a global counter across all releases; resetting it on a version bump would risk overwriting a previous tag.

> **To create a new release:**
> 1. Edit as needed:
>    - [`Dockerfile`](Dockerfile) — for NSGI config changes or PROJ version updates: bump `ARG PROJ_VERSION` and/or `ARG POST_PATCH`
>    - [`pyproj/Dockerfile`](pyproj/Dockerfile) — only for pyproj version updates: bump `ARG PYPROJ_VERSION`
> 2. Create and publish a GitHub release with tag matching `{PROJ_VERSION}-post{POST_PATCH}` (e.g. `9.7.1-post2`).
>
> The release workflow:
> - Reads `PROJ_VERSION` and `POST_PATCH` from the root `Dockerfile`
> - Reads `PYPROJ_VERSION` from `pyproj/Dockerfile`
> - Builds the transformations image (using root Dockerfile values)
> - Passes PROJ version strings to pyproj build
> - Applies derived versions to both Docker image tags, the wheel version, and the wheel filename

## Integration

There are three options to use the NSGI-configured PROJ in your own environment.

### 1. Use the transformations Docker image

Use `ghcr.io/geodetischeinfrastructuur/transformations:latest` as a base image or run it directly. This gives you a fully configured `libproj` with the NSGI `proj.db` and correction grids. Suitable for:

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

The release workflow publishes a custom `pyproj` wheel as a GitHub release asset. As built today, that wheel is for Linux `amd64` (`x86_64`) and CPython `3.12` only.

The wheel contains the Python package, compiled extension, and the NSGI custom PROJ data directory (`proj.db` and grids) bundled inside it. No additional data directory setup is needed after installation.

If you use `uv`, point your project at the published wheel with a direct URL dependency. The simplest form is to replace the PyPI dependency with the release asset URL:

```toml
[project]
dependencies = [
  "pyproj @ https://github.com/GeodetischeInfrastructuur/transformations/releases/download/9.7.1-post1/pyproj-3.7.2.post1-cp312-cp312-linux_x86_64.whl",
]
```

If you want to keep the dependency name separate from the wheel location, use a `tool.uv.sources` override instead:

```toml
[project]
dependencies = [
  "pyproj==3.7.2.post1",
]

[tool.uv.sources]
pyproj = { url = "https://github.com/GeodetischeInfrastructuur/transformations/releases/download/9.7.1-post1/pyproj-3.7.2.post1-cp312-cp312-linux_x86_64.whl" }
```

After updating `pyproject.toml`, run `uv lock` and `uv sync`.

This wheel is intended for local Python environments and Docker images that run on Linux `amd64` with Python `3.12`. For other platforms or Python versions, use the Docker image or build from source instead.

### 3. Manual setup for local Python environments

If Docker is unavailable, configure pyproj manually. This requires cloning this repository.

```sh
proj_dir=$(python -c 'import pyproj;print(pyproj.datadir.get_data_dir())')
./configure-proj.sh "$proj_dir" ./sql ./grids
# pyproj installation does not come pre installed with all grids, download grids for nl_nsgi
projsync --source-id nl_nsgi --target-dir "$proj_dir"
# or use --all (+700 MB)
# projsync --all --target-dir "$proj_dir"
# or use pyproj with environment variable to downlaod grids automatically as needed
# export PROJ_NETWORK=ON
```

## Building Images Locally

### Build the transformations image

To build the transformations Docker image locally with the default PROJ version and patch level:

```bash
docker build -t transformations .
```

To build with custom `PROJ_VERSION` or `POST_PATCH`:

```bash
docker build -t transformations . \
  --build-arg PROJ_VERSION=9.7.1 \
  --build-arg POST_PATCH=1
```

The image tag will follow the pattern `transformations:latest`. To tag it with the version:

```bash
docker build -t transformations:9.7.1-post1 .
```

### Build the pyproj image

The pyproj image depends on the transformations image, so build transformations first (or fetch from the registry).

To build against your local transformations image (after building it above), reading versions from the root `Dockerfile`:

```bash
docker build -t pyproj ./pyproj \
  --build-arg TRANSFORMATION_IMAGE_SOURCE= \
  --build-arg PROJ_VERSION=$(grep -E '^ARG PROJ_VERSION=' Dockerfile | head -1 | cut -d= -f2) \
  --build-arg POST_PATCH=$(grep -E '^ARG POST_PATCH=' Dockerfile | head -1 | cut -d= -f2)
```

Or pass explicit values:

```bash
docker build -t pyproj ./pyproj \
  --build-arg TRANSFORMATION_IMAGE_SOURCE= \
  --build-arg PROJ_VERSION=9.7.1 \
  --build-arg POST_PATCH=1
```

To build against the registry (without a local transformations image):

```bash
docker build -t pyproj ./pyproj \
  --build-arg TRANSFORMATION_IMAGE_SOURCE=ghcr.io/geodetischeinfrastructuur/ \
  --build-arg PROJ_VERSION=$(grep -E '^ARG PROJ_VERSION=' Dockerfile | head -1 | cut -d= -f2) \
  --build-arg POST_PATCH=$(grep -E '^ARG POST_PATCH=' Dockerfile | head -1 | cut -d= -f2)
```

To override the pyproj version (for testing):

```bash
docker build -t pyproj:3.7.2-post1 ./pyproj \
  --build-arg TRANSFORMATION_IMAGE_SOURCE= \
  --build-arg PYPROJ_VERSION=3.7.2 \
  --build-arg POST_PATCH=1 \
  --build-arg PROJ_VERSION=$(grep -E '^ARG PROJ_VERSION=' Dockerfile | head -1 | cut -d= -f2)
```


## Validation

### Manual validation transformations PROJ

To verify that NSGI transformations are correctly installed in the  PROJ environment, you can use the `cs2cs` command to transform coordinates:

```bash
docker build -t transformations .
docker run --rm transformations sh -c 'echo "52.115330444 7.684748554 41.4160" | cs2cs -f "%.4f" EPSG:7931 EPSG:7415'
```

Expected output:

```txt
312352.6004 461058.5812 -2.5206
```

### Manual validation transformations pyproj

To verify that NSGI transformations are correctly installed via the published wheel, run the following command (requires Linux `amd64` and Python `3.12`):

```bash
WHEEL_URL="https://github.com/GeodetischeInfrastructuur/transformations/releases/download/9.7.1-post1/pyproj-3.7.2.post1-cp312-cp312-linux_x86_64.whl"
uv run --with "pyproj @ $WHEEL_URL" python validation/transform_csv.py validation/data/002_ETRS89.txt validation/data/002_ETRS89_transformed.txt
```

Expected output: transformed coordinates file.

### Validate transformation accuracy with NSGI validation service

Use the [NSGI validation service](https://www.nsgi.nl/coordinatenstelsels-en-transformaties/tools/validatieservice) to verify transformation accuracy. The service tests transformations between EPSG:7931 (ETRS89) and EPSG:7415 (RDNAP) and returns an accuracy score. The transformation direction is determined automatically based on feature IDs in the input dataset:

| first feature fid | source crs | target crs |
| :--- | :--- | :--- |
| 20020000 | EPSG:7931 | EPSG:7415 |
| 10020000 | EPSG:7415 | EPSG:7931 |

Download the test datasets, transform them with this tool, and upload the results:

```sh
curl -o validation/data/002_RDNAP.txt 'https://www.nsgi.nl/documents/1888506/1945213/002_RDNAP.txt/5d6dc6b8-a59d-40d0-0363-8a9b59e51c62?t=1574879689583'
curl -o validation/data/002_ETRS89.txt 'https://www.nsgi.nl/documents/1888506/1944539/002_ETRS89.txt/6aa954da-d345-de97-386a-4fbd956edf52?t=1574879755720'

WHEEL_URL="https://github.com/GeodetischeInfrastructuur/transformations/releases/download/9.7.1-post1/pyproj-3.7.2.post1-cp312-cp312-linux_x86_64.whl"
uv run --with "pyproj @ $WHEEL_URL" python validation/transform_csv.py validation/data/002_ETRS89.txt validation/data/002_ETRS89_transformed.txt
uv run --with "pyproj @ $WHEEL_URL" python validation/transform_csv.py validation/data/002_RDNAP.txt validation/data/002_RDNAP_transformed.txt
```

Upload the generated files to the [validation service](https://www.nsgi.nl/coordinatenstelsels-en-transformaties/tools/validatieservice). The score must be 100% for *Netherlands+EEZ*.

### Validate transformation accuracy with reference coordinates

Validate transformation accuracy against reference coordinates. The file `validation/data/Z001_ETRS89andRDNAP.txt` contains verified coordinate pairs in both ETRS89 and RDNAP. The script transforms each set and calculates deviation from the known values—measuring transformation accuracy.

```bash
WHEEL_URL="https://github.com/GeodetischeInfrastructuur/transformations/releases/download/9.7.1-post1/pyproj-3.7.2.post1-cp312-cp312-linux_x86_64.whl"
uv run --with "pyproj @ $WHEEL_URL" python validation/validate.py validation/data/Z001_ETRS89andRDNAP.txt validation/data/Z001_ETRS89andRDNAP_transformed.csv
```

This outputs `validation/data/Z001_ETRS89andRDNAP_transformed.csv` file. If correct, the transformed coordinates will have minimal deviation from the known coordinates.

<!-- TODO: add check to verify if deviations are within a certain threshold. -->

## LICENSE

The SQL used in this repository is licensed under a [CC-BY license](./LICENSE).

All other code in this repository is licensed under the [MIT
license](./LICENSE-CODE).
