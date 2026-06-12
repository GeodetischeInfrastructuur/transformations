ARG PROJ_VERSION=9.7.1
ARG POST_PATCH=1
# image tag follows PROJ_VERSION-postPOST_PATCH (e.g. 9.7.1-post1)
# bump POST_PATCH for config-only changes; bump PROJ_VERSION and reset POST_PATCH=1 for PROJ updates

FROM osgeo/proj:${PROJ_VERSION}
ARG PROJ_VERSION
ARG POST_PATCH
LABEL org.opencontainers.image.version="${PROJ_VERSION}-post${POST_PATCH}" \
    org.opencontainers.image.description="PROJ ${PROJ_VERSION} with NSGI transformations (post${POST_PATCH})"
RUN apt-get -y update &&  \
    apt-get install --no-install-recommends -y \
    sqlite3 && \
    rm -rf /var/lib/apt/lists/*
COPY sql /sql
COPY grids/nl_nsgi/ /grids
COPY configure-proj.sh /configure-proj.sh
RUN /configure-proj.sh /usr/share/proj /sql /grids
