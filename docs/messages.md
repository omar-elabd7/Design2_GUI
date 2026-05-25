# System JSON Messages

---

## SEND — Flutter → Backend

---

### order.place
```json
{
  "type": "order.place",
  "user_id": "usr_001",
  "assigned_rfid": "RFID_CARD_A1",
  "items": [
    {
      "product_id": "prod_apple",
      "product_name": "Apple",
      "quantity": 2,
      "unit_price": 5.00
    }
  ],
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### order.cancel
```json
{
  "type": "order.cancel",
  "order_id": "ord_001",
  "user_id": "usr_001",
  "reason": "customer_cancelled",
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### mission.start
```json
{
  "type": "mission.start",
  "order_id": "ord_001",
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### mission.stop
```json
{
  "type": "mission.stop",
  "order_id": "ord_001",
  "reason": "user_requested",
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### rfid.verification
```json
{
  "type": "rfid.verification",
  "order_id": "ord_001",
  "rfid_card_id": "RFID_CARD_A1",
  "user_id": "usr_001",
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### payment.request
```json
{
  "type": "payment.request",
  "order_id": "ord_001",
  "user_id": "usr_001",
  "amount": 42.50,
  "method": "credits",
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### payment.status
```json
{
  "type": "payment.status",
  "order_id": "ord_001",
  "state": "approved",
  "transaction_id": "txn_abc123",
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### debug.obstacle_inject
```json
{
  "type": "debug.obstacle_inject",
  "distance_meters": 0.5,
  "angle_degrees": 0.0,
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### debug.obstacle_release
```json
{
  "type": "debug.obstacle_release",
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### debug.rfid_simulate
```json
{
  "type": "debug.rfid_simulate",
  "rfid_card_id": "RFID_CARD_A1",
  "order_id": "ord_001",
  "should_succeed": true,
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---
---

## RECEIVE — Backend → Flutter

---

### robot.status
```json
{
  "type": "robot.status",
  "battery_percent": 82,
  "is_charging": false,
  "mode": "autonomous",
  "mission_state": "navigatingToUser",
  "storage_state": "closed",
  "fault_type": "none",
  "active_order_id": "ord_001",
  "linear_speed": 0.25,
  "angular_speed": 0.0,
  "distance_remaining": 1.4,
  "obstacle_detected": false,
  "current_fruit": "apple",
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### mission.event
```json
{
  "type": "mission.event",
  "order_id": "ord_001",
  "event": "navigatingToItems",
  "message": "Heading to apple shelf",
  "progress_percent": 40,
  "timestamp": "2026-05-24T10:00:05.000Z"
}
```

---

### order.status_update
```json
{
  "type": "order.status_update",
  "order_id": "ord_001",
  "status": "navigating",
  "message": "Robot is on its way",
  "timestamp": "2026-05-24T10:01:00.000Z"
}
```

---

### navigation.obstacle_status
```json
{
  "type": "navigation.obstacle_status",
  "state": "detected",
  "distance_meters": 0.45,
  "angle_degrees": 15.0,
  "is_blocking_path": true,
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### navigation.path_status
```json
{
  "type": "navigation.path_status",
  "state": "clear",
  "target_x": 2.0,
  "target_y": 1.5,
  "distance_to_goal": 1.2,
  "estimated_seconds": 8,
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### navigation.lidar_status
```json
{
  "type": "navigation.lidar_status",
  "is_active": true,
  "scan_frequency_hz": 10,
  "nearest_object_meters": 0.9,
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### navigation.proximity_status
```json
{
  "type": "navigation.proximity_status",
  "front_cm": 45.0,
  "back_cm": 120.0,
  "left_cm": 80.0,
  "right_cm": 75.0,
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### navigation.pose
```json
{
  "type": "navigation.pose",
  "x": 1.8,
  "y": 1.2,
  "heading_degrees": 45.0,
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### storage.status
```json
{
  "type": "storage.status",
  "state": "closed",
  "order_id": "ord_001",
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### storage.open
```json
{
  "type": "storage.open",
  "state": "open",
  "order_id": "ord_001",
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### storage.closed
```json
{
  "type": "storage.closed",
  "state": "closed",
  "order_id": "ord_001",
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### storage.pickup_status
```json
{
  "type": "storage.pickup_status",
  "state": "gripping",
  "fruit": "apple",
  "attempt": 1,
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### vision.fruit_detection
```json
{
  "type": "vision.fruit_detection",
  "fruit": "apple",
  "detected": true,
  "confidence": 0.93,
  "bounding_box": { "x": 120, "y": 80, "w": 60, "h": 55 },
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### vision.fruit_availability
```json
{
  "type": "vision.fruit_availability",
  "availability": {
    "apple": true,
    "banana": false,
    "orange": true,
    "mango": true,
    "grapes": false
  },
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### event.log
```json
{
  "type": "event.log",
  "level": "mission",
  "event_type": "navigatingToItems",
  "message": "Robot heading to apple shelf",
  "order_id": "ord_001",
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### rfid.result
```json
{
  "type": "rfid.result",
  "success": true,
  "rfid_card_id": "RFID_CARD_A1",
  "order_id": "ord_001",
  "message": "Identity verified",
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### payment.required
```json
{
  "type": "payment.required",
  "order_id": "ord_001",
  "amount": 42.50,
  "method": "credits",
  "user_credits_available": 150.00,
  "timeout_seconds": 30,
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### connection.status
```json
{
  "type": "connection.status",
  "state": "connected",
  "latency_ms": 12,
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### telemetry.battery
```json
{
  "type": "telemetry.battery",
  "battery_percent": 82,
  "is_charging": false,
  "voltage": 11.8,
  "estimated_minutes_remaining": 45,
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

### system.health
```json
{
  "type": "system.health",
  "level": "nominal",
  "cpu_percent": 34,
  "ram_percent": 51,
  "uptime_seconds": 3600,
  "ros2_active": true,
  "micro_ros_active": true,
  "camera_active": true,
  "lidar_active": true,
  "timestamp": "2026-05-24T10:00:00.000Z"
}
```

---

## mission_state values

| Value | Meaning |
|---|---|
| `idle` | No active mission |
| `orderReceived` | Order accepted by backend |
| `robotAssigned` | Robot allocated to order |
| `planningPath` | Generating navigation path |
| `navigatingToItems` | Moving toward fruit shelf |
| `fruitDetection` | Camera scanning for fruit |
| `collectingItems` | Pickup arm collecting fruit |
| `storingItem` | Placing item in compartment |
| `returningToDropoff` | Returning to customer location |
| `waitingForRfid` | Awaiting RFID card scan |
| `paymentProcessing` | Processing payment |
| `unlockingStorage` | Opening storage door |
| `deliveryComplete` | Mission finished successfully |
| `error` | Mission failed with fault |

## fault_type values

| Value | Meaning |
|---|---|
| `none` | No fault |
| `obstacleBlocked` | Path permanently blocked |
| `lowBattery` | Battery below threshold |
| `criticalBattery` | Battery critically low |
| `outOfStock` | Fruit not available |
| `rfidFailed` | RFID scan failed |
| `storageFault` | Storage door fault |
| `communicationLost` | Lost connection to robot |
| `missionCancelled` | Mission aborted |

## event.log — level values

| Value | Color | Use |
|---|---|---|
| `mission` | Blue | Normal milestone step |
| `warning` | Amber | Non-critical issue |
| `error` | Red | Critical fault |
| `system` | Grey | Connection / health update |
