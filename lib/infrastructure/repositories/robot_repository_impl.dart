import '../../shared/repositories/robot_repository.dart';
import '../../shared/models/robot_status.dart';
import '../../shared/models/mission_update.dart';
import '../../shared/models/enums.dart';
import '../data_sources/mock/mock_robot_data_source.dart';

class RobotRepositoryImpl implements RobotRepository {
  final MockRobotDataSource _mockDataSource;

  RobotRepositoryImpl(this._mockDataSource);

  @override
  Stream<RobotStatus> watchRobotStatus() => _mockDataSource.statusStream;

  @override
  Stream<MissionUpdate> watchMissionUpdates() => _mockDataSource.missionStream;

  @override
  Stream<bool> watchRfidVerificationResult() => _mockDataSource.rfidStream;

  @override
  Future<void> sendOrder({
    required String orderId,
    required String userId,
    required String authorizedRfid,
    required List<Map<String, dynamic>> items,
  }) =>
      _mockDataSource.sendOrder(
        orderId: orderId,
        userId: userId,
        authorizedRfid: authorizedRfid,
        items: items,
      );

  @override
  Future<void> setRobotMode(RobotMode mode) => _mockDataSource.setRobotMode(mode);
}
