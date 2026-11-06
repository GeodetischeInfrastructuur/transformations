# PROJ_VERSION and TRANSFORMATIONS_VERSION are deliberately required build args;
# their source of truth is the root Dockerfile, not duplicated defaults here.
# Build context: Must be run from repository root with:
#   docker build . -f pyproj/Dockerfile [--build-arg ...]
# This allows COPY to access both pyproj/ and validation/ directories.
#
ARG PYTHON_VERSION=3.15
ARG PYPROJ_VERSION=3.7.2
ARG PROJ_VERSION
ARG TRANSFORMATIONS_VERSION
ARG TRANSFORMATIONS_PRERELEASE_SUFFIX=
ARG TRANSFORMATION_IMAGE_SOURCE=ghcr.io/geodetischeinfrastructuur/
ARG TRANSFORMATION_IMAGE_TAG=${TRANSFORMATIONS_VERSION}${TRANSFORMATIONS_PRERELEASE_SUFFIX}-proj${PROJ_VERSION}
# PYPROJ_VERSION is managed here (source of truth for the Python wrapper).
# PROJ_VERSION and TRANSFORMATIONS_VERSION must be supplied by the build caller; TRANSFORMATIONS_VERSION is sourced from the root Dockerfile.
# this image is versioned by pyproj: PYPROJ_VERSION-nsgiTRANSFORMATIONS_VERSION (e.g. 3.7.2-nsgi2.0.0)

FROM osgeo/proj:${PROJ_VERSION} AS proj-source
# download nl_nsgi grids from cdn.proj.org so the pyproj image works out of the box
RUN mkdir /nlnsgi-grids && projsync --source-id nl_nsgi --target-dir /nlnsgi-grids

FROM ${TRANSFORMATION_IMAGE_SOURCE}transformations:${TRANSFORMATION_IMAGE_TAG} AS transformations

# uv doesn't have a noble variant, so copy just the uv binary from the uv image
FROM ghcr.io/astral-sh/uv:latest AS uv-source

# manylinux_2_28 (AlmaLinux 8, glibc 2.28): wheels built here run on glibc >= 2.28
FROM quay.io/pypa/manylinux_2_28_x86_64

ARG PYTHON_VERSION
ARG PROJ_VERSION
WORKDIR /app

COPY --from=uv-source /uv /uvx /usr/local/bin/

# build PROJ from source: libcurl-minimal keeps TLS via OpenSSL without LDAP/SSH/libpsl,
# and libstdc++/libgcc are linked statically so libproj needs no GLIBCXX symbols from the host
RUN yum -y swap libcurl libcurl-minimal \
    && yum install -y curl sqlite sqlite-devel libtiff-devel libcurl-devel openssl-devel \
    && yum clean all
RUN curl -fsSL "https://download.osgeo.org/proj/proj-${PROJ_VERSION}.tar.gz" | tar -xz -C /tmp \
    && cmake -S "/tmp/proj-${PROJ_VERSION}" -B /tmp/proj-build \
       -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_INSTALL_LIBDIR=lib \
       -DBUILD_TESTING=OFF -DBUILD_APPS=OFF -DENABLE_CURL=ON -DENABLE_TIFF=ON \
       -DCMAKE_SHARED_LINKER_FLAGS="-static-libstdc++ -static-libgcc" \
    && cmake --build /tmp/proj-build -j"$(nproc)" \
    && cmake --install /tmp/proj-build \
    && rm -rf /tmp/proj-* \
    && echo /usr/local/lib > /etc/ld.so.conf.d/proj.conf && ldconfig

# No system python is installed: the interpreter is provided by uv (see UV_PYTHON),
# so one Dockerfile builds for any CPython 3.12-3.15.

# Pin the interpreter for every uv/uvx call (uv sync here and `uvx pip wheel` in
# build-wheel.sh) so the compiled extension — and thus the wheel's ABI tag
# (cp312/cp313/cp314/cp315) — matches PYTHON_VERSION.
ENV UV_PYTHON=${PYTHON_VERSION}
RUN uv python install "${PYTHON_VERSION}"

COPY pyproj/pyproject.toml pyproj/uv.lock ./
COPY validation/ ./validation/
# compile pyproj from source against the selected PROJ version
RUN PROJ_DIR=/usr/local PROJ_VERSION="${PROJ_VERSION}" uv sync --no-binary-package pyproj

# copy NSGI proj data into pyproj's internal data dir so pyproj picks it up automatically
# (pyproj checks <package>/proj_dir/share/proj before any env var or system path)
COPY --from=transformations /usr/share/proj/ /app/.venv/lib/python${PYTHON_VERSION}/site-packages/pyproj/proj_dir/share/proj/
# copy nl_nsgi grids so the image works out of the box without PROJ_NETWORK=ON
COPY --from=proj-source /nlnsgi-grids/ /app/.venv/lib/python${PYTHON_VERSION}/site-packages/pyproj/proj_dir/share/proj/

ENV PATH="/app/.venv/bin:$PATH"

ARG PYPROJ_VERSION
ARG TRANSFORMATIONS_VERSION
ARG TRANSFORMATIONS_PRERELEASE_SUFFIX
LABEL org.opencontainers.image.version="${PYPROJ_VERSION}-nsgi${TRANSFORMATIONS_VERSION}${TRANSFORMATIONS_PRERELEASE_SUFFIX}" \
    org.opencontainers.image.description="pyproj ${PYPROJ_VERSION} with NSGI transformations ${TRANSFORMATIONS_VERSION}${TRANSFORMATIONS_PRERELEASE_SUFFIX} compiled against PROJ ${PROJ_VERSION}"
