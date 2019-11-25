#!/bin/bash
set -eu

docker pull hadolint/hadolint:v1.17.3

echo "now linting: Dockerfile"
docker run --rm -i hadolint/hadolint:v1.3.0 hadolint --ignore DL3006 - < "$(pwd)/jackett/Dockerfile"
echo "-------"