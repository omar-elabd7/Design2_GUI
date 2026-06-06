# System JSON Messages

> **Last updated:** June 2026  
> Reflects the final 11-state mission flow.  
> Flutter ↔ Laptop Python Backend (sim_server / real backend) over WebSocket (`/ws`) and HTTP.

---

## Contents
1. [SEND — Flutter → Backend](#send--flutter--backend)
2. [RECEIVE — Backend → Flutter](#receive--backend--flutter)
3. [MissionState values](#missionstate-values)
4. [FaultType values](#faulttype-values)
5. [Mission flow sequence](#mission-flow-sequence)
6. [event.log level values](#eventlog--level-values)

---

## SEND — Flutter → Backend


---

### order.place
> **Transport:** HTTP `POST /orders`  
> Sent by Flutter checkout to place an order. The backend responds with the created order object and starts `run_mission()` automatically.

```json
{
  "type": "order.place",
  "user_id": "user_006",
  "assigned_rfid": "RFID_OM4R99",
  "items": [
    {
      "product_id": "prod_001",
      "product_name": "Apple",
      "quantity": 2,
      "unit_price": 5.00
    }
  ]
}
```

---

### order.cancel
> **Transport:** WebSocket

```json
{
  "type": "order.cancel",
  "order_id": "ord_abc123",
  "user_id": "user_006",
  "reason": "customer_cancelled"
}
```

---

### mission.start
> **Transport:** WebSocket  
> Safety-net re-trigger sent after `POST /orders` succeeds (in case server missed the HTTP trigger).

```json
{
  "type": "mission.start",
  "order_id": "ord_abc123"
}
```

---

### mission.stop
> **Transport:** WebSocket  
> Immediately cancels the active mission task.

```json
{
  "type": "mission.stop",
  "order_id": "ord_abc123",
  "reason": "user_requested"
}
```

---

### storage.close_request
> **Transport:** WebSocket  
> Sent when the customer taps **"I Took My Order"** on the Flutter tracking screen.  
> Unblocks the `storageOpened` wait in `run_mission()`, advancing to `storageClosed`.

```json
{
  "type": "storage.close_request",
  "order_id": "ord_abc123"
}
```

---

### user.session
> **Transport:** WebSocket  
> Sent immediately after a successful login. Lets the backend know which user is active (for RFID matching and credit tracking).

```json
{
  "type": "user.session",
  "user_id": "user_006",
  "username": "omar",
  "name": "Omar",
  "role": "customer",
  "rfid_card_id": "RFID_OM4R99",
  "credits": 500.0,
  "session_token": "tok_xyz",
  "is_logout": false
}
```

> On logout send the same message with `"is_logout": true`.

---

### rfid.verification
> **Transport:** WebSocket  
> Sent by Flutter RFID panel when the user scans their card. Unblocks the `rfidAwaiting` wait in `run_mission()`.

```json
{
  "type": "rfid.verification",
  "order_id": "ord_abc123",
  "rfid_card_id": "RFID_OM4R99",
  "user_id": "user_006"
}
```

---

### payment.request
> **Transport:** WebSocket

```json
{
  "type": "payment.request",
  "order_id": "ord_abc123",
  "user_id": "user_006",
  "amount": 10.00,
  "method": "credits"
}
```

---

### payment.status
> **Transport:** WebSocket

```json
{
  "type": "payment.status",
  "order_id": "ord_abc123",
  "state": "approved",
  "transaction_id": "txn_abc123"
}
```

---

### debug.obstacle_inject
> **Transport:** WebSocket (Dashboard → Backend)  
> Pauses robot navigation immediately; sets `fault_type = "obstacleBlocked"`.

```json
{
  "type": "debug.obstacle_inject"
}
```

---

### debug.obstacle_release
> **Transport:** WebSocket (Dashboard → Backend)  
> Clears the obstacle pause; robot resumes navigation in its current `mission_state`.

```json
{
  "type": "debug.obstacle_release"
}
```

---

### debug.rfid_simulate
> **Transport:** WebSocket (Dashboard → Backend)  
> Simulates an RFID card tap on the robot.

```json
{
  "type": "debug.rfid_simulate",
  "rfid_card_id": "RFID_OM4R99",
  "order_id": "ord_abc123",
  "should_succeed": true
}
```

---

### debug.force_state
> **Transport:** WebSocket (Dashboard → Backend)  
> Forces `robot.mission_state` to any value instantly and emits a `mission.event` so the Flutter timeline updates live.

```json
{
  "type": "debug.force_state",
  "state": "rfidAwaiting"
}
```

---

### debug.battery_drain / debug.battery_charge
> **Transport:** WebSocket (Dashboard → Backend)

```json
{ "type": "debug.battery_drain",  "amount": 20 }
{ "type": "debug.battery_charge", "amount": 30 }
```

---

### debug.reset
> **Transport:** WebSocket (Dashboard → Backend)  
> Full reset: cancels mission, restores battery to 82%, clears all state.

```json
{
  "type": "debug.reset"
}
```

---

## RECEIVE — Backend → Flutter

---

### robot.status
> **Transport:** WebSocket — broadcast every **2 s** (heartbeat) and on every state change.  
> This is the primary source for `robotStatusProvider` in Flutter.

```json
{
  "type": "robot.status",
  "battery_percent": 78,
  "is_charging": false,
  "mode": "autonomous",
  "mission_state": "headingToCustomer",
  "storage_state": "closed",
  "fault_type": "none",
  "active_order_id": "ord_abc123",
  "linear_speed": 0.25,
  "angular_speed": 0.0,
  "distance_remaining": 2.40,
  "obstacle_detected": false,
  "current_fruit": "apple",
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

> `mission_state` must be one of the 11 values listed in [MissionState values](#missionstate-values).  
> `fault_type` must be one of the values listed in [FaultType values](#faulttype-values).

---

### mission.event
> **Transport:** WebSocket — emitted at every mission state transition.  
> Consumed by `missionUpdatesProvider` to build the event log and advance the timeline.

```json
{
  "type": "mission.event",
  "order_id": "ord_abc123",
  "event": "headingToCustomer",
  "message": "Robot heading to customer location!",
  "progress_percent": 55,
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

> The `event` string maps 1-to-1 with `mission_state` (see table below).

---

### event.log
> **Transport:** WebSocket — emitted alongside every `mission.event` and for system/warning messages.  
> Consumed by the **Event Log Panel** on the tracking screen.

```json
{
  "type": "event.log",
  "level": "mission",
  "event_type": "headingToCustomer",
  "message": "Robot heading to customer location!",
  "order_id": "ord_abc123",
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

> `level` values: `mission` (blue) · `warning` (amber) · `error` (red) · `system` (grey)

---

### rfid.result
> **Transport:** WebSocket — sent after RFID verification completes (success or fail).

```json
{
  "type": "rfid.result",
  "success": true,
  "rfid_card_id": "RFID_OM4R99",
  "order_id": "ord_abc123",
  "message": "Identity verified ✓",
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

---

### storage.status
> **Transport:** WebSocket — sent whenever the storage door state changes.

```json
{
  "type": "storage.status",
  "state": "open",
  "order_id": "ord_abc123",
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

> `state` values: `open` · `closed` · `opening` · `closing` · `fault`

---

### storage.open
> **Transport:** WebSocket — sent when door transitions to fully open (during `storageOpened`).

```json
{
  "type": "storage.open",
  "state": "open",
  "order_id": "ord_abc123",
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

---

### storage.closed
> **Transport:** WebSocket — sent when door transitions to closed (during `storageClosed`).

```json
{
  "type": "storage.closed",
  "state": "closing",
  "order_id": "ord_abc123",
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

---

### vision.fruit_detection
> **Transport:** WebSocket — sent during `visionChecking` state.

```json
{
  "type": "vision.fruit_detection",
  "fruit": "apple",
  "detected": true,
  "confidence": 0.94,
  "bounding_box": { "x": 118, "y": 82, "w": 58, "h": 52 },
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

---

### navigation.obstacle_status
> **Transport:** WebSocket — sent every 0.5 s while obstacle is active; sent once on clearance.

```json
{
  "type": "navigation.obstacle_status",
  "state": "detected",
  "distance_meters": 0.35,
  "angle_degrees": 0.0,
  "is_blocking_path": true,
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

> `state` values: `detected` · `clear`

---

### navigation.path_status
> **Transport:** WebSocket — sent every 0.8 s during `_navigate()` (while robot is moving).

```json
{
  "type": "navigation.path_status",
  "state": "clear",
  "target_x": 2.0,
  "target_y": 1.5,
  "distance_to_goal": 2.40,
  "estimated_seconds": 6,
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

---

### navigation.lidar_status
> **Transport:** WebSocket

```json
{
  "type": "navigation.lidar_status",
  "is_active": true,
  "scan_frequency_hz": 10,
  "nearest_object_meters": 0.9,
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

---

### navigation.proximity_status
> **Transport:** WebSocket

```json
{
  "type": "navigation.proximity_status",
  "front_cm": 45.0,
  "back_cm": 120.0,
  "left_cm": 80.0,
  "right_cm": 75.0,
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

---

### navigation.pose
> **Transport:** WebSocket

```json
{
  "type": "navigation.pose",
  "x": 1.8,
  "y": 1.2,
  "heading_degrees": 45.0,
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

---

### storage.pickup_status
> **Transport:** WebSocket — sent during `storing` state.

```json
{
  "type": "storage.pickup_status",
  "state": "gripping",
  "fruit": "apple",
  "attempt": 1,
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

---

### vision.fruit_availability
> **Transport:** WebSocket

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
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

---

### order.status_update
> **Transport:** WebSocket

```json
{
  "type": "order.status_update",
  "order_id": "ord_abc123",
  "status": "navigating",
  "message": "Robot is on its way",
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

---

### payment.required
> **Transport:** WebSocket

```json
{
  "type": "payment.required",
  "order_id": "ord_abc123",
  "amount": 10.00,
  "method": "credits",
  "user_credits_available": 500.0,
  "timeout_seconds": 30,
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

---

### user.session_ack
> **Transport:** WebSocket — backend acknowledgement of a `user.session` message.

```json
{
  "type": "user.session_ack",
  "user_id": "user_006",
  "username": "omar",
  "active": true,
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

---

### telemetry.battery
> **Transport:** WebSocket — broadcast every 30 s and on manual drain/charge.

```json
{
  "type": "telemetry.battery",
  "battery_percent": 78,
  "is_charging": false,
  "voltage": 11.3,
  "estimated_minutes_remaining": 156,
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

---

### system.health
> **Transport:** WebSocket — broadcast every 10 s.

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
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

---

### connection.status
> **Transport:** WebSocket

```json
{
  "type": "connection.status",
  "state": "connected",
  "latency_ms": 12,
  "timestamp": "2026-06-06T10:00:00.000Z"
}
```

---

## MissionState values

These are the **only valid** values for `mission_state` in `robot.status` and `event` in `mission.event`.

| `mission_state` / `event` | Flutter enum | Timeline step | Description |
|---|---|---|---|
| `idle` | `MissionState.idle` | — | No active mission |
| `missionReceived` | `MissionState.missionReceived` | ① Order Received | Order accepted, robot preparing |
| `headingToFruit` | `MissionState.headingToFruit` | ② Heading to Fruit | Robot moving to fruit stock area |
| `visionChecking` | `MissionState.visionChecking` | ③ Checking Stock | Vision module scanning for fruit (3 s) |
| `storing` | `MissionState.storing` | ④ Collecting Fruit | Mechanism grabs fruit and places in storage (4 s) |
| `headingToCustomer` | `MissionState.headingToCustomer` | ⑤ Heading to Customer | Robot driving to customer location |
| `rfidAwaiting` | `MissionState.rfidAwaiting` | ⑥ RFID Verification | Waiting for customer to tap RFID card (60 s timeout) |
| `storageOpened` | `MissionState.storageOpened` | ⑦ Collect Your Order | Storage box open — customer collects order |
| `storageClosed` | `MissionState.storageClosed` | ⑦ Collect Your Order | Storage box closing after customer confirms |
| `returning` | `MissionState.returning` | — | Robot heading back to home position |
| `failed` | `MissionState.failed` | — | Mission aborted (see `fault_type`) |

> **`mission.event` field:** the `event` string in a `mission.event` message maps directly to the `mission_state` value above, **except** the very first event which uses `"orderReceived"` (maps to `missionReceived`).

| `mission.event` → `event` field | Maps to Flutter state |
|---|---|
| `orderReceived` | `MissionState.missionReceived` |
| `headingToFruit` | `MissionState.headingToFruit` |
| `visionChecking` | `MissionState.visionChecking` |
| `storing` | `MissionState.storing` |
| `headingToCustomer` | `MissionState.headingToCustomer` |
| `rfidAwaiting` | `MissionState.rfidAwaiting` |
| `storageOpened` | `MissionState.storageOpened` |
| `storageClosed` | `MissionState.storageClosed` |
| `returning` | `MissionState.returning` |
| `error` | `MissionState.failed` |
| `idle` | `MissionState.idle` |

---

## FaultType values

| `fault_type` | Flutter enum | Description |
|---|---|---|
| `none` | `FaultType.none` | No active fault |
| `obstacleBlocked` | `FaultType.obstacleBlocked` | Path blocked by obstacle (robot paused) |
| `lowBattery` | `FaultType.lowBattery` | Battery ≤ 20 % |
| `criticalBattery` | `FaultType.criticalBattery` | Battery ≤ 10 % |
| `outOfStock` | `FaultType.outOfStock` | Fruit unavailable in stock |
| `rfidFailed` | `FaultType.rfidFailed` | RFID scan failed or timed out |
| `storageFault` | `FaultType.storageFault` | Storage door error |
| `communicationLost` | `FaultType.communicationLost` | Lost connection to robot |
| `missionCancelled` | `FaultType.missionCancelled` | Mission cancelled by user |

---

## Mission flow sequence

Full end-to-end sequence after a customer places an order:

```
Flutter  ──POST /orders──►  Backend
Backend  ──robot.status (missionReceived)──►  Flutter   [4 s hold]
Backend  ──mission.event (orderReceived)──►   Flutter

Backend  ──robot.status (headingToFruit)──►   Flutter
Backend  ──navigation.path_status (× N)──►    Flutter   [~8 s drive]

Backend  ──robot.status (visionChecking)──►   Flutter
Backend  ──vision.fruit_detection──►          Flutter   [3 s]

Backend  ──robot.status (storing)──►          Flutter
Backend  ──storage.status (opening)──►        Flutter   [4 s]

Backend  ──robot.status (headingToCustomer)── Flutter
Backend  ──navigation.path_status (× N)──►    Flutter   [~9 s drive]

Backend  ──robot.status (rfidAwaiting)──►     Flutter   [60 s timeout]
Flutter  ──rfid.verification──►               Backend
Backend  ──rfid.result (success)──►           Flutter

Backend  ──robot.status (storageOpened)──►    Flutter
Backend  ──storage.open──►                    Flutter
         ← customer taps "I Took My Order" →
Flutter  ──storage.close_request──►           Backend

Backend  ──robot.status (storageClosed)──►    Flutter
Backend  ──storage.closed──►                  Flutter   [2.5 s close]

Backend  ──robot.status (returning)──►        Flutter   [5 s]

Backend  ──robot.status (idle)──►             Flutter
```

**Obstacle during navigation:**
```
Backend  ──navigation.obstacle_status (detected)──►  Flutter  [fault_type = obstacleBlocked]
Backend  ──robot.status (fault active, speed = 0)──►  Flutter
         ← obstacle cleared →
Backend  ──navigation.obstacle_status (clear)──►     Flutter  [fault_type = none]
Backend  ──robot.status (same mission_state)──►       Flutter
```

---

## event.log — level values

| `level` | UI colour | When used |
|---|---|---|
| `mission` | 🔵 Blue | Normal milestone step (every state transition) |
| `warning` | 🟡 Amber | Non-critical issue (RFID timeout warning, obstacle) |
| `error` | 🔴 Red | Critical fault (rfidFailed, mission aborted) |
| `system` | ⚫ Grey | Connection / health / idle messages |
