import '../../../shared/models/teleop_command.dart';
import '../../../shared/models/enums.dart';
import '../../../core/errors/app_exceptions.dart';

class WorkerApiDataSource {
  Future<void> sendTeleopCommand(TeleopCommand command) async {
    throw const NetworkException('Real backend not connected yet');
  }

  Future<void> openStorage() async {
    throw const NetworkException('Real backend not connected yet');
  }

  Future<void> closeStorage() async {
    throw const NetworkException('Real backend not connected yet');
  }

  Future<void> setOnlineMode() async {
    throw const NetworkException('Real backend not connected yet');
  }

  Future<void> setOfflineMode() async {
    throw const NetworkException('Real backend not connected yet');
  }

  Stream<StorageState> watchStorageState() {
    throw const NetworkException('Real backend not connected yet');
  }
}
