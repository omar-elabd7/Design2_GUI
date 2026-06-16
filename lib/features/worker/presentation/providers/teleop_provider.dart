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
    final a = _held.contains(LogicalKeyboardKey.keyA); // arrow keys → mechanism
    final d = _held.contains(LogicalKeyboardKey.keyD); // arrow keys → mechanism
    final q = _held.contains(LogicalKeyboardKey.keyQ);
    final e = _held.contains(LogicalKeyboardKey.keyE);

    TeleopDirection dir;
    // ── linear + rotation combos (checked first) ──────────────────────
    if (w && q && !s) {
      dir = TeleopDirection.forwardRotateLeft;
    } else if (w && e && !s) {
      dir = TeleopDirection.forwardRotateRight;
    } else if (s && q && !w) {
      dir = TeleopDirection.backwardRotateLeft;
    } else if (s && e && !w) {
      dir = TeleopDirection.backwardRotateRight;
    } else if (a && q && !d) {
      dir = TeleopDirection.leftRotateLeft;
    } else if (a && e && !d) {
      dir = TeleopDirection.leftRotateRight;
    } else if (d && q && !a) {
      dir = TeleopDirection.rightRotateLeft;
    } else if (d && e && !a) {
      dir = TeleopDirection.rightRotateRight;
      // ── diagonal (vx + vy) ────────────────────────────────────────────
    } else if (w && a && !s && !d) {
      dir = TeleopDirection.forwardLeft;
    } else if (w && d && !s && !a) {
      dir = TeleopDirection.forwardRight;
    } else if (s && a && !w && !d) {
      dir = TeleopDirection.backwardLeft;
    } else if (s && d && !w && !a) {
      dir = TeleopDirection.backwardRight;
      // ── single axis ───────────────────────────────────────────────────
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
    int vx = 0, vy = 0, w = 0;
    switch (direction) {
      // ── single axis ────────────────────────────────────────────────
      case TeleopDirection.forward:
        vx = 1;
      case TeleopDirection.backward:
        vx = -1;
      case TeleopDirection.left:
        vy = -1;
      case TeleopDirection.right:
        vy = 1;
      // ── diagonal ───────────────────────────────────────────────────
      case TeleopDirection.forwardLeft:
        vx = 1;
        vy = -1;
      case TeleopDirection.forwardRight:
        vx = 1;
        vy = 1;
      case TeleopDirection.backwardLeft:
        vx = -1;
        vy = -1;
      case TeleopDirection.backwardRight:
        vx = -1;
        vy = 1;
      // ── pure rotation ──────────────────────────────────────────────
      case TeleopDirection.rotateLeft:
        w = -1;
      case TeleopDirection.rotateRight:
        w = 1;
      // ── linear + rotation ──────────────────────────────────────────
      case TeleopDirection.forwardRotateLeft:
        vx = 1;
        w = -1;
      case TeleopDirection.forwardRotateRight:
        vx = 1;
        w = 1;
      case TeleopDirection.backwardRotateLeft:
        vx = -1;
        w = -1;
      case TeleopDirection.backwardRotateRight:
        vx = -1;
        w = 1;
      case TeleopDirection.leftRotateLeft:
        vy = -1;
        w = -1;
      case TeleopDirection.leftRotateRight:
        vy = -1;
        w = 1;
      case TeleopDirection.rightRotateLeft:
        vy = 1;
        w = -1;
      case TeleopDirection.rightRotateRight:
        vy = 1;
        w = 1;
      case TeleopDirection.stop:
        break;
    }
    final command = TeleopCommand(direction: direction, vx: vx, vy: vy, w: w);
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
