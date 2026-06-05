ARG PYTHON_VERSION=3.12
ARG TRANSFORMATION_IMAGE_SOURCE=ghcr.io/

FROM ${TRANSFORMATION_IMAGE_SOURCE}geodetischeinfrastructuur/transformations:latest AS transformations

FROM ghcr.io/astral-sh/uv:python${PYTHON_VERSION}-bookworm-slim

ARG PYTHON_VERSION
WORKDIR /app
COPY pyproject.toml uv.lock validate.py transform_csv.py .python-version ./
RUN uv sync

# copies over the full proj data_dir from transformation docker image
COPY --from=transformations /usr/share/proj/ \
     "/app/.venv/lib/python${PYTHON_VERSION}/site-packages/pyproj/proj_dir/share/proj"

ENV PATH="/app/.venv/bin:$PATH"