import '../models/robot_status.dart';
import '../models/mission_update.dart';
import '../models/enums.dart';

abstract interface class RobotRepository {
  Stream<RobotStatus> watchRobotStatus();
  Stream<MissionUpdate> watchMissionUpdates();
  Stream<bool> watchRfidVerificationResult();
  Future<void> sendOrder({
    required String orderId,
    required String userId,
    required String authorizedRfid,
    required List<Map<String, dynamic>> items,
  });
  Future<void> setRobotMode(RobotMode mode);
}
