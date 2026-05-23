import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../providers/robot_status_provider.dart';

class MissionStatusCard extends ConsumerWidget {
  const MissionStatusCard({super.key});

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
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Mission Status', style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          Text(
            status.missionState.label,
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status.isConnected ? AppColors.success : AppColors.danger,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                status.isConnected ? 'Connected' : 'Disconnected',
                style: AppTextStyles.bodySmall.copyWith(
                  color: status.isConnected
                      ? AppColors.success
                      : AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
