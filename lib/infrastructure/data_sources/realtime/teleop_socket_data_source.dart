import '../../../shared/models/teleop_command.dart';
import '../../../core/constants/api_constants.dart';
import 'websocket_client.dart';

class TeleopSocketDataSource {
  final WebSocketClient _wsClient;

  TeleopSocketDataSource(this._wsClient);

  void sendCommand(TeleopCommand command) {
    final payload = command.toMap();
    payload['type'] = kWsTeleopCommand;
    _wsClient.send(payload);
  }

  void sendStop() {
    sendCommand(TeleopCommand.stop);
  }
}
