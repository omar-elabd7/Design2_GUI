import '../../../shared/repositories/worker_control_repository.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/models/teleop_command.dart';
import '../data_sources/live/live_worker_control_data_source.dart';

class LiveWorkerControlRepositoryImpl implements WorkerControlRepository {
  LiveWorkerControlRepositoryImpl(this._src);
  final LiveWorkerControlDataSource _src;

  @override
  Future<void> sendTeleopCommand(TeleopCommand command) =>
      _src.sendTeleopCommand(command);

  @override
  Future<void> openStorage() => _src.openStorage();

  @override
  Future<void> closeStorage() => _src.closeStorage();

  @override
  Future<void> setOnlineMode() => _src.setMode(RobotMode.online);

  @override
  Future<void> setOfflineMode() => _src.setMode(RobotMode.offline);

  @override
  Future<void> clearFaults() => _src.clearFaults();

  @override
  Stream<StorageState> watchStorageState() => _src.watchStorageState();
}
