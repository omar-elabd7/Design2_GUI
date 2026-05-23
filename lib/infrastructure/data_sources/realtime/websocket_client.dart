import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/logger_service.dart';

class WebSocketClient {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  Timer? _reconnectTimer;
  bool _intentionallyDisconnected = false;

  Stream<Map<String, dynamic>> get messages => _messageController.stream;
  bool get isConnected => _channel != null;

  Future<void> connect() async {
    _intentionallyDisconnected = false;
    try {
      _channel = WebSocketChannel.connect(Uri.parse(kWebSocketUrl));
      logger.info('WebSocket connecting to $kWebSocketUrl', tag: 'WS');

      _channel!.stream.listen(
        (data) {
          try {
            final decoded = jsonDecode(data as String) as Map<String, dynamic>;
            _messageController.add(decoded);
          } catch (e) {
            logger.warning('Failed to decode WS message: $e', tag: 'WS');
          }
        },
        onDone: () {
          logger.warning('WebSocket disconnected', tag: 'WS');
          _channel = null;
          if (!_intentionallyDisconnected) {
            _scheduleReconnect();
          }
        },
        onError: (error) {
          logger.error('WebSocket error', exception: error, tag: 'WS');
          _channel = null;
          if (!_intentionallyDisconnected) {
            _scheduleReconnect();
          }
        },
      );
    } catch (e) {
      logger.error('WebSocket connect failed', exception: e, tag: 'WS');
      _scheduleReconnect();
    }
  }

  void send(Map<String, dynamic> message) {
    if (_channel == null) {
      logger.warning('WS send skipped: not connected', tag: 'WS');
      return;
    }
    try {
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      logger.error('WS send error', exception: e, tag: 'WS');
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(kWebSocketReconnectDelay, connect);
  }

  Future<void> disconnect() async {
    _intentionallyDisconnected = true;
    _reconnectTimer?.cancel();
    await _channel?.sink.close();
    _channel = null;
    logger.info('WebSocket disconnected intentionally', tag: 'WS');
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _messageController.close();
  }
}
