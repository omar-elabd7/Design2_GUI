import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/robot_status_provider.dart';

class StorageStateChip extends ConsumerWidget {
  const StorageStateChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(robotStatusProvider);
    final storageState = status.storageState;

    return StatusBadge(
      label: storageState.label,
      color: storageState.color,
    );
  }
}
