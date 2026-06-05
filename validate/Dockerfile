ARG PYTHON_VERSION=3.12
# supply empty build-arg to use local image
# --build-arg TRANSFORMATION_IMAGE_SOURCE=""
ARG TRANSFORMATION_IMAGE_SOURCE=ghcr.io/

FROM ${TRANSFORMATION_IMAGE_SOURCE}geodetischeinfrastructuur/transformations:latest AS transformations

FROM ghcr.io/astral-sh/uv:python${PYTHON_VERSION}-bookworm-slim

ARG PYTHON_VERSION
WORKDIR /app
COPY pyproject.toml uv.lock validate.py .python-version validate_ETRS89andRDNAP.txt ./
RUN uv sync

# COPY the transformation grids, the modified proj.db and all the other proj files, so we do not have to run configure-proj.sh
COPY --from=transformations  /usr/share/proj/ "/app/.venv/lib/python${PYTHON_VERSION}/site-packages/pyproj/proj_dir/share/proj"

ENV PATH="/app/.venv/bin:$PATH"
ENV PROJ_DATA="/app/.venv/lib/python${PYTHON_VERSION}/site-packages/pyproj/proj_dir/share/proj"
