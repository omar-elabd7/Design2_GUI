import '../../../../shared/models/mission_update.dart';
import '../../../../shared/repositories/robot_repository.dart';

class WatchMissionUpdatesUsecase {
  final RobotRepository _repo;

  WatchMissionUpdatesUsecase(this._repo);

  Stream<MissionUpdate> call() => _repo.watchMissionUpdates();
}
