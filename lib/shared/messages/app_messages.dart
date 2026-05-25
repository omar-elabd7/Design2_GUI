// =============================================================================
// app_messages.dart
//
// Full JSON message contract for the system.
// Flutter (Customer) ↔ Laptop Python Backend ↔ Raspberry Pi ↔ ROS2 ↔ ESP32
//
// Sections:
//   1.  Message Type Constants
//   2.  Supporting Enums
//   3.  SEND Messages    (Flutter → Backend)
//   4.  RECEIVE Messages (Backend → Flutter)
//   5.  Shared Sub-models
// =============================================================================

// ignore_for_file: constant_identifier_names

// =============================================================================
// 1. MESSAGE TYPE CONSTANTS
// =============================================================================

// ── SEND: Mission / Order ────────────────────────────────────────────────────
const String kMsgOrderPlace = 'order.place';
const String kMsgOrderCancel = 'order.cancel';
const String kMsgMissionStart = 'mission.start';
const String kMsgMissionStop = 'mission.stop';

// ── SEND: Storage ────────────────────────────────────────────────────────────
/// Sent when customer taps "I took my order" — triggers storageClosed state.
const String kMsgStorageCloseRequest = 'storage.close_request';

// ── SEND: Session ────────────────────────────────────────────────────────────
/// Sent immediately after a successful login so the backend/robot knows
/// which user is now active (id, name, role, rfid, credits, token).
const String kMsgUserSession = 'user.session';

// ── SEND: Authentication / Payment ──────────────────────────────────────────
const String kMsgRfidVerification = 'rfid.verification';
const String kMsgPaymentRequest = 'payment.request';
const String kMsgPaymentStatus = 'payment.status';

// ── SEND: Debug / Testing ────────────────────────────────────────────────────
const String kMsgObstacleInject = 'debug.obstacle_inject';
const String kMsgObstacleRelease = 'debug.obstacle_release';
const String kMsgRfidSimulate = 'debug.rfid_simulate';

// ── RECEIVE: Robot State ─────────────────────────────────────────────────────
const String kMsgRobotStatus = 'robot.status';

// ── RECEIVE: Mission Timeline ────────────────────────────────────────────────
const String kMsgMissionEvent = 'mission.event';
const String kMsgOrderStatusUpdate = 'order.status_update';

// ── RECEIVE: Navigation / Environment ───────────────────────────────────────
const String kMsgObstacleStatus = 'navigation.obstacle_status';
const String kMsgPathStatus = 'navigation.path_status';
const String kMsgLidarStatus = 'navigation.lidar_status';
const String kMsgProximityStatus = 'navigation.proximity_status';
const String kMsgRobotPose = 'navigation.pose';

// ── RECEIVE: Storage / Mechanism ─────────────────────────────────────────────
const String kMsgStorageStatus = 'storage.status';
const String kMsgStorageOpen = 'storage.open';
const String kMsgStorageClosed = 'storage.closed';
const String kMsgPickupStatus = 'storage.pickup_status';

// ── RECEIVE: Vision ──────────────────────────────────────────────────────────
const String kMsgFruitDetection = 'vision.fruit_detection';
const String kMsgFruitAvailability = 'vision.fruit_availability';

// ── RECEIVE: Event System / Log ──────────────────────────────────────────────
const String kMsgEventLog = 'event.log';

// ── RECEIVE: Authentication / Payment ────────────────────────────────────────
const String kMsgRfidResult = 'rfid.result';
const String kMsgPaymentRequired = 'payment.required';

// ── RECEIVE: Session ─────────────────────────────────────────────────────────
/// Backend acknowledgement of a received user.session message.
const String kMsgUserSessionAck = 'user.session_ack';

// ── RECEIVE: Connection / Health ─────────────────────────────────────────────
const String kMsgConnectionStatus = 'connection.status';
const String kMsgBatteryStatus = 'telemetry.battery';
const String kMsgSystemHealth = 'system.health';

// =============================================================================
// 2. SUPPORTING ENUMS
// =============================================================================

/// Maps to the left timeline on the Order Tracking screen.
enum MissionEventType {
  idle,
  orderReceived,
  robotAssigned,
  planningPath,
  navigatingToItems,
  fruitDetection,
  collectingItems,
  storingItem,
  returningToDropoff,
  waitingForRfid,
  paymentProcessing,
  unlockingStorage,
  deliveryComplete,
  error,
}

/// Severity level for event log entries.
enum EventLogLevel {
  mission, // blue  – normal milestone
  warning, // amber – non-critical
  error, // red   – critical fault
  system, // grey  – connection / health
}

/// Overall connection state with the backend.
enum BackendConnectionState { connected, reconnecting, disconnected }

/// Whether the path is clear, blocked, or replanning.
enum PathState { clear, blocked, replanning, unknown }

/// Obstacle detection state from sensors.
enum ObstacleState { clear, detected, tooClose, criticallyClose }

/// High-level health of the whole robot system.
enum SystemHealthLevel { nominal, degraded, critical, offline }

/// Pickup arm / mechanism state.
enum PickupState { idle, extending, gripping, retracting, success, failed }

/// Payment flow states.
enum PaymentState { pending, processing, approved, declined, cancelled }

// =============================================================================
// 3. SEND MESSAGES  (Flutter → Laptop Python Backend)
//    All classes expose:  Map<String, dynamic> toMap()
// =============================================================================

// ─────────────────────────────────────────────────────────────────────────────
/// [SEND] Customer places a new order.
/// HTTP POST /orders  OR  WebSocket type = kMsgOrderPlace
// ─────────────────────────────────────────────────────────────────────────────
class OrderPlaceMsg {
  const OrderPlaceMsg({
    required this.userId,
    required this.assignedRfid,
    required this.items,
  });

  final String userId;
  final String assignedRfid;

  /// List of { product_id, product_name, quantity, unit_price }
  final List<CartItemPayload> items;

  Map<String, dynamic> toMap() => {
    'type': kMsgOrderPlace,
    'user_id': userId,
    'assigned_rfid': assignedRfid,
    'items': items.map((e) => e.toMap()).toList(),
    'timestamp': DateTime.now().toIso8601String(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
/// [SEND] Customer cancels an active order.
// ─────────────────────────────────────────────────────────────────────────────
class OrderCancelMsg {
  const OrderCancelMsg({
    required this.orderId,
    required this.userId,
    this.reason = 'customer_cancelled',
  });

  final String orderId;
  final String userId;
  final String reason;

  Map<String, dynamic> toMap() => {
    'type': kMsgOrderCancel,
    'order_id': orderId,
    'user_id': userId,
    'reason': reason,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
/// [SEND] Explicitly start a mission for an accepted order.
/// Used when mission does not auto-start after order acceptance.
// ─────────────────────────────────────────────────────────────────────────────
class MissionStartMsg {
  const MissionStartMsg({required this.orderId});

  final String orderId;

  Map<String, dynamic> toMap() => {
    'type': kMsgMissionStart,
    'order_id': orderId,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
/// [SEND] Stop / abort the current mission.
// ─────────────────────────────────────────────────────────────────────────────
class MissionStopMsg {
  const MissionStopMsg({required this.orderId, this.reason = 'user_requested'});

  final String orderId;
  final String reason;

  Map<String, dynamic> toMap() => {
    'type': kMsgMissionStop,
    'order_id': orderId,
    'reason': reason,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
/// [SEND] Customer presents RFID card to verify identity.
/// Sent after robot arrives and is waiting for RFID scan.
// ─────────────────────────────────────────────────────────────────────────────
class RfidVerificationMsg {
  const RfidVerificationMsg({
    required this.orderId,
    required this.rfidCardId,
    required this.userId,
  });

  final String orderId;
  final String rfidCardId;
  final String userId;

  Map<String, dynamic> toMap() => {
    'type': kMsgRfidVerification,
    'order_id': orderId,
    'rfid_card_id': rfidCardId,
    'user_id': userId,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
/// [SEND] Customer confirms payment intent.
// ─────────────────────────────────────────────────────────────────────────────
class PaymentRequestMsg {
  const PaymentRequestMsg({
    required this.orderId,
    required this.userId,
    required this.amount,
    this.method = 'credits',
  });

  final String orderId;
  final String userId;
  final double amount;

  /// 'credits' | 'card' | 'cash'
  final String method;

  Map<String, dynamic> toMap() => {
    'type': kMsgPaymentRequest,
    'order_id': orderId,
    'user_id': userId,
    'amount': amount,
    'method': method,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
/// [SEND] Acknowledge a payment result from the GUI side.
// ─────────────────────────────────────────────────────────────────────────────
class PaymentStatusMsg {
  const PaymentStatusMsg({
    required this.orderId,
    required this.state,
    this.transactionId,
  });

  final String orderId;
  final PaymentState state;
  final String? transactionId;

  Map<String, dynamic> toMap() => {
    'type': kMsgPaymentStatus,
    'order_id': orderId,
    'state': state.name,
    if (transactionId != null) 'transaction_id': transactionId,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
/// [SEND][DEBUG] Inject a fake obstacle into the robot's sensor data.
// ─────────────────────────────────────────────────────────────────────────────
class ObstacleInjectMsg {
  const ObstacleInjectMsg({this.distanceMeters = 0.5, this.angleDegrees = 0.0});

  final double distanceMeters;
  final double angleDegrees;

  Map<String, dynamic> toMap() => {
    'type': kMsgObstacleInject,
    'distance_meters': distanceMeters,
    'angle_degrees': angleDegrees,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
/// [SEND][DEBUG] Release the injected obstacle.
// ─────────────────────────────────────────────────────────────────────────────
class ObstacleReleaseMsg {
  const ObstacleReleaseMsg();

  Map<String, dynamic> toMap() => {
    'type': kMsgObstacleRelease,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
/// [SEND][DEBUG] Simulate an RFID card scan.
// ─────────────────────────────────────────────────────────────────────────────
class RfidSimulationMsg {
  const RfidSimulationMsg({
    required this.rfidCardId,
    required this.orderId,
    this.shouldSucceed = true,
  });

  final String rfidCardId;
  final String orderId;
  final bool shouldSucceed;

  Map<String, dynamic> toMap() => {
    'type': kMsgRfidSimulate,
    'rfid_card_id': rfidCardId,
    'order_id': orderId,
    'should_succeed': shouldSucceed,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
/// [SEND] Announce the signed-in user to the backend immediately after login.
/// The backend stores this as the "active session" so it can:
///   • pre-load the user's RFID for delivery verification
///   • link any incoming orders to the right user
///   • display the user name on the worker dashboard
///   • log session start / end events
///
/// Also sent on logout with [isLogout] = true so the backend clears the
/// active session state.
///
/// Example JSON (login):
/// {
///   "type": "user.session",
///   "user_id": "user_001",
///   "username": "ahmed_hassan",
///   "name": "Ahmed Hassan",
///   "role": "customer",
///   "rfid_card_id": "RFID_A1B2C3",
///   "credits": 150.0,
///   "session_token": "tok_abc123",
///   "is_logout": false,
///   "timestamp": "2026-05-25T10:00:00.000Z"
/// }
///
/// Example JSON (logout):
/// { "type": "user.session", "user_id": "user_001", "is_logout": true, ... }
// ─────────────────────────────────────────────────────────────────────────────
class UserSessionMsg {
  const UserSessionMsg({
    required this.userId,
    required this.username,
    required this.name,
    required this.role,
    required this.rfidCardId,
    required this.credits,
    required this.sessionToken,
    this.isLogout = false,
  });

  final String userId;
  final String username;
  final String name;

  /// 'customer' | 'worker'
  final String role;
  final String rfidCardId;
  final double credits;
  final String sessionToken;

  /// true when this message signals a logout / session end.
  final bool isLogout;

  Map<String, dynamic> toMap() => {
    'type': kMsgUserSession,
    'user_id': userId,
    'username': username,
    'name': name,
    'role': role,
    'rfid_card_id': rfidCardId,
    'credits': credits,
    'session_token': sessionToken,
    'is_logout': isLogout,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

// =============================================================================
// 4. RECEIVE MESSAGES  (Backend → Flutter via WebSocket)
//    All classes expose:  factory ClassName.fromMap(Map<String, dynamic> map)
// =============================================================================

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] Complete robot state snapshot.
/// Single source of truth for the Mission Control screen.
///
/// Maps directly to RobotStatus model — use RobotStatusDto to convert.
///
/// Example JSON:
/// {
///   "type": "robot.status",
///   "battery_percent": 82,
///   "is_charging": false,
///   "mode": "autonomous",
///   "mission_state": "navigatingToUser",
///   "storage_state": "closed",
///   "fault_type": "none",
///   "active_order_id": "ord_001",
///   "linear_speed": 0.25,
///   "angular_speed": 0.0,
///   "distance_remaining": 1.4,
///   "obstacle_detected": false,
///   "current_fruit": "apple",
///   "timestamp": "2026-05-24T10:00:00.000Z"
/// }
// ─────────────────────────────────────────────────────────────────────────────
class RobotStatusMsg {
  const RobotStatusMsg({
    required this.batteryPercent,
    required this.isCharging,
    required this.mode,
    required this.missionState,
    required this.storageState,
    required this.faultType,
    required this.activeOrderId,
    required this.linearSpeed,
    required this.angularSpeed,
    required this.distanceRemaining,
    required this.obstacleDetected,
    required this.currentFruit,
    required this.timestamp,
  });

  final int batteryPercent;
  final bool isCharging;
  final String mode;
  final String missionState;
  final String storageState;
  final String faultType;
  final String? activeOrderId;
  final double linearSpeed;
  final double angularSpeed;
  final double distanceRemaining;
  final bool obstacleDetected;
  final String? currentFruit;
  final DateTime timestamp;

  factory RobotStatusMsg.fromMap(Map<String, dynamic> map) => RobotStatusMsg(
    batteryPercent: map['battery_percent'] as int? ?? 0,
    isCharging: map['is_charging'] as bool? ?? false,
    mode: map['mode'] as String? ?? 'offline',
    missionState: map['mission_state'] as String? ?? 'idle',
    storageState: map['storage_state'] as String? ?? 'closed',
    faultType: map['fault_type'] as String? ?? 'none',
    activeOrderId: map['active_order_id'] as String?,
    linearSpeed: (map['linear_speed'] as num?)?.toDouble() ?? 0.0,
    angularSpeed: (map['angular_speed'] as num?)?.toDouble() ?? 0.0,
    distanceRemaining: (map['distance_remaining'] as num?)?.toDouble() ?? 0.0,
    obstacleDetected: map['obstacle_detected'] as bool? ?? false,
    currentFruit: map['current_fruit'] as String?,
    timestamp: map['timestamp'] != null
        ? DateTime.parse(map['timestamp'] as String)
        : DateTime.now(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] One step in the mission timeline.
/// Drives the left-side progress timeline on OrderTrackingScreen.
///
/// Example JSON:
/// {
///   "type": "mission.event",
///   "order_id": "ord_001",
///   "event": "navigatingToItems",
///   "message": "Heading to apple shelf",
///   "progress_percent": 40,
///   "timestamp": "2026-05-24T10:00:05.000Z"
/// }
// ─────────────────────────────────────────────────────────────────────────────
class MissionEventMsg {
  const MissionEventMsg({
    required this.orderId,
    required this.event,
    required this.message,
    required this.progressPercent,
    required this.timestamp,
  });

  final String orderId;
  final MissionEventType event;
  final String message;

  /// 0–100, used to fill the circular progress indicator.
  final int progressPercent;
  final DateTime timestamp;

  factory MissionEventMsg.fromMap(Map<String, dynamic> map) => MissionEventMsg(
    orderId: map['order_id'] as String,
    event: MissionEventType.values.byName(map['event'] as String? ?? 'idle'),
    message: map['message'] as String? ?? '',
    progressPercent: map['progress_percent'] as int? ?? 0,
    timestamp: DateTime.parse(map['timestamp'] as String),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] Order status changed on the backend side.
///
/// Example JSON:
/// {
///   "type": "order.status_update",
///   "order_id": "ord_001",
///   "status": "navigating",
///   "message": "Robot is on its way",
///   "timestamp": "2026-05-24T10:01:00.000Z"
/// }
// ─────────────────────────────────────────────────────────────────────────────
class OrderStatusUpdateMsg {
  const OrderStatusUpdateMsg({
    required this.orderId,
    required this.status,
    required this.message,
    required this.timestamp,
  });

  final String orderId;
  final String status; // maps to OrderStatus enum
  final String message;
  final DateTime timestamp;

  factory OrderStatusUpdateMsg.fromMap(Map<String, dynamic> map) =>
      OrderStatusUpdateMsg(
        orderId: map['order_id'] as String,
        status: map['status'] as String,
        message: map['message'] as String? ?? '',
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] Obstacle detection state from LIDAR / ultrasonic sensors.
///
/// Example JSON:
/// {
///   "type": "navigation.obstacle_status",
///   "state": "detected",
///   "distance_meters": 0.45,
///   "angle_degrees": 15.0,
///   "is_blocking_path": true,
///   "timestamp": "..."
/// }
// ─────────────────────────────────────────────────────────────────────────────
class ObstacleStatusMsg {
  const ObstacleStatusMsg({
    required this.state,
    required this.distanceMeters,
    required this.angleDegrees,
    required this.isBlockingPath,
    required this.timestamp,
  });

  final ObstacleState state;
  final double distanceMeters;
  final double angleDegrees;
  final bool isBlockingPath;
  final DateTime timestamp;

  factory ObstacleStatusMsg.fromMap(Map<String, dynamic> map) =>
      ObstacleStatusMsg(
        state: ObstacleState.values.byName(map['state'] as String? ?? 'clear'),
        distanceMeters: (map['distance_meters'] as num?)?.toDouble() ?? 0.0,
        angleDegrees: (map['angle_degrees'] as num?)?.toDouble() ?? 0.0,
        isBlockingPath: map['is_blocking_path'] as bool? ?? false,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] Navigation path state (clear / blocked / replanning).
///
/// Example JSON:
/// {
///   "type": "navigation.path_status",
///   "state": "clear",
///   "target_x": 2.0,
///   "target_y": 1.5,
///   "distance_to_goal": 1.2,
///   "estimated_seconds": 8,
///   "timestamp": "..."
/// }
// ─────────────────────────────────────────────────────────────────────────────
class PathStatusMsg {
  const PathStatusMsg({
    required this.state,
    required this.targetX,
    required this.targetY,
    required this.distanceToGoal,
    required this.estimatedSeconds,
    required this.timestamp,
  });

  final PathState state;
  final double targetX;
  final double targetY;
  final double distanceToGoal;
  final int estimatedSeconds;
  final DateTime timestamp;

  factory PathStatusMsg.fromMap(Map<String, dynamic> map) => PathStatusMsg(
    state: PathState.values.byName(map['state'] as String? ?? 'unknown'),
    targetX: (map['target_x'] as num?)?.toDouble() ?? 0.0,
    targetY: (map['target_y'] as num?)?.toDouble() ?? 0.0,
    distanceToGoal: (map['distance_to_goal'] as num?)?.toDouble() ?? 0.0,
    estimatedSeconds: map['estimated_seconds'] as int? ?? 0,
    timestamp: DateTime.parse(map['timestamp'] as String),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] LIDAR sensor health/data summary.
///
/// Example JSON:
/// {
///   "type": "navigation.lidar_status",
///   "is_active": true,
///   "scan_frequency_hz": 10,
///   "nearest_object_meters": 0.9,
///   "timestamp": "..."
/// }
// ─────────────────────────────────────────────────────────────────────────────
class LidarStatusMsg {
  const LidarStatusMsg({
    required this.isActive,
    required this.scanFrequencyHz,
    required this.nearestObjectMeters,
    required this.timestamp,
  });

  final bool isActive;
  final int scanFrequencyHz;
  final double nearestObjectMeters;
  final DateTime timestamp;

  factory LidarStatusMsg.fromMap(Map<String, dynamic> map) => LidarStatusMsg(
    isActive: map['is_active'] as bool? ?? false,
    scanFrequencyHz: map['scan_frequency_hz'] as int? ?? 0,
    nearestObjectMeters:
        (map['nearest_object_meters'] as num?)?.toDouble() ?? 0.0,
    timestamp: DateTime.parse(map['timestamp'] as String),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] Short-range proximity sensors (front/back/sides).
///
/// Example JSON:
/// {
///   "type": "navigation.proximity_status",
///   "front_cm": 45.0,
///   "back_cm": 120.0,
///   "left_cm": 80.0,
///   "right_cm": 75.0,
///   "timestamp": "..."
/// }
// ─────────────────────────────────────────────────────────────────────────────
class ProximityStatusMsg {
  const ProximityStatusMsg({
    required this.frontCm,
    required this.backCm,
    required this.leftCm,
    required this.rightCm,
    required this.timestamp,
  });

  final double frontCm;
  final double backCm;
  final double leftCm;
  final double rightCm;
  final DateTime timestamp;

  factory ProximityStatusMsg.fromMap(Map<String, dynamic> map) =>
      ProximityStatusMsg(
        frontCm: (map['front_cm'] as num?)?.toDouble() ?? 0.0,
        backCm: (map['back_cm'] as num?)?.toDouble() ?? 0.0,
        leftCm: (map['left_cm'] as num?)?.toDouble() ?? 0.0,
        rightCm: (map['right_cm'] as num?)?.toDouble() ?? 0.0,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] Robot's current position and heading on the map.
/// Maps to the /robot_pose ROS2 topic.
///
/// Example JSON:
/// {
///   "type": "navigation.pose",
///   "x": 1.8,
///   "y": 1.2,
///   "heading_degrees": 45.0,
///   "timestamp": "..."
/// }
// ─────────────────────────────────────────────────────────────────────────────
class RobotPoseMsg {
  const RobotPoseMsg({
    required this.x,
    required this.y,
    required this.headingDegrees,
    required this.timestamp,
  });

  final double x;
  final double y;
  final double headingDegrees;
  final DateTime timestamp;

  factory RobotPoseMsg.fromMap(Map<String, dynamic> map) => RobotPoseMsg(
    x: (map['x'] as num?)?.toDouble() ?? 0.0,
    y: (map['y'] as num?)?.toDouble() ?? 0.0,
    headingDegrees: (map['heading_degrees'] as num?)?.toDouble() ?? 0.0,
    timestamp: DateTime.parse(map['timestamp'] as String),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] Storage compartment state update.
///
/// Example JSON:
/// {
///   "type": "storage.status",
///   "state": "open",
///   "order_id": "ord_001",
///   "timestamp": "..."
/// }
// ─────────────────────────────────────────────────────────────────────────────
class StorageStatusMsg {
  const StorageStatusMsg({
    required this.state,
    required this.orderId,
    required this.timestamp,
  });

  /// 'open' | 'closed' | 'opening' | 'closing' | 'fault'
  final String state;
  final String? orderId;
  final DateTime timestamp;

  factory StorageStatusMsg.fromMap(Map<String, dynamic> map) =>
      StorageStatusMsg(
        state: map['state'] as String? ?? 'closed',
        orderId: map['order_id'] as String?,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] Pickup arm / mechanism state during item collection.
///
/// Example JSON:
/// {
///   "type": "storage.pickup_status",
///   "state": "gripping",
///   "fruit": "apple",
///   "attempt": 1,
///   "timestamp": "..."
/// }
// ─────────────────────────────────────────────────────────────────────────────
class PickupStatusMsg {
  const PickupStatusMsg({
    required this.state,
    required this.fruit,
    required this.attempt,
    required this.timestamp,
  });

  final PickupState state;
  final String fruit;
  final int attempt;
  final DateTime timestamp;

  factory PickupStatusMsg.fromMap(Map<String, dynamic> map) => PickupStatusMsg(
    state: PickupState.values.byName(map['state'] as String? ?? 'idle'),
    fruit: map['fruit'] as String? ?? '',
    attempt: map['attempt'] as int? ?? 1,
    timestamp: DateTime.parse(map['timestamp'] as String),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] Vision system detected a fruit.
///
/// Example JSON:
/// {
///   "type": "vision.fruit_detection",
///   "fruit": "apple",
///   "detected": true,
///   "confidence": 0.93,
///   "bounding_box": {"x": 120, "y": 80, "w": 60, "h": 55},
///   "timestamp": "..."
/// }
// ─────────────────────────────────────────────────────────────────────────────
class FruitDetectionMsg {
  const FruitDetectionMsg({
    required this.fruit,
    required this.detected,
    required this.confidence,
    required this.boundingBox,
    required this.timestamp,
  });

  final String fruit;
  final bool detected;

  /// 0.0 – 1.0
  final double confidence;

  /// Pixel bounding box from camera frame: {x, y, w, h}
  final Map<String, int>? boundingBox;
  final DateTime timestamp;

  factory FruitDetectionMsg.fromMap(Map<String, dynamic> map) =>
      FruitDetectionMsg(
        fruit: map['fruit'] as String? ?? '',
        detected: map['detected'] as bool? ?? false,
        confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
        boundingBox: map['bounding_box'] != null
            ? Map<String, int>.from(map['bounding_box'] as Map)
            : null,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] Whether each fruit is physically available at its shelf.
///
/// Example JSON:
/// {
///   "type": "vision.fruit_availability",
///   "availability": {
///     "apple": true,
///     "banana": false,
///     "orange": true
///   },
///   "timestamp": "..."
/// }
// ─────────────────────────────────────────────────────────────────────────────
class FruitAvailabilityMsg {
  const FruitAvailabilityMsg({
    required this.availability,
    required this.timestamp,
  });

  /// fruit_name → isAvailable
  final Map<String, bool> availability;
  final DateTime timestamp;

  factory FruitAvailabilityMsg.fromMap(Map<String, dynamic> map) =>
      FruitAvailabilityMsg(
        availability: Map<String, bool>.from(map['availability'] as Map? ?? {}),
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] A single entry in the event log panel.
/// Covers: MissionEvent, WarningEvent, ErrorEvent, SystemEvent
///
/// Example JSON:
/// {
///   "type": "event.log",
///   "level": "mission",
///   "event_type": "navigatingToItems",
///   "message": "Robot heading to apple shelf",
///   "order_id": "ord_001",
///   "timestamp": "..."
/// }
// ─────────────────────────────────────────────────────────────────────────────
class EventLogMsg {
  const EventLogMsg({
    required this.level,
    required this.eventType,
    required this.message,
    required this.timestamp,
    this.orderId,
    this.metadata,
  });

  final EventLogLevel level;
  final String eventType; // free string — use MissionEventType.name or custom
  final String message;
  final DateTime timestamp;
  final String? orderId;

  /// Optional extra key-value pairs for debug display.
  final Map<String, dynamic>? metadata;

  factory EventLogMsg.fromMap(Map<String, dynamic> map) => EventLogMsg(
    level: EventLogLevel.values.byName(map['level'] as String? ?? 'system'),
    eventType: map['event_type'] as String? ?? '',
    message: map['message'] as String? ?? '',
    timestamp: DateTime.parse(map['timestamp'] as String),
    orderId: map['order_id'] as String?,
    metadata: map['metadata'] as Map<String, dynamic>?,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] RFID card scan result.
///
/// Example JSON:
/// {
///   "type": "rfid.result",
///   "success": true,
///   "rfid_card_id": "RFID_CARD_A1",
///   "order_id": "ord_001",
///   "message": "Identity verified",
///   "timestamp": "..."
/// }
// ─────────────────────────────────────────────────────────────────────────────
class RfidResultMsg {
  const RfidResultMsg({
    required this.success,
    required this.rfidCardId,
    required this.orderId,
    required this.message,
    required this.timestamp,
  });

  final bool success;
  final String rfidCardId;
  final String orderId;
  final String message;
  final DateTime timestamp;

  factory RfidResultMsg.fromMap(Map<String, dynamic> map) => RfidResultMsg(
    success: map['success'] as bool? ?? false,
    rfidCardId: map['rfid_card_id'] as String? ?? '',
    orderId: map['order_id'] as String? ?? '',
    message: map['message'] as String? ?? '',
    timestamp: DateTime.parse(map['timestamp'] as String),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] Robot is requesting payment from the customer.
/// Shown as a modal/bottom sheet on the Order Tracking screen.
///
/// Example JSON:
/// {
///   "type": "payment.required",
///   "order_id": "ord_001",
///   "amount": 42.50,
///   "method": "credits",
///   "user_credits_available": 150.00,
///   "timeout_seconds": 30,
///   "timestamp": "..."
/// }
// ─────────────────────────────────────────────────────────────────────────────
class PaymentRequiredMsg {
  const PaymentRequiredMsg({
    required this.orderId,
    required this.amount,
    required this.method,
    required this.userCreditsAvailable,
    required this.timeoutSeconds,
    required this.timestamp,
  });

  final String orderId;
  final double amount;
  final String method;
  final double userCreditsAvailable;
  final int timeoutSeconds;
  final DateTime timestamp;

  factory PaymentRequiredMsg.fromMap(Map<String, dynamic> map) =>
      PaymentRequiredMsg(
        orderId: map['order_id'] as String,
        amount: (map['amount'] as num).toDouble(),
        method: map['method'] as String? ?? 'credits',
        userCreditsAvailable:
            (map['user_credits_available'] as num?)?.toDouble() ?? 0.0,
        timeoutSeconds: map['timeout_seconds'] as int? ?? 30,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] WebSocket connection state with backend.
///
/// Example JSON:
/// {
///   "type": "connection.status",
///   "state": "connected",
///   "latency_ms": 12,
///   "timestamp": "..."
/// }
// ─────────────────────────────────────────────────────────────────────────────
class ConnectionStatusMsg {
  const ConnectionStatusMsg({
    required this.state,
    required this.latencyMs,
    required this.timestamp,
  });

  final BackendConnectionState state;
  final int latencyMs;
  final DateTime timestamp;

  factory ConnectionStatusMsg.fromMap(Map<String, dynamic> map) =>
      ConnectionStatusMsg(
        state: BackendConnectionState.values.byName(
          map['state'] as String? ?? 'disconnected',
        ),
        latencyMs: map['latency_ms'] as int? ?? 0,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] Battery telemetry from the ESP32 / Pi.
///
/// Example JSON:
/// {
///   "type": "telemetry.battery",
///   "battery_percent": 82,
///   "is_charging": false,
///   "voltage": 11.8,
///   "estimated_minutes_remaining": 45,
///   "timestamp": "..."
/// }
// ─────────────────────────────────────────────────────────────────────────────
class BatteryStatusMsg {
  const BatteryStatusMsg({
    required this.batteryPercent,
    required this.isCharging,
    required this.voltage,
    required this.estimatedMinutesRemaining,
    required this.timestamp,
  });

  final int batteryPercent;
  final bool isCharging;
  final double voltage;
  final int estimatedMinutesRemaining;
  final DateTime timestamp;

  factory BatteryStatusMsg.fromMap(Map<String, dynamic> map) =>
      BatteryStatusMsg(
        batteryPercent: map['battery_percent'] as int? ?? 0,
        isCharging: map['is_charging'] as bool? ?? false,
        voltage: (map['voltage'] as num?)?.toDouble() ?? 0.0,
        estimatedMinutesRemaining:
            map['estimated_minutes_remaining'] as int? ?? 0,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] Overall robot system health heartbeat.
///
/// Example JSON:
/// {
///   "type": "system.health",
///   "level": "nominal",
///   "cpu_percent": 34,
///   "ram_percent": 51,
///   "uptime_seconds": 3600,
///   "ros2_active": true,
///   "micro_ros_active": true,
///   "camera_active": true,
///   "lidar_active": true,
///   "timestamp": "..."
/// }
// ─────────────────────────────────────────────────────────────────────────────
class SystemHealthMsg {
  const SystemHealthMsg({
    required this.level,
    required this.cpuPercent,
    required this.ramPercent,
    required this.uptimeSeconds,
    required this.ros2Active,
    required this.microRosActive,
    required this.cameraActive,
    required this.lidarActive,
    required this.timestamp,
  });

  final SystemHealthLevel level;
  final int cpuPercent;
  final int ramPercent;
  final int uptimeSeconds;
  final bool ros2Active;
  final bool microRosActive;
  final bool cameraActive;
  final bool lidarActive;
  final DateTime timestamp;

  factory SystemHealthMsg.fromMap(Map<String, dynamic> map) => SystemHealthMsg(
    level: SystemHealthLevel.values.byName(
      map['level'] as String? ?? 'offline',
    ),
    cpuPercent: map['cpu_percent'] as int? ?? 0,
    ramPercent: map['ram_percent'] as int? ?? 0,
    uptimeSeconds: map['uptime_seconds'] as int? ?? 0,
    ros2Active: map['ros2_active'] as bool? ?? false,
    microRosActive: map['micro_ros_active'] as bool? ?? false,
    cameraActive: map['camera_active'] as bool? ?? false,
    lidarActive: map['lidar_active'] as bool? ?? false,
    timestamp: DateTime.parse(map['timestamp'] as String),
  );
}

// =============================================================================
// 5. SHARED SUB-MODELS
// =============================================================================

/// Item in an order placement request.
class CartItemPayload {
  const CartItemPayload({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  Map<String, dynamic> toMap() => {
    'product_id': productId,
    'product_name': productName,
    'quantity': quantity,
    'unit_price': unitPrice,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
/// [RECEIVE] Backend acknowledgement of a user.session message.
/// Flutter can use this to confirm the session was registered on the backend,
/// and to refresh credits from the server's authoritative value.
///
/// Example JSON:
/// {
///   "type": "user.session_ack",
///   "user_id": "user_001",
///   "username": "ahmed_hassan",
///   "credits": 150.0,
///   "active_session": true,
///   "message": "Session registered",
///   "timestamp": "2026-05-25T10:00:00.100Z"
/// }
// ─────────────────────────────────────────────────────────────────────────────
class UserSessionAckMsg {
  const UserSessionAckMsg({
    required this.userId,
    required this.username,
    required this.credits,
    required this.activeSession,
    required this.message,
    required this.timestamp,
  });

  final String userId;
  final String username;

  /// Server-authoritative credit balance — use this to update Flutter state.
  final double credits;

  /// false if this was a logout acknowledgement.
  final bool activeSession;
  final String message;
  final DateTime timestamp;

  factory UserSessionAckMsg.fromMap(Map<String, dynamic> map) =>
      UserSessionAckMsg(
        userId: map['user_id'] as String? ?? '',
        username: map['username'] as String? ?? '',
        credits: (map['credits'] as num?)?.toDouble() ?? 0.0,
        activeSession: map['active_session'] as bool? ?? false,
        message: map['message'] as String? ?? '',
        timestamp: map['timestamp'] != null
            ? DateTime.parse(map['timestamp'] as String)
            : DateTime.now(),
      );
}

// =============================================================================
// MESSAGE DISPATCHER HELPER
// Parses any incoming WebSocket message by its 'type' field.
// =============================================================================

/// Converts a raw decoded WebSocket map to the correct message object.
/// Returns null if the type is unrecognised.
Object? parseIncomingMessage(Map<String, dynamic> map) {
  final type = map['type'] as String?;
  switch (type) {
    case kMsgRobotStatus:
      return RobotStatusMsg.fromMap(map);
    case kMsgMissionEvent:
      return MissionEventMsg.fromMap(map);
    case kMsgOrderStatusUpdate:
      return OrderStatusUpdateMsg.fromMap(map);
    case kMsgObstacleStatus:
      return ObstacleStatusMsg.fromMap(map);
    case kMsgPathStatus:
      return PathStatusMsg.fromMap(map);
    case kMsgLidarStatus:
      return LidarStatusMsg.fromMap(map);
    case kMsgProximityStatus:
      return ProximityStatusMsg.fromMap(map);
    case kMsgRobotPose:
      return RobotPoseMsg.fromMap(map);
    case kMsgStorageStatus:
      return StorageStatusMsg.fromMap(map);
    case kMsgStorageOpen:
      return StorageStatusMsg.fromMap(map);
    case kMsgStorageClosed:
      return StorageStatusMsg.fromMap(map);
    case kMsgPickupStatus:
      return PickupStatusMsg.fromMap(map);
    case kMsgFruitDetection:
      return FruitDetectionMsg.fromMap(map);
    case kMsgFruitAvailability:
      return FruitAvailabilityMsg.fromMap(map);
    case kMsgEventLog:
      return EventLogMsg.fromMap(map);
    case kMsgRfidResult:
      return RfidResultMsg.fromMap(map);
    case kMsgPaymentRequired:
      return PaymentRequiredMsg.fromMap(map);
    case kMsgConnectionStatus:
      return ConnectionStatusMsg.fromMap(map);
    case kMsgBatteryStatus:
      return BatteryStatusMsg.fromMap(map);
    case kMsgSystemHealth:
      return SystemHealthMsg.fromMap(map);
    case kMsgUserSessionAck:
      return UserSessionAckMsg.fromMap(map);
    default:
      return null;
  }
}
