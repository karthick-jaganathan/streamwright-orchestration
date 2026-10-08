#!/usr/bin/env bash
# Builds the pipeline image (streamwright from PyPI + its pinned ad and reader connectors) from the repository root:
#   bash docker/build.sh            # -> streamwright-pipeline:local (or $STREAMWRIGHT_IMAGE)
#   bash docker/build.sh --no-cache # extra arguments go to docker build
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image="${STREAMWRIGHT_IMAGE:-streamwright-pipeline:local}"

cd "$repo_root"
DOCKER_BUILDKIT=1 docker build -t "$image" -f docker/Dockerfile "$@" .
docker image ls "$image" --format 'built {{.Repository}}:{{.Tag}} ({{.Size}})'
