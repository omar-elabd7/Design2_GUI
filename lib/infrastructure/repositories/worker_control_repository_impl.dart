import '../../shared/repositories/worker_control_repository.dart';
import '../../shared/models/teleop_command.dart';
import '../../shared/models/enums.dart';
import '../data_sources/mock/mock_worker_control_data_source.dart';

class WorkerControlRepositoryImpl implements WorkerControlRepository {
  final MockWorkerControlDataSource _mockDataSource;

  WorkerControlRepositoryImpl(this._mockDataSource);

  @override
  Future<void> sendTeleopCommand(TeleopCommand command) =>
      _mockDataSource.sendTeleopCommand(command);

  @override
  Future<void> openStorage() => _mockDataSource.openStorage();

  @override
  Future<void> closeStorage() => _mockDataSource.closeStorage();

  @override
  Future<void> setOnlineMode() => _mockDataSource.setOnlineMode();

  @override
  Future<void> setOfflineMode() => _mockDataSource.setOfflineMode();

  @override
  Stream<StorageState> watchStorageState() =>
      _mockDataSource.storageStateStream;
}
