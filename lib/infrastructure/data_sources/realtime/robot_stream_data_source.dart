import 'dart:async';
import '../../../shared/models/robot_status.dart';
import '../../../shared/models/mission_update.dart';
import '../../../shared/models/enums.dart';
import '../../../core/constants/api_constants.dart';
import 'websocket_client.dart';

class RobotStreamDataSource {
  final WebSocketClient _wsClient;

  RobotStreamDataSource(this._wsClient);

  Stream<RobotStatus> watchRobotStatus() {
    return _wsClient.messages
        .where((msg) =>
            msg['type'] == kWsTelemetryBattery ||
            msg['type'] == kWsTelemetryMission ||
            msg['type'] == kWsTelemetryFault ||
            msg['type'] == kWsRobotStorageState)
        .map((msg) {
      return RobotStatus(
        batteryPercent: msg['battery_percent'] as int? ?? 0,
        mode: RobotMode.values.byName(msg['mode'] as String? ?? 'online'),
        missionState:
            MissionState.values.byName(msg['mission_state'] as String? ?? 'idle'),
        storageState:
            StorageState.values.byName(msg['storage_state'] as String? ?? 'closed'),
        faultType: FaultType.values.byName(msg['fault_type'] as String? ?? 'none'),
        activeOrderId: msg['active_order_id'] as String?,
        isConnected: true,
      );
    });
  }

  Stream<MissionUpdate> watchMissionUpdates() {
    return _wsClient.messages
        .where((msg) => msg['type'] == kWsTelemetryMission)
        .map((msg) => MissionUpdate.fromMap(msg));
  }

  Stream<bool> watchRfidVerificationResult() {
    return _wsClient.messages
        .where((msg) => msg['type'] == kWsRobotRfidResult)
        .map((msg) => msg['success'] as bool? ?? false);
  }
}
