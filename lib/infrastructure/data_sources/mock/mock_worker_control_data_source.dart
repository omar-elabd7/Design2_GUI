import 'dart:async';
import '../../../shared/models/teleop_command.dart';
import '../../../shared/models/enums.dart';
import '../../../core/services/logger_service.dart';

class MockWorkerControlDataSource {
  StorageState _storageState = StorageState.closed;
  final StreamController<StorageState> _storageController =
      StreamController<StorageState>.broadcast();

  GripperState _gripperState = GripperState.closed;
  final StreamController<GripperState> _gripperController =
      StreamController<GripperState>.broadcast();

  Stream<StorageState> get storageStateStream => _storageController.stream;
  Stream<GripperState> get gripperStateStream => _gripperController.stream;

  Future<void> sendTeleopCommand(TeleopCommand command) async {
    logger.debug(
      'Teleop: ${command.direction.name} | '
      'vx=${command.vx}, vy=${command.vy}, w=${command.w}',
    );
  }

  Future<void> openStorage() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _storageState = StorageState.opening;
    _storageController.add(_storageState);
    await Future.delayed(const Duration(milliseconds: 800));
    _storageState = StorageState.open;
    _storageController.add(_storageState);
    logger.info('Storage opened');
  }

  Future<void> closeStorage() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _storageState = StorageState.closing;
    _storageController.add(_storageState);
    await Future.delayed(const Duration(milliseconds: 800));
    _storageState = StorageState.closed;
    _storageController.add(_storageState);
    logger.info('Storage closed');
  }

  Future<void> setOnlineMode() async {
    await Future.delayed(const Duration(milliseconds: 200));
    logger.info('Robot set to ONLINE');
  }

  Future<void> setOfflineMode() async {
    await Future.delayed(const Duration(milliseconds: 200));
    logger.info('Robot set to OFFLINE');
  }

  Future<void> clearFaults() async {
    logger.info('[Mock] Clear faults requested');
  }

  // ── Mechanism ──────────────────────────────────────────────────────────────

  Future<void> setMechanismPosition(String position) async {
    logger.debug('[Mock] Mechanism position: $position');
  }

  // ── Gripper ────────────────────────────────────────────────────────────────

  Future<void> openGripper() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _gripperState = GripperState.opening;
    _gripperController.add(_gripperState);
    await Future.delayed(const Duration(milliseconds: 600));
    _gripperState = GripperState.open;
    _gripperController.add(_gripperState);
    logger.info('[Mock] Gripper opened');
  }

  Future<void> closeGripper() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _gripperState = GripperState.closing;
    _gripperController.add(_gripperState);
    await Future.delayed(const Duration(milliseconds: 600));
    _gripperState = GripperState.closed;
    _gripperController.add(_gripperState);
    logger.info('[Mock] Gripper closed');
  }

  void dispose() {
    _storageController.close();
    _gripperController.close();
  }
}
