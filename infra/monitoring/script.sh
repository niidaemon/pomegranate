#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROM_PATH="$SCRIPT_DIR/prometheus"
GRAF_PATH="$SCRIPT_DIR/grafana"

PROM_IMAGE="pomegranate-prometheus"
GRAF_IMAGE="pomegranate-grafana"
PROM_CONTAINER="prometheus-dev"
GRAF_CONTAINER="grafana-dev"

for name in $PROM_CONTAINER $GRAF_CONTAINER; do
  if [ "$(docker ps -aq -f name=$name)" ]; then
    echo "Stopping and removing existing container: $name"
    docker rm -f $name
  fi
done

echo "Building Prometheus image..."
docker build -t $PROM_IMAGE "$PROM_PATH"

echo "Building Grafana image..."
docker build -t $GRAF_IMAGE "$GRAF_PATH"

echo "Starting Prometheus..."
docker run -d \
  --name $PROM_CONTAINER \
  -p 9090:9090 \
  -v "$(pwd)/prometheus:/etc/prometheus" \
  $PROM_IMAGE

echo "Starting Grafana..."
docker run -d \
  --name $GRAF_CONTAINER \
  -p 3000:3000 \
  $GRAF_IMAGE

echo "✅ Prometheus is running at: http://localhost:9090"
echo "✅ Grafana is running at: http://localhost:3000"
echo "Test Prometheus with: curl http://localhost:9090/api/v1/status/buildinfo"
echo "Stop with: docker rm -f $PROM_CONTAINER $GRAF_CONTAINER"
