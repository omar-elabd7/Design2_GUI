import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/helpers.dart';
import '../../../robot_status/presentation/providers/robot_status_provider.dart';

class BatteryStatusCard extends ConsumerWidget {
  const BatteryStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(robotStatusProvider);
    final percent = status.batteryPercent;
    final isCritical = Helpers.isBatteryCritical(percent);
    final isLow = Helpers.isBatteryLow(percent);

    final color = isCritical
        ? AppColors.batteryLow
        : isLow
            ? AppColors.batteryMedium
            : AppColors.batteryHigh;

    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        border: Border.all(
          color: isCritical ? AppColors.danger : AppColors.cardBorder,
          width: isCritical ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCritical
                ? Icons.battery_alert
                : isLow
                    ? Icons.battery_1_bar
                    : Icons.battery_full,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Battery', style: AppTextStyles.labelMedium),
                Row(
                  children: [
                    Text(
                      '$percent%',
                      style:
                          AppTextStyles.headlineMedium.copyWith(color: color),
                    ),
                    if (isCritical) ...[
                      const SizedBox(width: 8),
                      Text(
                        'CRITICAL',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.danger),
                      ),
                    ] else if (isLow) ...[
                      const SizedBox(width: 8),
                      Text(
                        'LOW',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.warning),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    backgroundColor: AppColors.cardBorder,
                    color: color,
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
