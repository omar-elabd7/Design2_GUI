import '../../../../shared/models/teleop_command.dart';
import '../../../../shared/repositories/worker_control_repository.dart';

class SendTeleopCommandUsecase {
  final WorkerControlRepository _repo;

  SendTeleopCommandUsecase(this._repo);

  Future<void> call(TeleopCommand command) => _repo.sendTeleopCommand(command);
}
