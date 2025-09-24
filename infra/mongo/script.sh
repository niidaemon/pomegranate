#!/usr/bin/env bash
set -e

IMAGE_NAME="pomegranate-mongo"
CONTAINER_NAME="mongotest"

if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "Stopping and removing existing container: $CONTAINER_NAME"
    docker rm -f $CONTAINER_NAME
fi

docker build -t $IMAGE_NAME . 

docker run -d \
    --name $CONTAINER_NAME \
    -p 27017:27017 \
    -e MONGO_INITDB_ROOT_USERNAME=dev \
    -e MONGO_INITDB_ROOT_PASSWORD=pass \
    -e MONGO_INITDB_DATABASE=devdb \
    $IMAGE_NAME

echo "MongoDB is running in container: $CONTAINER_NAME"
echo "Connect with: docker exec -it $CONTAINER_NAME mongosh -u dev -p pass --authenticationDatabase admin devdb"
echo "Stop with: docker stop $CONTAINER_NAME"
echo "Remove with: docker rm -f $CONTAINER_NAME"