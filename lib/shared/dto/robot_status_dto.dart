import '../models/robot_status.dart';
import '../models/enums.dart';

class RobotStatusDto {
  const RobotStatusDto({
    required this.batteryPercent,
    required this.mode,
    required this.missionState,
    required this.storageState,
    required this.faultType,
    required this.activeOrderId,
    required this.isConnected,
  });

  final int batteryPercent;
  final String mode;
  final String missionState;
  final String storageState;
  final String faultType;
  final String? activeOrderId;
  final bool isConnected;

  RobotStatus toDomain() {
    return RobotStatus(
      batteryPercent: batteryPercent,
      mode: RobotMode.values.byName(mode),
      missionState: MissionState.values.byName(missionState),
      storageState: StorageState.values.byName(storageState),
      faultType: FaultType.values.byName(faultType),
      activeOrderId: activeOrderId,
      isConnected: isConnected,
    );
  }

  factory RobotStatusDto.fromMap(Map<String, dynamic> map) {
    return RobotStatusDto(
      batteryPercent: map['battery_percent'] as int,
      mode: map['mode'] as String,
      missionState: map['mission_state'] as String,
      storageState: map['storage_state'] as String,
      faultType: map['fault_type'] as String? ?? 'none',
      activeOrderId: map['active_order_id'] as String?,
      isConnected: map['is_connected'] as bool? ?? false,
    );
  }
}
