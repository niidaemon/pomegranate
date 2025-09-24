db = db.getSiblingDB("pomegranate-mongo");

db.createCollection("deliveries", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["order_id", "user_id", "status", "created_at"],
      properties: {
        order_id: { bsonType: "string" },
        user_id: { bsonType: "string" },
        rider_id: { bsonType: ["string", "null"] },
        carrier: { bsonType: ["string", "null"] },
        tracking_number: { bsonType: ["string", "null"] },
        status: { 
          enum: ["PENDING", "ASSIGNED", "PICKED_UP", "EN_ROUTE", "NEARBY", "DELIVERED", "FAILED", "CANCELLED"] 
        },
        eta: { bsonType: ["date", "null"] },
        // Geo snapshot of most recent location (GeoJSON Point)
        current_location: {
          bsonType: ["object", "null"],
          properties: {
            type: { enum: ["Point"] },
            coordinates: { 
              bsonType: "array",
              minItems: 2,
              maxItems: 2,
              items: { bsonType: "double" }
            }
          },
          additionalProperties: false
        },
        // events array: timeline of status/location changes
        events: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["status", "timestamp"],
            properties: {
              status: { bsonType: "string" },
              location: {
                bsonType: ["object", "null"],
                properties: {
                  type: { enum: ["Point"] },
                  coordinates: { 
                    bsonType: "array",
                    minItems: 2,
                    maxItems: 2,
                    items: { bsonType: "double" }
                  }
                },
                additionalProperties: false
              },
              note: { bsonType: ["string", "null"] },
              timestamp: { bsonType: "date" }
            },
            additionalProperties: false
          }
        },
        created_at: { bsonType: "date" },
        last_updated: { bsonType: "date" },
        meta: { bsonType: ["object", "null"] }
      },
      additionalProperties: false
    }
  }
});

db.deliveries.createIndex({ order_id: 1 }, { unique: true });
db.deliveries.createIndex({ user_id: 1, status: 1 });
db.deliveries.createIndex({ rider_id: 1, status: 1 });
db.deliveries.createIndex({ "current_location": "2dsphere" });
db.deliveries.createIndex({ last_updated: -1 });

db.createCollection("rider_locations", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["rider_id", "timestamp", "location"],
      properties: {
        rider_id: { bsonType: "string" },
        delivery_id: { bsonType: ["objectId", "string", "null"] },
        location: {
          bsonType: "object",
          required: ["type", "coordinates"],
          properties: {
            type: { enum: ["Point"] },
            coordinates: { 
              bsonType: "array",
              minItems: 2,
              maxItems: 2,
              items: { bsonType: "double" }
            }
          },
          additionalProperties: false
        },
        speed: { bsonType: ["double", "null"] },
        heading: { bsonType: ["double", "null"] },
        battery: { bsonType: ["int", "null"] },
        timestamp: { bsonType: "date" },
        event_id: { bsonType: ["string", "null"] }
      },
      additionalProperties: false
    }
  }
});

db.rider_locations.createIndex({ rider_id: 1, timestamp: -1 });
db.rider_locations.createIndex({ "location": "2dsphere" });
db.rider_locations.createIndex({ timestamp: 1 }, { expireAfterSeconds: 604800 }); // 7 days TTL
// Optional unique index for idempotency on event_id
db.rider_locations.createIndex(
  { event_id: 1 }, 
  { 
    unique: true, 
    partialFilterExpression: { event_id: { $exists: true } }
  }
);

db.createCollection("delivery_notifications", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["delivery_id", "user_id", "channel", "event", "created_at"],
      properties: {
        delivery_id: { bsonType: "string" },
        user_id: { bsonType: "string" },
        channel: { enum: ["SMS", "EMAIL", "PUSH"] },
        event: { bsonType: "string" },
        message: { bsonType: ["string", "null"] },
        status: { enum: ["QUEUED", "SENT", "FAILED", "RETRY"] },
        error: { bsonType: ["string", "null"] },
        created_at: { bsonType: "date" },
        sent_at: { bsonType: ["date", "null"] },
        retry_count: { bsonType: ["int", "null"] }
      },
      additionalProperties: false
    }
  }
});

db.delivery_notifications.createIndex({ delivery_id: 1 });
db.delivery_notifications.createIndex({ user_id: 1, status: 1 });
db.delivery_notifications.createIndex({ created_at: -1 });

db.createCollection("delivery_settings", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["user_id", "updated_at"],
      properties: {
        user_id: { bsonType: "string" },
        preferences: {
          bsonType: ["object", "null"],
          properties: {
            delivery_window: { 
              bsonType: ["string", "null"],
              enum: ["MORNING", "AFTERNOON", "EVENING", null]
            },
            leave_at_door: { bsonType: ["bool", "null"] },
            signature_required: { bsonType: ["bool", "null"] },
            notify_on: {
              bsonType: ["array", "null"],
              items: { bsonType: "string" }
            },
            preferred_delivery_instructions: { bsonType: ["string", "null"] }
          },
          additionalProperties: true
        },
        updated_at: { bsonType: "date" }
      },
      additionalProperties: false
    }
  }
});

db.delivery_settings.createIndex({ user_id: 1 }, { unique: true });

db.createCollection("delivery_feedback", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["delivery_id", "order_id", "user_id", "submitted_at"],
      properties: {
        delivery_id: { bsonType: "string" },
        order_id: { bsonType: "string" },
        user_id: { bsonType: "string" },
        rider_id: { bsonType: ["string", "null"] },
        rating: { 
          bsonType: ["int", "null"],
          minimum: 1,
          maximum: 5
        },
        comment: { bsonType: ["string", "null"] },
        categories: {
          bsonType: ["array", "null"],
          items: { bsonType: "string" }
        },
        submitted_at: { bsonType: "date" }
      },
      additionalProperties: false
    }
  }
});

db.delivery_feedback.createIndex({ delivery_id: 1 }, { unique: true });
db.delivery_feedback.createIndex({ rider_id: 1 });
db.delivery_feedback.createIndex({ user_id: 1 });
db.delivery_feedback.createIndex({ rating: 1 });

db.createCollection("user_events", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["event_type", "timestamp"],
      properties: {
        event_id: { bsonType: ["string", "null"] },
        user_id: { bsonType: ["string", "null"] },
        session_id: { bsonType: ["string", "null"] },
        event_type: { bsonType: "string" },
        payload: { bsonType: ["object", "null"] },
        timestamp: { bsonType: "date" },
        ip: { bsonType: ["string", "null"] },
        user_agent: { bsonType: ["string", "null"] },
        // Optional KPI fields for faster queries
        product_id: { bsonType: ["string", "null"] },
        page: { bsonType: ["string", "null"] },
        referrer: { bsonType: ["string", "null"] }
      },
      additionalProperties: false
    }
  }
});

db.user_events.createIndex(
  { event_id: 1 }, 
  { 
    unique: true, 
    partialFilterExpression: { event_id: { $exists: true } }
  }
);
db.user_events.createIndex({ user_id: 1, timestamp: -1 });
db.user_events.createIndex({ session_id: 1, timestamp: -1 });
db.user_events.createIndex({ event_type: 1, timestamp: -1 });
db.user_events.createIndex({ timestamp: 1 }, { expireAfterSeconds: 7776000 }); // 90 days TTL
