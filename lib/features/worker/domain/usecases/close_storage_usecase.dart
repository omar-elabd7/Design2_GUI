import '../../../../shared/repositories/worker_control_repository.dart';

class CloseStorageUsecase {
  final WorkerControlRepository _repo;

  CloseStorageUsecase(this._repo);

  Future<void> call() => _repo.closeStorage();
}
