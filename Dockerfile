ARG PROJ_VERSION=9.7.1
ARG POST_PATCH=1
# These manage the PROJ version and NSGI config patch level (source of truth for both images).
# For local builds, these defaults will be used. The release workflow reads them here and
# passes them to pyproj/Dockerfile via --build-arg.
# image tag follows PROJ_VERSION-postPOST_PATCH (e.g. 9.7.1-post1)

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
