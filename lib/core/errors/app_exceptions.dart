class AppException implements Exception {
  const AppException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'AppException($code): $message';
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
      : super('Invalid username or password', code: 'AUTH_INVALID_CREDENTIALS');
}

class SessionExpiredException extends AuthException {
  const SessionExpiredException()
      : super('Session expired, please login again', code: 'AUTH_SESSION_EXPIRED');
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

class ConnectionTimeoutException extends NetworkException {
  const ConnectionTimeoutException()
      : super('Connection timed out', code: 'NET_TIMEOUT');
}

class WebSocketException extends NetworkException {
  const WebSocketException(super.message, {super.code});
}

class OrderException extends AppException {
  const OrderException(super.message, {super.code});
}

class InsufficientCreditsException extends OrderException {
  const InsufficientCreditsException()
      : super('Insufficient credits for this order', code: 'ORDER_INSUFFICIENT_CREDITS');
}

class OutOfStockException extends OrderException {
  const OutOfStockException(String productName)
      : super('$productName is out of stock', code: 'ORDER_OUT_OF_STOCK');
}

class RobotException extends AppException {
  const RobotException(super.message, {super.code});
}

class RobotOfflineException extends RobotException {
  const RobotOfflineException()
      : super('Robot is offline and cannot accept orders', code: 'ROBOT_OFFLINE');
}

class RobotBusyException extends RobotException {
  const RobotBusyException()
      : super('Robot is busy with another mission', code: 'ROBOT_BUSY');
}
