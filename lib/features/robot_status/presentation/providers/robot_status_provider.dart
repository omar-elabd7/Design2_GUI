import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/robot_status.dart';
import '../../../../infrastructure/dependency_injection/providers.dart';

final robotStatusProvider =
    StreamProvider.autoDispose<RobotStatus>((ref) {
  final repo = ref.watch(robotRepositoryProvider);
  return repo.watchRobotStatus();
}).select((value) => value.asData?.value ?? RobotStatus.initial);

final robotStatusStreamProvider =
    StreamProvider<RobotStatus>((ref) {
  final repo = ref.watch(robotRepositoryProvider);
  return repo.watchRobotStatus();
});
