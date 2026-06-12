import '../models/teleop_command.dart';
import '../models/enums.dart';

abstract interface class WorkerControlRepository {
  Future<void> sendTeleopCommand(TeleopCommand command);
  Future<void> openStorage();
  Future<void> closeStorage();
  Future<void> setOnlineMode();
  Future<void> setOfflineMode();
  Future<void> clearFaults();
  Stream<StorageState> watchStorageState();
}
