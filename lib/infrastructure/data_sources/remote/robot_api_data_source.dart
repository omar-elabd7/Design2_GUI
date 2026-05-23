import '../../../shared/models/robot_status.dart';
import '../../../shared/models/mission_update.dart';
import '../../../shared/models/enums.dart';
import '../../../core/errors/app_exceptions.dart';

class RobotApiDataSource {
  Stream<RobotStatus> watchRobotStatus() {
    throw const NetworkException('Real backend not connected yet');
  }

  Stream<MissionUpdate> watchMissionUpdates() {
    throw const NetworkException('Real backend not connected yet');
  }

  Stream<bool> watchRfidVerificationResult() {
    throw const NetworkException('Real backend not connected yet');
  }

  Future<void> sendOrder({
    required String orderId,
    required String userId,
    required String authorizedRfid,
    required List<Map<String, dynamic>> items,
  }) async {
    throw const NetworkException('Real backend not connected yet');
  }

  Future<void> setRobotMode(RobotMode mode) async {
    throw const NetworkException('Real backend not connected yet');
  }
}
