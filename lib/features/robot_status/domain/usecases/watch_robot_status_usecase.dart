import '../../../../shared/models/robot_status.dart';
import '../../../../shared/repositories/robot_repository.dart';

class WatchRobotStatusUsecase {
  final RobotRepository _repo;

  WatchRobotStatusUsecase(this._repo);

  Stream<RobotStatus> call() => _repo.watchRobotStatus();
}
