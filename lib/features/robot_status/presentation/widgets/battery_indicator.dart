import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/helpers.dart';

class BatteryIndicator extends StatelessWidget {
  const BatteryIndicator({super.key, required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) {
    final color = Helpers.isBatteryCritical(percent)
        ? AppColors.batteryLow
        : Helpers.isBatteryLow(percent)
            ? AppColors.batteryMedium
            : AppColors.batteryHigh;

    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            percent > 80
                ? Icons.battery_full
                : percent > 50
                    ? Icons.battery_5_bar
                    : percent > 30
                        ? Icons.battery_3_bar
                        : percent > 15
                            ? Icons.battery_1_bar
                            : Icons.battery_alert,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 6),
          Text(
            '$percent%',
            style: AppTextStyles.batteryValue.copyWith(color: color),
          ),
          Text('Battery', style: AppTextStyles.labelSmall),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: AppColors.cardBorder,
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
