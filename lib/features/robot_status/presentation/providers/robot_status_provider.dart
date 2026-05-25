import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/robot_status.dart';
import '../../../../shared/repositories/robot_repository.dart';
import '../../../../infrastructure/dependency_injection/providers.dart';

// ─── Notifier ─────────────────────────────────────────────────────────────────
/// Holds the latest [RobotStatus] received from the WebSocket stream.
/// Uses a [StateNotifier] (NOT autoDispose) so the subscription stays alive
/// for the full app lifetime — screen navigation never drops WS messages.
class RobotStatusNotifier extends StateNotifier<RobotStatus> {
  RobotStatusNotifier(RobotRepository repo) : super(RobotStatus.initial) {
    _sub = repo.watchRobotStatus().listen(
      (status) => state = status,
      onError: (e) {
        // Keep last known state on error; stream will auto-reconnect via WS
      },
    );
  }

  StreamSubscription<RobotStatus>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

/// Primary robot-status provider — gives [RobotStatus] directly.
/// Persists for the full app lifetime (no autoDispose).
/// Widgets just do: `final status = ref.watch(robotStatusProvider);`
final robotStatusProvider =
    StateNotifierProvider<RobotStatusNotifier, RobotStatus>((ref) {
      final repo = ref.watch(robotRepositoryProvider);
      return RobotStatusNotifier(repo);
    });

/// Raw stream provider kept for any code that needs [AsyncValue<RobotStatus>]
/// (e.g., animated loading indicators on first connect).
final robotStatusStreamProvider = StreamProvider<RobotStatus>((ref) {
  final repo = ref.watch(robotRepositoryProvider);
  return repo.watchRobotStatus();
});
