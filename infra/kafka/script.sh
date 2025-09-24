#!/usr/bin/env bash
set -e

IMAGE_NAME="pomegranate-kafka"
CONTAINER_NAME="kafkatest"
CLUSTER_ID="kraft-cluster-$(uuidgen | cut -d'-' -f1)"

if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
  echo "Stopping and removing existing container: $CONTAINER_NAME"
  docker rm -f $CONTAINER_NAME
fi

echo "Building Kafka image from apache/kafka:latest..."
docker build -t $IMAGE_NAME .

echo "Starting Kafka container in KRaft mode..."
docker run -d \
  --name $CONTAINER_NAME \
  -p 9092:9092 \
  -p 9093:9093 \
  -e KAFKA_PROCESS_ROLES=broker,controller \
  -e KAFKA_NODE_ID=1 \
  -e KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:9093 \
  -e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093 \
  -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 \
  -e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER \
  -e KAFKA_LOG_DIRS=/tmp/kraft-combined-logs \
  -e KAFKA_CLUSTER_ID=$CLUSTER_ID \
  $IMAGE_NAME

echo "Kafka is running in container: $CONTAINER_NAME"
echo "Test with: docker exec --workdir /opt/kafka/bin/ -it broker sh"
echo "Stop with: docker rm -f $CONTAINER_NAME"
