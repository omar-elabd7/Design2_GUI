import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/repositories/robot_repository.dart';
import '../../../shared/models/robot_status.dart';
import '../../../shared/models/mission_update.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/messages/app_messages.dart';
import '../../../core/constants/api_constants.dart';
import '../../data_sources/realtime/websocket_client.dart';

class LiveRobotRepositoryImpl implements RobotRepository {
  final WebSocketClient _ws;

  LiveRobotRepositoryImpl(this._ws);

  // ── Streams ────────────────────────────────────────────────────────────────

  @override
  Stream<RobotStatus> watchRobotStatus() {
    return _ws.messages
        .where((m) => m['type'] == kMsgRobotStatus)
        .map((m) => RobotStatusMsg.fromMap(m))
        .map(
          (msg) => RobotStatus(
            batteryPercent: msg.batteryPercent,
            mode: _safeEnum(RobotMode.values, msg.mode, RobotMode.online),
            missionState: _safeEnum(
              MissionState.values,
              msg.missionState,
              MissionState.idle,
            ),
            storageState: _safeEnum(
              StorageState.values,
              msg.storageState,
              StorageState.closed,
            ),
            faultType: _safeEnum(
              FaultType.values,
              msg.faultType,
              FaultType.none,
            ),
            activeOrderId: msg.activeOrderId,
            isConnected: true,
          ),
        );
  }

  @override
  Stream<MissionUpdate> watchMissionUpdates() {
    return _ws.messages
        .where((m) => m['type'] == kMsgMissionEvent)
        .map(
          (m) => MissionUpdate(
            orderId: m['order_id'] as String? ?? '',
            state: _missionEventToState(m['event'] as String? ?? 'idle'),
            message: m['message'] as String? ?? '',
            timestamp: _parseTs(m['timestamp'] as String?),
          ),
        );
  }

  @override
  Stream<bool> watchRfidVerificationResult() {
    return _ws.messages
        .where((m) => m['type'] == kMsgRfidResult)
        .map((m) => m['success'] as bool? ?? false);
  }

  // ── Commands ───────────────────────────────────────────────────────────────

  @override
  Future<void> sendOrder({
    required String orderId,
    required String userId,
    required String authorizedRfid,
    required List<Map<String, dynamic>> items,
  }) async {
    // Server auto-starts mission on POST /orders.
    // Send mission.start over WS as a safety net.
    _ws.send({'type': kMsgMissionStart, 'order_id': orderId});
  }

  @override
  Future<void> setRobotMode(RobotMode mode) async {
    await http
        .post(
          Uri.parse('$kBaseUrl$kRobotModeEndpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'mode': mode.name}),
        )
        .timeout(kHttpTimeout);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static T _safeEnum<T extends Enum>(List<T> values, String name, T fallback) {
    try {
      return values.byName(name);
    } catch (_) {
      return fallback;
    }
  }

  static MissionState _missionEventToState(String event) {
    const map = {
      'orderReceived': MissionState.missionReceived,
      'navigatingToItems': MissionState.navigatingToUser,
      'returningToDropoff': MissionState.arrived,
      'waitingForRfid': MissionState.awaitingRfid,
      'rfidVerification': MissionState.rfidVerified,
      'deliveryComplete': MissionState.deliveryComplete,
      'error': MissionState.failed,
      'idle': MissionState.idle,
    };
    return map[event] ?? MissionState.idle;
  }

  static DateTime _parseTs(String? ts) {
    if (ts == null) return DateTime.now();
    try {
      return DateTime.parse(ts);
    } catch (_) {
      return DateTime.now();
    }
  }
}
