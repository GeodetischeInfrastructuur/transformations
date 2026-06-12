ARG PYTHON_VERSION=3.12
ARG PYPROJ_VERSION=3.7.2
ARG PROJ_VERSION
ARG POST_PATCH
ARG TRANSFORMATION_IMAGE_SOURCE=ghcr.io/geodetischeinfrastructuur/
ARG TRANSFORMATION_IMAGE_TAG=${PROJ_VERSION}-post${POST_PATCH}
# PYPROJ_VERSION is managed here (source of truth for the Python wrapper).
# PROJ_VERSION and POST_PATCH must be passed by the release workflow or via --build-arg from the root Dockerfile.
# this image is versioned by pyproj: PYPROJ_VERSION-postPOST_PATCH (e.g. 3.7.2-post1)

FROM osgeo/proj:${PROJ_VERSION} AS proj-source

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

# install Python 3.12, gcc, and all runtime dependencies of libproj (sqlite3, tiff, curl+TLS chain)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-dev \
    gcc \
    libsqlite3-0 \
    libtiff6 \
    libcurl3t64-gnutls \
    && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml uv.lock validate.py transform_csv.py .python-version ./
# compile pyproj from source against PROJ 9.7.1; PROJ_DIR and PROJ_VERSION avoid needing the proj binary at build time
RUN PROJ_DIR=/usr PROJ_VERSION=9.7.1 uv sync --no-binary-package pyproj

# copy NSGI proj data into pyproj's internal data dir so pyproj picks it up automatically
# (pyproj checks <package>/proj_dir/share/proj before any env var or system path)
COPY --from=transformations /usr/share/proj/ /app/.venv/lib/python${PYTHON_VERSION}/site-packages/pyproj/proj_dir/share/proj/

ENV PATH="/app/.venv/bin:$PATH"

ARG PYPROJ_VERSION
ARG PROJ_VERSION
ARG POST_PATCH
LABEL org.opencontainers.image.version="${PYPROJ_VERSION}-post${POST_PATCH}" \
    org.opencontainers.image.description="pyproj ${PYPROJ_VERSION} with NSGI transformations compiled against PROJ ${PROJ_VERSION} (post${POST_PATCH})"
