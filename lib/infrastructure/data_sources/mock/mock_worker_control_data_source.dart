import 'dart:async';
import '../../../shared/models/teleop_command.dart';
import '../../../shared/models/enums.dart';
import '../../../core/services/logger_service.dart';

class MockWorkerControlDataSource {
  StorageState _storageState = StorageState.closed;
  final StreamController<StorageState> _storageController =
      StreamController<StorageState>.broadcast();

  Stream<StorageState> get storageStateStream => _storageController.stream;

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

  void dispose() {
    _storageController.close();
  }
}
