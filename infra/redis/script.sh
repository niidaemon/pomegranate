#!/usr/bin/env bash
set -e

IMAGE_NAME="pomegranate-redis"
CONTAINER_NAME="redistest"
CONFIG_FILE="redis.conf"

if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
  echo "Stopping and removing existing container: $CONTAINER_NAME"
  docker rm -f $CONTAINER_NAME
fi

echo "Building Redis image..."
docker build -t $IMAGE_NAME .

echo "Starting Redis container..."
docker run -d \
  --name $CONTAINER_NAME \
  -p 6379:6379 \
  $IMAGE_NAME

echo "Redis is running in container: $CONTAINER_NAME"
echo "Test with: docker exec -it $CONTAINER_NAME redis-cli ping"
echo "Stop with: docker stop $CONTAINER_NAME"
echo "Remove with: docker rm -f $CONTAINER_NAME"
