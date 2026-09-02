#!/usr/bin/env bash
# ===========================================================================
# Build the custom Decision Environment image
# ===========================================================================
# Usage:
#   ./build.sh                                    # use defaults
#   ./build.sh quay.myorg.com/eda/custom-de:v1    # custom tag
#
# Prerequisites:
#   - ansible-builder installed (pip install ansible-builder)
#   - podman installed
# ===========================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_TAG="quay.example.com/eda/custom-de:latest"
IMAGE_TAG="${1:-$DEFAULT_TAG}"
CONTAINER_RUNTIME="podman"

echo "============================================"
echo " Building Decision Environment"
echo " Tag: ${IMAGE_TAG}"
echo " Runtime: ${CONTAINER_RUNTIME}"
echo "============================================"

cd "${SCRIPT_DIR}"

ansible-builder build \
  --file execution-environment.yml \
  --tag "${IMAGE_TAG}" \
  --container-runtime "${CONTAINER_RUNTIME}" \
  --verbosity 2

echo ""
echo "============================================"
echo " Build complete!"
echo " Image: ${IMAGE_TAG}"
echo "============================================"
echo ""
echo "Next steps:"
echo "  ${CONTAINER_RUNTIME} push ${IMAGE_TAG}"
echo "  Then register the image in EDA Controller → Decision Environments"
