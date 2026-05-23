import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../infrastructure/data_sources/mock/mock_robot_data_source.dart';
import '../../../../infrastructure/dependency_injection/providers.dart';

enum DebugEvent { obstacle, lowBattery, rfidFail, outOfStock }

class DebugNotifier extends StateNotifier<bool> {
  final MockRobotDataSource _mockRobot;

  DebugNotifier(this._mockRobot) : super(false);

  Future<void> simulate(DebugEvent event) async {
    state = true;
    const debugOrderId = 'DEBUG_ORDER';
    switch (event) {
      case DebugEvent.obstacle:
        _mockRobot.simulateObstacle(debugOrderId);
      case DebugEvent.lowBattery:
        _mockRobot.simulateLowBattery();
      case DebugEvent.rfidFail:
        _mockRobot.simulateRfidFail(debugOrderId);
      case DebugEvent.outOfStock:
        _mockRobot.simulateOutOfStock(debugOrderId);
    }
    await Future.delayed(const Duration(milliseconds: 300));
    state = false;
  }
}

final debugProvider = StateNotifierProvider<DebugNotifier, bool>((ref) {
  final mockRobot = ref.watch(mockRobotDataSourceProvider);
  return DebugNotifier(mockRobot);
});
