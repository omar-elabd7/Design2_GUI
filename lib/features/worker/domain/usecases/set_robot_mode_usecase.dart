import '../../../../shared/models/enums.dart';
import '../../../../shared/repositories/worker_control_repository.dart';

class SetRobotModeUsecase {
  final WorkerControlRepository _repo;

  SetRobotModeUsecase(this._repo);

  Future<void> callOnline() => _repo.setOnlineMode();

  Future<void> callOffline() => _repo.setOfflineMode();

  Future<void> call(RobotMode mode) {
    switch (mode) {
      case RobotMode.online:
        return _repo.setOnlineMode();
      case RobotMode.offline:
        return _repo.setOfflineMode();
      default:
        return Future.value();
    }
  }
}
