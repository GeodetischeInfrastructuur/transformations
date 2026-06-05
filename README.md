# Transformations

[![GitHub
license](https://img.shields.io/github/license/GeodetischeInfrastructuur/Transformations)](https://github.com/GeodetischeInfrastructuur/Transformations/blob/master/LICENSE) [![Static Badge](https://img.shields.io/badge/%20ghcr.io-geodetischeinfrastructuur%2Ftransformations-green?)](https://ghcr.io/geodetischeinfrastructuur/transformations) [![GitHub Release](https://img.shields.io/github/v/release/GeodetischeInfrastructuur/transformations)](https://github.com/GeodetischeInfrastructuur/transformations/releases)

This repository contains a modified proj.db that implements the following
transformations according to the recommendations of the [NSGI](https://www.nsgi.nl/) (see image below).

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

## Docker

The [Docker image](./Dockerfile) is intended to be used as a base image, for applications that
layer on top of PROJ; for instance use it with
[pyproj](https://pyproj4.github.io/pyproj/stable/index.html), see the [`validate/Dockerfile`](validate/Dockerfile) file in this repo for an example.

The Docker image is published on the Github container registry: [ghcr.io/geodetischeinfrastructuur/transformations](https://ghcr.io/geodetischeinfrastructuur/transformations).

### Build

```bash
docker build -t geodetischeinfrastructuur/transformations:latest .
```

### Run

To start an interactive terminal inside the container run:

```bash
docker run -it --rm geodetischeinfrastructuur/transformations:latest
```

To invoke `projinfo` from your current terminal sessions run:

```bash
docker run --rm geodetischeinfrastructuur/transformations:latest projinfo
```

To verify if the NSGI transformation EPSG:7931 -> EPSG:7415 works as expected, run the following in a terminal:

```bash
docker build validate/ -t geodetischeinfrastructuur/validate-transformations:latest 
docker run --rm -it geodetischeinfrastructuur/validate-transformations:latest python
```

Then run the following Python code:

```python
from pyproj import transformer
etrf = transformer.TransformerGroup("EPSG:7931", "EPSG:7415")
"{0[0]:.4f} {0[1]:.4f} {0[2]:.4f}".format(etrf.transformers[0].transform(52.115330444, 7.684748554, 41.4160))
```

Alternatively the following [cs2cs](https://proj.org/en/stable/apps/cs2cs.html) command
can be used:

```bash
cs2cs -f "%.4f" EPSG:7931 EPSG:7415 <<< "52.115330444 7.684748554 41.4160"
```

Both should result in the following output: `'312352.6004 461058.5812 -2.5206'`

## Validation

<<<<<<< Updated upstream
Running the full validation file can be done by running the following docker run
command.

```bash
mkdir -p output # required otherwise output folder is created owned with root
docker run -u "$(id -u):$(id -g)" --rm -v $(pwd)/output:/output -t geodetischeinfrastructuur/validate-transformations:latest python /app/validate.py /app/validate_ETRS89andRDNAP.txt /output/validate-output.csv
```

Or by running the Python script directly.

```bash
cd validate/
uv sync # setuppython  environment with uv
direnv allow # only on installation, every subsequent opening of the workspace will activate the uv managed env, see "direnv config" section in this readme
../configure-proj.sh $(python -c 'import pyproj;print(pyproj.datadir.get_data_dir());') ../sql ../grids/nl_nsgi # note configure-proj.sh can only be run once since the sql commands will fail if applied multiple times
python validate.py validate_ETRS89andRDNAP.txt ../output/validate-output.csv
```

When the validation result is `OK` output (stdout) is:

```txt
validation result: OK
message: all points transformed and validated succesfully, output saved in output/validate-output.csv
```

When the validation result is `FAILED` output (stderr) is:

```txt
validation result: FAILED
message: accurate transformation of one or more points failed (242), invalid points saved in /output/validate-output.invalid.csv, all points saved in /output/validate-output.csv
```

### direnv config

Repository also contains a [`.envrc`](https://direnv.net/) config file, which automatically activates the `uv` managed
virtual environment. See the [direnv wiki](https://github.com/direnv/direnv/wiki/Python#uv) for how to set this up.
=======
Zie [validate/](validate/README.md).
>>>>>>> Stashed changes

## LICENSE

The SQL used in this repository is licensed under a [CC-BY license](./LICENSE).

All other code in this repository is licensed under the [MIT
license](./LICENSE-CODE).
