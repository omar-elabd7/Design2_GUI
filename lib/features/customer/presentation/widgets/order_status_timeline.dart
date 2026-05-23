import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/enums.dart';
import '../../../../core/utils/extensions.dart';

class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({super.key, required this.currentStatus});
  final OrderStatus currentStatus;

  static const _steps = [
    OrderStatus.pending,
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.navigating,
    OrderStatus.arrived,
    OrderStatus.waitingRfid,
    OrderStatus.unlocked,
    OrderStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexOf(currentStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_steps.length, (i) {
        final step = _steps[i];
        final isDone = currentIndex > i;
        final isCurrent = currentIndex == i;
        final isLast = i == _steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? AppColors.success
                        : isCurrent
                            ? step.color
                            : AppColors.surface,
                    border: Border.all(
                      color: isDone
                          ? AppColors.success
                          : isCurrent
                              ? step.color
                              : AppColors.cardBorder,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isDone
                        ? Icons.check
                        : isCurrent
                            ? Icons.radio_button_checked
                            : Icons.circle_outlined,
                    size: 14,
                    color: isDone || isCurrent
                        ? AppColors.textOnPrimary
                        : AppColors.textMuted,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 32,
                    color: isDone ? AppColors.success : AppColors.cardBorder,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                step.label,
                style: (isCurrent
                        ? AppTextStyles.bodyMedium
                            .copyWith(color: step.color, fontWeight: FontWeight.w600)
                        : isDone
                            ? AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.success)
                            : AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.textMuted)),
              ),
            ),
          ],
        );
      }),
    );
  }
}
