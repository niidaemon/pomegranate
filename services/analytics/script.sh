#!/usr/bin/env bash
set -e

IMAGE_NAME="analytics-service"
CONTAINER_NAME="analytics-dev"
PORT=8002

if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
  echo "Stopping and removing existing container: $CONTAINER_NAME"
  docker rm -f $CONTAINER_NAME
fi

echo "Building Analytics Service image..."
docker build -t $IMAGE_NAME .

echo "Starting Analytics Service container..."
docker run -d \
  --name $CONTAINER_NAME \
  -p $PORT:$PORT \
  $IMAGE_NAME

echo "✅ Payment Service is running at: http://localhost:$PORT"
echo "Test with: curl -X GET http://localhost:$PORT/docs"
echo "Stop with: docker rm -f $CONTAINER_NAME"