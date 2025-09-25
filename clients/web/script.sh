#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-pomegranate-web}"
CONTAINER_NAME="${CONTAINER_NAME:-client-web}"
SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT="${PORT:-3000}"                    
CONTAINER_PORT="${CONTAINER_PORT:-80}"
RETRIES="${RETRIES:-30}"
SLEEP="${SLEEP:-2}"

dump_logs() {
  echo
  echo "===== container logs (tail 100) ====="
  docker logs "$CONTAINER_NAME" --tail 100 || true
  echo "====================================="
}

if [ -n "$(docker ps -aq -f name="^${CONTAINER_NAME}$")" ]; then
  echo "Removing existing container: $CONTAINER_NAME"
  docker rm -f "$CONTAINER_NAME" >/dev/null || true
fi

echo "Building React Vite image '$IMAGE_NAME' from $SERVICE_DIR"
echo "This may take a few minutes for the first build..."

docker build --progress=plain -t "$IMAGE_NAME" "$SERVICE_DIR"

echo "Starting container '$CONTAINER_NAME' mapping host:$PORT -> container:$CONTAINER_PORT"
docker run -d \
  --name "$CONTAINER_NAME" \
  -p "$PORT":"$CONTAINER_PORT" \
  "$IMAGE_NAME"

echo -n "Waiting for frontend on http://localhost:$PORT"
i=0
while ! curl -fs "http://localhost:$PORT" >/dev/null 2>&1; do
  i=$((i+1))
  if [ $i -ge "$RETRIES" ]; then
    echo
    echo "ERROR: Frontend did not start after $((RETRIES*SLEEP))s"
    dump_logs
    exit 1
  fi
  printf "."
  sleep "$SLEEP"
done

echo
echo "✅ Frontend is running!..."
