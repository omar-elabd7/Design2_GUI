import 'package:equatable/equatable.dart';
import 'enums.dart';

class RobotStatus extends Equatable {
  const RobotStatus({
    required this.batteryPercent,
    required this.mode,
    required this.missionState,
    required this.storageState,
    required this.faultType,
    required this.activeOrderId,
    required this.isConnected,
  });

  final int batteryPercent;
  final RobotMode mode;
  final MissionState missionState;
  final StorageState storageState;
  final FaultType faultType;
  final String? activeOrderId;
  final bool isConnected;

  static const RobotStatus initial = RobotStatus(
    batteryPercent: 0,
    mode: RobotMode.offline,
    missionState: MissionState.idle,
    storageState: StorageState.closed,
    faultType: FaultType.none,
    activeOrderId: null,
    isConnected: false,
  );

  RobotStatus copyWith({
    int? batteryPercent,
    RobotMode? mode,
    MissionState? missionState,
    StorageState? storageState,
    FaultType? faultType,
    String? activeOrderId,
    bool? isConnected,
    bool clearActiveOrder = false,
  }) {
    return RobotStatus(
      batteryPercent: batteryPercent ?? this.batteryPercent,
      mode: mode ?? this.mode,
      missionState: missionState ?? this.missionState,
      storageState: storageState ?? this.storageState,
      faultType: faultType ?? this.faultType,
      activeOrderId: clearActiveOrder
          ? null
          : (activeOrderId ?? this.activeOrderId),
      isConnected: isConnected ?? this.isConnected,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'battery_percent': batteryPercent,
      'mode': mode.name,
      'mission_state': missionState.name,
      'storage_state': storageState.name,
      'fault_type': faultType.name,
      'active_order_id': activeOrderId,
      'is_connected': isConnected,
    };
  }

  factory RobotStatus.fromMap(Map<String, dynamic> map) {
    return RobotStatus(
      batteryPercent: map['battery_percent'] as int,
      mode: RobotMode.values.byName(map['mode'] as String),
      missionState: MissionState.values.byName(map['mission_state'] as String),
      storageState: StorageState.values.byName(map['storage_state'] as String),
      faultType: FaultType.values.byName(map['fault_type'] as String),
      activeOrderId: map['active_order_id'] as String?,
      isConnected: map['is_connected'] as bool,
    );
  }

  @override
  List<Object?> get props => [
    batteryPercent,
    mode,
    missionState,
    storageState,
    faultType,
    activeOrderId,
    isConnected,
  ];
}
