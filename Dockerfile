ARG PROJ_VERSION=9.7.1
ARG TRANSFORMATIONS_VERSION=2.0.0
ARG TRANSFORMATIONS_PRERELEASE_SUFFIX=
# PROJ_VERSION pins the libproj line; TRANSFORMATIONS_VERSION is the NSGI config
# semver (source of truth for both images). For local builds these defaults are
# used. The release workflow reads them here and passes them to pyproj/Dockerfile
# via --build-arg.
# release tag follows TRANSFORMATIONS_VERSION[-rcN]-projPROJ_VERSION

FROM osgeo/proj:${PROJ_VERSION}
ARG PROJ_VERSION
ARG TRANSFORMATIONS_VERSION
ARG TRANSFORMATIONS_PRERELEASE_SUFFIX
LABEL org.opencontainers.image.version="${TRANSFORMATIONS_VERSION}${TRANSFORMATIONS_PRERELEASE_SUFFIX}-proj${PROJ_VERSION}" \
    org.opencontainers.image.description="PROJ ${PROJ_VERSION} with NSGI transformations ${TRANSFORMATIONS_VERSION}${TRANSFORMATIONS_PRERELEASE_SUFFIX}"
RUN apt-get -y update &&  \
    apt-get install --no-install-recommends -y \
    sqlite3 && \
    rm -rf /var/lib/apt/lists/*
COPY sql /sql
COPY configure-proj.sh /configure-proj.sh
RUN /configure-proj.sh /usr/share/proj /sql
# Configure PROJ CDN endpoint so network-based grid downloads work
RUN printf '[projnetwork]\nendpoint=https://cdn.proj.org\n' > /usr/share/proj/proj.ini
