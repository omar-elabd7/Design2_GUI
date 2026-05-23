import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/robot_status_provider.dart';

class RobotStatusCard extends ConsumerWidget {
  const RobotStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(robotStatusProvider);

    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Robot Status', style: AppTextStyles.labelMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.smart_toy_outlined,
                  color: AppColors.textSecondary, size: 22),
              const SizedBox(width: 8),
              StatusBadge(
                label: status.mode.label,
                color: status.mode.color,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.directions_run,
                  color: AppColors.textSecondary, size: 22),
              const SizedBox(width: 8),
              StatusBadge(
                label: status.missionState.label,
                color: AppColors.info,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined,
                  color: AppColors.textSecondary, size: 22),
              const SizedBox(width: 8),
              StatusBadge(
                label: status.storageState.label,
                color: status.storageState.color,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
