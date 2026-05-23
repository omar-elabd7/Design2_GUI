import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/teleop_command.dart';
import '../../../../shared/models/enums.dart';
import '../../../../infrastructure/dependency_injection/providers.dart';
import '../../../../core/constants/app_constants.dart';

class TeleopNotifier extends StateNotifier<TeleopDirection> {
  TeleopNotifier(this._ref) : super(TeleopDirection.stop);

  final Ref _ref;
  Timer? _sendTimer;

  static const double _linearSpeed = 0.3;
  static const double _angularSpeed = 0.5;

  void startCommand(TeleopDirection direction) {
    state = direction;
    _sendTimer?.cancel();
    _sendCommand(direction);
    _sendTimer = Timer.periodic(
      const Duration(milliseconds: kTeleopIntervalMs),
      (_) => _sendCommand(direction),
    );
  }

  void stopCommand() {
    _sendTimer?.cancel();
    state = TeleopDirection.stop;
    _sendCommand(TeleopDirection.stop);
  }

  void _sendCommand(TeleopDirection direction) {
    final command = TeleopCommand(
      direction: direction,
      linearSpeed: direction == TeleopDirection.forward
          ? _linearSpeed
          : direction == TeleopDirection.backward
          ? -_linearSpeed
          : 0.0,
      angularSpeed: direction == TeleopDirection.left
          ? _angularSpeed
          : direction == TeleopDirection.right
          ? -_angularSpeed
          : 0.0,
    );
    _ref.read(workerControlRepositoryProvider).sendTeleopCommand(command);
  }

  @override
  void dispose() {
    _sendTimer?.cancel();
    super.dispose();
  }
}

final teleopProvider = StateNotifierProvider<TeleopNotifier, TeleopDirection>((
  ref,
) {
  return TeleopNotifier(ref);
});
