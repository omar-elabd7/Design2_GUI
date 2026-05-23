import '../../../../shared/repositories/worker_control_repository.dart';

class OpenStorageUsecase {
  final WorkerControlRepository _repo;

  OpenStorageUsecase(this._repo);

  Future<void> call() => _repo.openStorage();
}
