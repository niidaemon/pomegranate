#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-orders-service}"
CONTAINER_NAME="${CONTAINER_NAME:-orders-dev}"
SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT="${PORT:-8007}"                    
CONTAINER_PORT="${CONTAINER_PORT:-$PORT}"
HEALTH_PATH="${HEALTH_PATH:-/actuator/health}"  
RETRIES="${RETRIES:-30}"
SLEEP="${SLEEP:-1}"

dump_logs() {
  echo
  echo "===== container logs (tail 200) ====="
  docker logs "$CONTAINER_NAME" --tail 200 || true
  echo "====================================="
}

if [ -n "$(docker ps -aq -f name="^${CONTAINER_NAME}$")" ]; then
  echo "Removing existing container: $CONTAINER_NAME"
  docker rm -f "$CONTAINER_NAME" >/dev/null || true
fi

echo "Building image '$IMAGE_NAME' from $SERVICE_DIR"
docker build -t "$IMAGE_NAME" "$SERVICE_DIR"

echo "Starting container '$CONTAINER_NAME' mapping host:$PORT -> container:$CONTAINER_PORT"
docker run -d \
  --name "$CONTAINER_NAME" \
  -p "$PORT":"$CONTAINER_PORT" \
  -e "PORT=$CONTAINER_PORT" \
  "$IMAGE_NAME"

echo -n "Waiting for service on http://localhost:$PORT$HEALTH_PATH"
i=0
while ! curl -fs "http://localhost:$PORT$HEALTH_PATH" >/dev/null 2>&1; do
  i=$((i+1))
  if [ $i -ge "$RETRIES" ]; then
    echo
    echo "ERROR: service did not become healthy after $((RETRIES*SLEEP))s"
    dump_logs
    exit 1
  fi
  printf "."
  sleep "$SLEEP"
done
echo
echo "Service healthy. Running smoke tests..."

echo
echo "GET $HEALTH_PATH"
curl -fsS "http://localhost:$PORT$HEALTH_PATH" || true
echo

echo "GET / (root)"
curl -fsS "http://localhost:$PORT/" || true
echo

echo
echo "✅ Java service is up at http://localhost:$PORT"
echo "To follow logs: docker logs -f $CONTAINER_NAME"
echo "To stop and remove: docker rm -f $CONTAINER_NAME"