#!/usr/bin/env bash
set -e

IMAGE_NAME="pomegranate-traefik"
CONTAINER_NAME="traefik-dev"
CONFIG_FILE="traefik.yml"

if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
  echo "Stopping and removing existing container: $CONTAINER_NAME"
  docker rm -f $CONTAINER_NAME
fi

echo "Building Traefik image..."
docker build -t $IMAGE_NAME .

echo "Starting Traefik container..."
docker run -d \
  --name $CONTAINER_NAME \
  -p 80:80 \
  -p 443:443 \
  -p 8080:8080 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$(pwd)/$CONFIG_FILE:/etc/traefik/traefik.yml" \
  $IMAGE_NAME

echo "Traefik is running in container: $CONTAINER_NAME"
echo "Dashboard available at: http://localhost:8080/dashboard/"
echo "Stop with:   docker stop $CONTAINER_NAME"
echo "Remove with: docker rm -f $CONTAINER_NAME"
