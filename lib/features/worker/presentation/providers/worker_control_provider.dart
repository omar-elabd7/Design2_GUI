import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/enums.dart';
import '../../../../infrastructure/dependency_injection/providers.dart';

class WorkerControlNotifier extends StateNotifier<RobotMode> {
  WorkerControlNotifier(this._ref) : super(RobotMode.online);

  final Ref _ref;

  Future<void> setOnline() async {
    await _ref.read(workerControlRepositoryProvider).setOnlineMode();
    await _ref.read(robotRepositoryProvider).setRobotMode(RobotMode.online);
    state = RobotMode.online;
  }

  Future<void> setOffline() async {
    await _ref.read(workerControlRepositoryProvider).setOfflineMode();
    await _ref.read(robotRepositoryProvider).setRobotMode(RobotMode.offline);
    state = RobotMode.offline;
  }

  Future<void> setManual() async {
    await _ref.read(robotRepositoryProvider).setRobotMode(RobotMode.manual);
    state = RobotMode.manual;
  }

  Future<void> setAutonomous() async {
    await _ref.read(robotRepositoryProvider).setRobotMode(RobotMode.autonomous);
    state = RobotMode.online;
  }

  Future<void> openStorage() async {
    await _ref.read(workerControlRepositoryProvider).openStorage();
  }

  Future<void> closeStorage() async {
    await _ref.read(workerControlRepositoryProvider).closeStorage();
  }

  Future<void> clearFaults() async {
    await _ref.read(workerControlRepositoryProvider).clearFaults();
  }

  // ── Mechanism position (one-shot) ─────────────────────────────────────────

  Future<void> setMechanismPosition(String position) async {
    await _ref
        .read(workerControlRepositoryProvider)
        .setMechanismPosition(position);
  }

  // ── Gripper ───────────────────────────────────────────────────────────────

  Future<void> openGripper() async {
    await _ref.read(workerControlRepositoryProvider).openGripper();
  }

  Future<void> closeGripper() async {
    await _ref.read(workerControlRepositoryProvider).closeGripper();
  }
}

final workerControlProvider =
    StateNotifierProvider<WorkerControlNotifier, RobotMode>((ref) {
      return WorkerControlNotifier(ref);
    });

final workerStorageStateProvider = StreamProvider<StorageState>((ref) {
  final repo = ref.watch(workerControlRepositoryProvider);
  return repo.watchStorageState();
});

final workerGripperStateProvider = StreamProvider<GripperState>((ref) {
  final repo = ref.watch(workerControlRepositoryProvider);
  return repo.watchGripperState();
});
