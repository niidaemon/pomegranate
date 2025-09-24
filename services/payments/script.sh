#!/usr/bin/env bash
set -e

IMAGE_NAME="payment-service"
CONTAINER_NAME="payment-dev"
PORT=8005

if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
  echo "Stopping and removing existing container: $CONTAINER_NAME"
  docker rm -f $CONTAINER_NAME
fi

echo "Building Payment Service image..."
docker build -t $IMAGE_NAME .

echo "Starting Payment Service container..."
docker run -d \
  --name $CONTAINER_NAME \
  -p $PORT:$PORT \
  $IMAGE_NAME

echo "✅ Payment Service is running at: http://localhost:$PORT"
echo "Test with: curl -X GET http://localhost:$PORT/docs"
echo "Stop with: docker rm -f $CONTAINER_NAME"
