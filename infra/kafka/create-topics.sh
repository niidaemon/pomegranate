#!/bin/bash
# create-topics.sh

BROKERS="kafka-1:9092,kafka-2:9093,kafka-3:9094"
PARTITIONS=3
REPLICATION_FACTOR=3
MIN_INSYNC_REPLICAS=2

# Function to create topic
create_topic() {
  local topic=$1
  local retention=${2:-168}  # Default 7 days
  
  docker exec kafka-1 kafka-topics --create \
    --bootstrap-server $BROKERS \
    --topic $topic \
    --partitions $PARTITIONS \
    --replication-factor $REPLICATION_FACTOR \
    --config min.insync.replicas=$MIN_INSYNC_REPLICAS \
    --config retention.ms=$((retention * 3600000)) \
    --config compression.type=producer \
    --config max.message.bytes=1048576 \
    --if-not-exists
  
  echo "✅ Created topic: $topic"
}

# Create all topics
echo "Creating Kafka topics..."

create_topic "order-events" 168        # 7 days
create_topic "payment-events" 168      # 7 days
create_topic "inventory-events" 168    # 7 days
create_topic "user-events" 720         # 30 days (audit)
create_topic "notification-events" 72  # 3 days

# Dead Letter Queue topics
create_topic "order-events-dlq" 720
create_topic "payment-events-dlq" 720
create_topic "inventory-events-dlq" 720
create_topic "user-events-dlq" 720
create_topic "notification-events-dlq" 720

echo "✅ All topics created successfully"