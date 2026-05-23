abstract class Failure {
  const Failure(this.message);
  final String message;
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class OrderFailure extends Failure {
  const OrderFailure(super.message);
}

class RobotFailure extends Failure {
  const RobotFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
