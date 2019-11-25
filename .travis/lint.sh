#!/bin/bash
set -eu

echo "now linting: Dockerfile"
docker run --rm -i hadolint/hadolint:v1.3.0 hadolint --ignore DL3006 - "$(pwd)/jackett/Dockerfile"
echo "-------"