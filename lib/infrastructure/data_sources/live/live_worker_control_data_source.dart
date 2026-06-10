import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/services/logger_service.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/models/teleop_command.dart';
import '../../data_sources/realtime/websocket_client.dart';

/// Live implementation — sends commands directly to the Pi server.
///
/// Commands that are instant (teleop, storage) go over WebSocket for
/// minimum latency. Mode changes go over HTTP so they are acknowledged.
class LiveWorkerControlDataSource {
  LiveWorkerControlDataSource(this._ws);
  final WebSocketClient _ws;

  // ── Teleop ──────────────────────────────────────────────────────────────────

  Future<void> sendTeleopCommand(TeleopCommand command) async {
    _ws.send(command.toMap());
  }

  // ── Storage ─────────────────────────────────────────────────────────────────

  Future<void> openStorage() async {
    await _httpPost(kStorageOpenEndpoint);
  }

  Future<void> closeStorage() async {
    await _httpPost(kStorageCloseEndpoint);
  }

  // ── Robot mode ───────────────────────────────────────────────────────────────

  Future<void> setMode(RobotMode mode) async {
    await _httpPost(kRobotModeEndpoint, body: {'mode': mode.name});
  }

  // ── Storage state stream (via WS) ────────────────────────────────────────────

  Stream<StorageState> watchStorageState() {
    return _ws.messages.where((m) => m['type'] == kWsRobotStorageState).map((
      m,
    ) {
      final raw = m['state'] as String? ?? 'closed';
      return StorageState.values.firstWhere(
        (s) => s.name == raw,
        orElse: () => StorageState.closed,
      );
    });
  }

  // ── helpers ──────────────────────────────────────────────────────────────────

  Future<void> _httpPost(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final res = await http
          .post(
            Uri.parse('$kBaseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(kHttpTimeout);
      if (res.statusCode != 200) {
        logger.warning(
          'HTTP $endpoint returned ${res.statusCode}',
          tag: 'LiveWorkerCtrl',
        );
      }
    } catch (e) {
      logger.error(
        'HTTP $endpoint failed',
        exception: e,
        tag: 'LiveWorkerCtrl',
      );
    }
  }
}
