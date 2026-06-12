import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/teleop_command.dart';
import '../../../../shared/models/enums.dart';
import '../../../../infrastructure/dependency_injection/providers.dart';
import '../../../../core/constants/app_constants.dart';

class TeleopNotifier extends StateNotifier<TeleopDirection> {
  TeleopNotifier(this._ref) : super(TeleopDirection.stop);

  final Ref _ref;
  Timer? _sendTimer;
  final Set<LogicalKeyboardKey> _held = {};

  static const double _lin = 0.3;
  static const double _linDiag = 0.212; // 0.3 / sqrt(2)
  static const double _ang = 0.5;

  /// Called on every KeyDownEvent / KeyUpEvent from the UI.
  void onKeyDown(LogicalKeyboardKey k) {
    _held.add(k);
    _evaluate();
  }

  void onKeyUp(LogicalKeyboardKey k) {
    _held.remove(k);
    _evaluate();
  }

  void _evaluate() {
    final w =
        _held.contains(LogicalKeyboardKey.keyW) ||
        _held.contains(LogicalKeyboardKey.arrowUp);
    final s =
        _held.contains(LogicalKeyboardKey.keyS) ||
        _held.contains(LogicalKeyboardKey.arrowDown);
    final a =
        _held.contains(LogicalKeyboardKey.keyA) ||
        _held.contains(LogicalKeyboardKey.arrowLeft);
    final d =
        _held.contains(LogicalKeyboardKey.keyD) ||
        _held.contains(LogicalKeyboardKey.arrowRight);
    final q = _held.contains(LogicalKeyboardKey.keyQ);
    final e = _held.contains(LogicalKeyboardKey.keyE);

    TeleopDirection dir;
    if (w && a && !s && !d) {
      dir = TeleopDirection.forwardLeft;
    } else if (w && d && !s && !a) {
      dir = TeleopDirection.forwardRight;
    } else if (s && a && !w && !d) {
      dir = TeleopDirection.backwardLeft;
    } else if (s && d && !w && !a) {
      dir = TeleopDirection.backwardRight;
    } else if (w && !s) {
      dir = TeleopDirection.forward;
    } else if (s && !w) {
      dir = TeleopDirection.backward;
    } else if (a && !d) {
      dir = TeleopDirection.left;
    } else if (d && !a) {
      dir = TeleopDirection.right;
    } else if (q && !e) {
      dir = TeleopDirection.rotateLeft;
    } else if (e && !q) {
      dir = TeleopDirection.rotateRight;
    } else {
      dir = TeleopDirection.stop;
    }

    if (dir == TeleopDirection.stop) {
      _sendTimer?.cancel();
      state = TeleopDirection.stop;
      _sendCommand(TeleopDirection.stop);
    } else if (dir != state) {
      state = dir;
      _sendTimer?.cancel();
      _sendCommand(dir);
      _sendTimer = Timer.periodic(
        const Duration(milliseconds: kTeleopIntervalMs),
        (_) => _sendCommand(dir),
      );
    }
  }

  // Keep these for on-screen button taps (D-pad touch)
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
    _held.clear();
    state = TeleopDirection.stop;
    _sendCommand(TeleopDirection.stop);
  }

  void _sendCommand(TeleopDirection direction) {
    double lin = 0.0;
    double ang = 0.0;
    switch (direction) {
      case TeleopDirection.forward:
        lin = _lin;
      case TeleopDirection.backward:
        lin = -_lin;
      case TeleopDirection.left:
        ang = _ang;
      case TeleopDirection.right:
        ang = -_ang;
      case TeleopDirection.forwardLeft:
        lin = _linDiag;
        ang = _ang;
      case TeleopDirection.forwardRight:
        lin = _linDiag;
        ang = -_ang;
      case TeleopDirection.backwardLeft:
        lin = -_linDiag;
        ang = _ang;
      case TeleopDirection.backwardRight:
        lin = -_linDiag;
        ang = -_ang;
      case TeleopDirection.rotateLeft:
        ang = _ang;
      case TeleopDirection.rotateRight:
        ang = -_ang;
      case TeleopDirection.stop:
        break;
    }
    final command = TeleopCommand(
      direction: direction,
      linearSpeed: lin,
      angularSpeed: ang,
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
