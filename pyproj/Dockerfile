# Build context: Must be run from repository root with:
#   docker build . -f pyproj/Dockerfile [--build-arg ...]
# This allows COPY to access both pyproj/ and validation/ directories.
#
ARG PYTHON_VERSION=3.12
ARG PYPROJ_VERSION=3.7.2
ARG PROJ_VERSION=9.7.1
ARG TRANSFORMATIONS_VERSION=2.0.0
ARG TRANSFORMATIONS_PRERELEASE_SUFFIX=
ARG TRANSFORMATION_IMAGE_SOURCE=ghcr.io/geodetischeinfrastructuur/
ARG TRANSFORMATION_IMAGE_TAG=${TRANSFORMATIONS_VERSION}${TRANSFORMATIONS_PRERELEASE_SUFFIX}-proj${PROJ_VERSION}
# PYPROJ_VERSION is managed here (source of truth for the Python wrapper).
# PROJ_VERSION and TRANSFORMATIONS_VERSION must be passed by the release workflow or via --build-arg from the root Dockerfile.
# this image is versioned by pyproj: PYPROJ_VERSION-nsgiTRANSFORMATIONS_VERSION (e.g. 3.7.2-nsgi2.0.0)

FROM osgeo/proj:${PROJ_VERSION} AS proj-source
# download nl_nsgi grids from cdn.proj.org so the pyproj image works out of the box
RUN mkdir /nlnsgi-grids && projsync --source-id nl_nsgi --target-dir /nlnsgi-grids

FROM ${TRANSFORMATION_IMAGE_SOURCE}transformations:${TRANSFORMATION_IMAGE_TAG} AS transformations

# uv doesn't have a noble variant, so copy just the uv binary from the uv image
FROM ghcr.io/astral-sh/uv:latest AS uv-source

# use Ubuntu 24.04 (noble) to match osgeo/proj:9.7.1 base OS and glibc version
FROM ubuntu:24.04

ARG PYTHON_VERSION
WORKDIR /app

COPY --from=uv-source /uv /uvx /usr/local/bin/

# copy PROJ 9.7.1 libraries and headers so pyproj can be compiled from source against it
COPY --from=proj-source /usr/lib/x86_64-linux-gnu/libproj.so.25 /usr/lib/x86_64-linux-gnu/
COPY --from=proj-source /usr/lib/x86_64-linux-gnu/libproj.so.25.9.7.1 /usr/lib/x86_64-linux-gnu/
COPY --from=proj-source /usr/lib/x86_64-linux-gnu/libproj.so /usr/lib/x86_64-linux-gnu/
COPY --from=proj-source /usr/include/*.h /usr/include/
COPY --from=proj-source /usr/include/proj/ /usr/include/proj/

# install gcc + patchelf (build tools) and all runtime dependencies of libproj
# (sqlite3, tiff, curl+TLS chain). ca-certificates lets uv download the managed
# CPython build over TLS. No system python is installed — the interpreter is
# provided by uv (see UV_PYTHON), so one Dockerfile builds for any CPython 3.12-3.15.
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libc6-dev \
    patchelf \
    ca-certificates \
    libsqlite3-0 \
    libtiff6 \
    libcurl3t64-gnutls \
    && rm -rf /var/lib/apt/lists/*

# Pin the interpreter for every uv/uvx call (uv sync here and `uvx pip wheel` in
# build-wheel.sh) so the compiled extension — and thus the wheel's ABI tag
# (cp312/cp313/cp314/cp315) — matches PYTHON_VERSION.
ENV UV_PYTHON=${PYTHON_VERSION}
RUN uv python install "${PYTHON_VERSION}"

COPY pyproj/pyproject.toml pyproj/uv.lock ./
COPY validation/ ./validation/
# compile pyproj from source against PROJ 9.7.1; PROJ_DIR and PROJ_VERSION avoid needing the proj binary at build time
RUN PROJ_DIR=/usr PROJ_VERSION=9.7.1 uv sync --no-binary-package pyproj

# copy NSGI proj data into pyproj's internal data dir so pyproj picks it up automatically
# (pyproj checks <package>/proj_dir/share/proj before any env var or system path)
COPY --from=transformations /usr/share/proj/ /app/.venv/lib/python${PYTHON_VERSION}/site-packages/pyproj/proj_dir/share/proj/
# copy nl_nsgi grids so the image works out of the box without PROJ_NETWORK=ON
COPY --from=proj-source /nlnsgi-grids/ /app/.venv/lib/python${PYTHON_VERSION}/site-packages/pyproj/proj_dir/share/proj/

ENV PATH="/app/.venv/bin:$PATH"

ARG PYPROJ_VERSION
ARG PROJ_VERSION
ARG TRANSFORMATIONS_VERSION
ARG TRANSFORMATIONS_PRERELEASE_SUFFIX
LABEL org.opencontainers.image.version="${PYPROJ_VERSION}-nsgi${TRANSFORMATIONS_VERSION}${TRANSFORMATIONS_PRERELEASE_SUFFIX}" \
    org.opencontainers.image.description="pyproj ${PYPROJ_VERSION} with NSGI transformations ${TRANSFORMATIONS_VERSION}${TRANSFORMATIONS_PRERELEASE_SUFFIX} compiled against PROJ ${PROJ_VERSION}"
