import 'package:flutter/material.dart';
import '../../shared/models/enums.dart';
import '../theme/app_colors.dart';

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.outOfStock:
        return 'Out of Stock';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.navigating:
        return 'On the way';
      case OrderStatus.arrived:
        return 'Arrived';
      case OrderStatus.waitingRfid:
        return 'Awaiting RFID';
      case OrderStatus.unlocked:
        return 'Unlocked';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.failed:
        return 'Failed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.failed:
      case OrderStatus.cancelled:
      case OrderStatus.outOfStock:
        return AppColors.danger;
      case OrderStatus.navigating:
      case OrderStatus.preparing:
      case OrderStatus.accepted:
        return AppColors.info;
      case OrderStatus.waitingRfid:
      case OrderStatus.arrived:
        return AppColors.warning;
      case OrderStatus.unlocked:
        return AppColors.primaryLight;
      case OrderStatus.pending:
        return AppColors.textSecondary;
    }
  }
}

extension MissionStateExtension on MissionState {
  String get label {
    switch (this) {
      case MissionState.idle:
        return 'Idle';
      case MissionState.missionReceived:
        return 'Mission Received';
      case MissionState.headingToFruit:
        return 'Heading to Fruit';
      case MissionState.visionChecking:
        return 'Checking Stock';
      case MissionState.storing:
        return 'Collecting Fruit';
      case MissionState.headingToCustomer:
        return 'Heading to Customer';
      case MissionState.rfidAwaiting:
        return 'Awaiting RFID';
      case MissionState.storageOpened:
        return 'Storage Open';
      case MissionState.storageClosed:
        return 'Storage Closed';
      case MissionState.returning:
        return 'Returning to Base';
      case MissionState.failed:
        return 'Failed';
    }
  }
}

extension RobotModeExtension on RobotMode {
  String get label {
    switch (this) {
      case RobotMode.online:
        return 'Online';
      case RobotMode.offline:
        return 'Offline';
      case RobotMode.autonomous:
        return 'Autonomous';
      case RobotMode.manual:
        return 'Manual';
      case RobotMode.emergencyStop:
        return 'Emergency Stop';
    }
  }

  Color get color {
    switch (this) {
      case RobotMode.online:
      case RobotMode.autonomous:
        return AppColors.success;
      case RobotMode.offline:
        return AppColors.textMuted;
      case RobotMode.manual:
        return AppColors.secondary;
      case RobotMode.emergencyStop:
        return AppColors.danger;
    }
  }
}

extension StorageStateExtension on StorageState {
  String get label {
    switch (this) {
      case StorageState.open:
        return 'Open';
      case StorageState.closed:
        return 'Closed';
      case StorageState.opening:
        return 'Opening...';
      case StorageState.closing:
        return 'Closing...';
      case StorageState.fault:
        return 'Fault';
    }
  }

  Color get color {
    switch (this) {
      case StorageState.open:
        return AppColors.success;
      case StorageState.closed:
        return AppColors.textSecondary;
      case StorageState.opening:
      case StorageState.closing:
        return AppColors.warning;
      case StorageState.fault:
        return AppColors.danger;
    }
  }
}

extension FaultTypeExtension on FaultType {
  String get label {
    switch (this) {
      case FaultType.none:
        return 'No Fault';
      case FaultType.obstacleBlocked:
        return 'Obstacle Blocked';
      case FaultType.lowBattery:
        return 'Low Battery';
      case FaultType.criticalBattery:
        return 'Critical Battery';
      case FaultType.outOfStock:
        return 'Out of Stock';
      case FaultType.rfidFailed:
        return 'RFID Verification Failed';
      case FaultType.storageFault:
        return 'Storage Fault';
      case FaultType.communicationLost:
        return 'Communication Lost';
      case FaultType.missionCancelled:
        return 'Mission Cancelled';
      case FaultType.visionFailed:
        return 'Item Out of Stock';
    }
  }
}

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}
