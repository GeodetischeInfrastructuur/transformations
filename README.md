# Transformations

[![GitHub
license](https://img.shields.io/github/license/GeodetischeInfrastructuur/Transformations)](https://github.com/GeodetischeInfrastructuur/Transformations/blob/master/LICENSE) [![Static Badge](https://img.shields.io/badge/%20ghcr.io-geodetischeinfrastructuur%2Ftransformations-green?)](https://ghcr.io/geodetischeinfrastructuur/transformations) [![GitHub Release](https://img.shields.io/github/v/release/GeodetischeInfrastructuur/transformations)](https://github.com/GeodetischeInfrastructuur/transformations/releases) [![PROJ](https://img.shields.io/badge/PROJ-9.5.0-blue)](https://proj.org/) [![pyproj](https://img.shields.io/badge/pyproj-3.7.0-blue)](https://pyproj4.github.io/pyproj/)

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

## Integration

There are two ways to use the NSGI-configured PROJ in your own environment.

### 1. Use the Docker image directly

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

### 2. Copy the proj data directory into your Python environment

`pyproj` bundles its own PROJ library and data directory. To use the NSGI-configured `proj.db` and grids, copy the full `/usr/share/proj/` from the Docker image into pyproj's data directory.

This works for:

- **Local Python environments** (virtualenv, conda, uv)
- **QGIS** (replace the proj data dir used by QGIS's bundled PROJ)
- **Python Docker containers** (see [`validate/Dockerfile`](validate/Dockerfile) for a working example)

**Locally:**

```bash
id=$(docker create ghcr.io/geodetischeinfrastructuur/transformations:latest)
docker cp "$id:/usr/share/proj/." "$(python -c 'import pyproj;print(pyproj.datadir.get_data_dir())')"
docker rm "$id"
```

**In a Dockerfile** (multi-stage, copies into pyproj's bundled data dir):

```dockerfile
FROM ghcr.io/geodetischeinfrastructuur/transformations:latest AS transformations

FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim
ARG PYTHON_VERSION=3.12
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync
COPY --from=transformations /usr/share/proj/ \
     "/app/.venv/lib/python${PYTHON_VERSION}/site-packages/pyproj/proj_dir/share/proj"
ENV PATH="/app/.venv/bin:$PATH"
```

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

## Validation

### Manual validation transformations

To verify that NSGI transformations are correctly installed in the local PROJ environment, you can use the `cs2cs` command to transform coordinates:

```bash
docker build -t transformations .
docker run --rm transformations sh -c 'echo "52.115330444 7.684748554 41.4160" | cs2cs -f "%.4f" EPSG:7931 EPSG:7415'
```

Expected output:

```txt
312352.6004 461058.5812 -2.5206
```

### Manual validation transformation-validate pyproj

To verify that NSGI transformations are correcly installed in pyproj environment run the following docker/python command:

```bash
docker build -t transformations-validate ./validate
docker run --rm transformations-validate python -c '
from pyproj import transformer
etrf = transformer.TransformerGroup("EPSG:7931", "EPSG:7415")
result = etrf.transformers[0].transform(52.115330444, 7.684748554, 41.4160)
print("{0[0]:.4f} {0[1]:.4f} {0[2]:.4f}".format(result))
'
```

Expected output:

```txt
312352.6004 461058.5812 -2.5206
```

### Validate transformation accuracy with NSGI validation service

Use the official [NSGI validation service](https://www.nsgi.nl/coordinatenstelsels-en-transformaties/tools/validatieservice) to verify transformation accuracy. The service tests transformations between EPSG:7931 (ETRS89) and EPSG:7415 (RDNAP) and returns an accuracy score. The transformation direction is determined automatically based on feature IDs in the input dataset:

| first feature fid | source crs | target crs |
| :--- | :--- | :--- |
| 20020000 | EPSG:7931 | EPSG:7415 |
| 10020000 | EPSG:7415 | EPSG:7931 |

Download the test datasets, transform them with this tool, and upload the results:

```sh
docker build -t transformations-validate ./validate
(
    cd validate
    curl -o 002_RDNAP.txt 'https://www.nsgi.nl/documents/1888506/1945213/002_RDNAP.txt/5d6dc6b8-a59d-40d0-0363-8a9b59e51c62?t=1574879689583'
    curl -o 002_ETRS89.txt 'https://www.nsgi.nl/documents/1888506/1944539/002_ETRS89.txt/6aa954da-d345-de97-386a-4fbd956edf52?t=1574879755720'
)

docker run -v $(pwd)/validate:/data \
  transformations-validate \
  transform-csv /data/002_ETRS89.txt /data/002_ETRS89_transformed.txt

docker run -v $(pwd)/validate:/data \
  transformations-validate \
  python transform-csv /data/002_RDNAP.txt /data/002_RDNAP_transformed.txt
```

Upload the generated files to the [validation service](https://www.nsgi.nl/coordinatenstelsels-en-transformaties/tools/validatieservice). The score must be 100% for *Netherlands+EEZ*.

### Validate transformation accuracy with reference coordinates

Validate transformation accuracy against reference coordinates. The file `Z001_ETRS89andRDNAP.txt` contains verified coordinate pairs in both ETRS89 and RDNAP. The script transforms each set and calculates deviation from the known values—measuring transformation accuracy.

```bash
docker run -v $(pwd)/validate/data:/data transformations-validate python validate.py /data/Z001_ETRS89andRDNAP.txt /data/Z001_ETRS89andRDNAP_transformed.csv
```

This outputs `validate/data/Z001_ETRS89andRDNAP_transformed.csv` file. If correct, the transformed coordinates will have minimal deviation from the known coordinates.

<!-- TODO: add check to verify if deviations are within a certain threshold. -->

## LICENSE

The SQL used in this repository is licensed under a [CC-BY license](./LICENSE).

All other code in this repository is licensed under the [MIT
license](./LICENSE-CODE).
