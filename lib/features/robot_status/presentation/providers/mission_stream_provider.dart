import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/mission_update.dart';
import '../../../../infrastructure/dependency_injection/providers.dart';

final missionUpdatesProvider =
    StreamProvider.autoDispose<List<MissionUpdate>>((ref) async* {
  final repo = ref.watch(robotRepositoryProvider);
  final log = <MissionUpdate>[];
  await for (final update in repo.watchMissionUpdates()) {
    log.add(update);
    yield List.unmodifiable(log);
  }
});
