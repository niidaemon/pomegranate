#!/usr/bin/env bash
set -euo pipefail

IMAGE="inventory-service"
CONTAINER="inventory-dev"
PORT="${PORT:-8004}"
BUILD_CTX="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

docker buildx create --use 2>/dev/null || true

docker buildx build --load \
  --platform linux/arm64 \
  --build-arg TARGETOS=linux \
  --build-arg TARGETARCH=amd64 \
  -t "${IMAGE}" "${BUILD_CTX}"

if docker ps -q -f name="${CONTAINER}" >/dev/null; then
  docker rm -f "${CONTAINER}"
fi

docker run -d --name "${CONTAINER}" -p "${PORT}":"${PORT}" "${IMAGE}"

echo -n "Waiting for service on http://localhost:${PORT}/health"

for i in {1..30}; do
  if curl -fs "http://localhost:${PORT}/health" >/dev/null 2>&1; then
    echo
    echo "Service healthy"
    echo "Test: curl http://localhost:${PORT}/health"
    exit 0
  fi
  printf "."
  sleep 1
done

echo
echo "Service did not start; container logs:"
docker logs "${CONTAINER}" --tail 200
exit 1
