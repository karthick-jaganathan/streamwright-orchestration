# syntax=docker/dockerfile:1
#
# streamwright-pipeline:local - the streamwright CLI with the AD connectors (google_ads + its gaql query builder,
# microsoft_ads, meta_ads) and the READER connectors (files, s3, gcs, postgres), so one image can run any network of
# the pipeline (config/networks.yaml `image:`). With STREAMWRIGHT_EXECUTION=docker each pipeline node runs
#   docker run --rm streamwright-pipeline:local run /app/sources/<source> --stream <node> ...
#
# Build from the repository root (the build context; Dockerfile.dockerignore next to this file keeps it small):
#   bash docker/build.sh
# See docker/README.md. The ad SDKs (google-ads, bingads, facebook_business) are heavy: the build takes a few
# minutes and the image is large.

FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_ROOT_USER_ACTION=ignore

# streamwright from PyPI; the connectors from the commits its catalog pins, in one `streamwright connectors install`
# (one pip install from GitHub - so git is installed for the build and removed in the same layer).
ARG STREAMWRIGHT_VERSION=">=0.1.4,<0.2"
ARG CONNECTORS="google_ads microsoft_ads meta_ads files s3 gcs postgres"
RUN apt-get update \
 && apt-get install -y --no-install-recommends git \
 && pip install "streamwright${STREAMWRIGHT_VERSION}" \
 && streamwright connectors install ${CONNECTORS} --yes \
 && streamwright connectors \
 && apt-get purge -y --auto-remove git \
 && rm -rf /var/lib/apt/lists/*

# A non-root runtime user. DuckDB's httpfs (s3, gcs), postgres and ducklake extensions (the DuckLake output: data on
# S3, a Postgres catalog) are installed for it now, so a --rm container or a Kubernetes Job pod never downloads them
# at run time.
RUN useradd --create-home --uid 1000 --shell /usr/sbin/nologin streamwright
USER streamwright
RUN python -c "import duckdb; c = duckdb.connect(); [c.install_extension(e) for e in ('httpfs', 'postgres', 'ducklake')]"

# The source folders at their repository-relative paths: <repo>/sources/<x> is /app/sources/<x>.
WORKDIR /app
COPY sources /app/sources

# Mount points: the user warehouses (DuckDB files) and the --summary JSON files persist on the host.
VOLUME ["/warehouse", "/runs"]

ENTRYPOINT ["streamwright"]
CMD ["--help"]
