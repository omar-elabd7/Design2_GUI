enum UserRole { customer, worker }

enum OrderStatus {
  pending,
  accepted,
  outOfStock,
  preparing,
  navigating,
  arrived,
  waitingRfid,
  unlocked,
  completed,
  failed,
  cancelled,
}

enum RobotMode { online, offline, autonomous, manual, emergencyStop }

enum StorageState { open, closed, opening, closing, fault }

enum GripperState { open, closed, opening, closing }

enum MissionState {
  idle,
  missionReceived,
  headingToFruit,
  visionChecking,
  storing,
  headingToCustomer,
  rfidAwaiting,
  storageOpened,
  storageClosed,
  returning,
  failed,
}

enum FaultType {
  none,
  obstacleBlocked,
  lowBattery,
  criticalBattery,
  outOfStock,
  rfidFailed,
  storageFault,
  communicationLost,
  missionCancelled,
  visionFailed,
}

enum TeleopDirection {
  // ── single axis ──────────────────────────────────────────
  forward,
  backward,
  left,
  right,
  // ── diagonal (vx + vy) ───────────────────────────────────
  forwardLeft,
  forwardRight,
  backwardLeft,
  backwardRight,
  // ── pure rotation ────────────────────────────────────────
  rotateLeft,
  rotateRight,
  // ── linear + rotation (vx/vy + w) ───────────────────────
  forwardRotateLeft, // W + Q
  forwardRotateRight, // W + E
  backwardRotateLeft, // S + Q
  backwardRotateRight, // S + E
  leftRotateLeft, // A + Q
  leftRotateRight, // A + E
  rightRotateLeft, // D + Q
  rightRotateRight, // D + E
  // ── stop ─────────────────────────────────────────────────
  stop,
}
