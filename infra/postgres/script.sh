#!/usr/bin/env bash
set -e

IMAGE_NAME="pomegranate-postgres"
CONTAINER_NAME="pgtest"

# Stop and remove any existing container with the same name
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "Stopping and removing existing container: $CONTAINER_NAME"
    docker rm -f $CONTAINER_NAME
fi

# Build the image
echo "Building Postgres image..."
docker build -t $IMAGE_NAME . 

# Run the container
echo "Starting Postgres container..."
docker run -d \
    --name $CONTAINER_NAME \
    -p 5432:5432 \
    -e POSTGRES_USER=dev \
    -e POSTGRES_PASSWORD=pass \
    -e POSTGRES_DB=devdb \
    $IMAGE_NAME

echo "Postgres is running in container: $CONTAINER_NAME"
echo "Connect with: docker exec -it pgtest psql -U dev -d devdb"
echo "Stop with: docker stop $CONTAINER_NAME"
echo "Remove with: docker rm -f $CONTAINER_NAME"