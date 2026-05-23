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

enum MissionState {
  idle,
  missionReceived,
  preparingOrder,
  navigatingToUser,
  arrived,
  awaitingRfid,
  rfidVerified,
  rfidFailed,
  storageOpened,
  deliveryComplete,
  returningToBase,
  obstacleBlocked,
  lowBattery,
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
}

enum TeleopDirection { forward, backward, left, right, stop }
