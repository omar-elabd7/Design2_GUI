import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/glass_panel.dart';
import '../../../../../shared/models/order_item.dart';
import '../../../../../shared/models/enums.dart';
import '../../../../../core/utils/formatters.dart';

/// Order items card showing requested items, collected status, and totals.
class OrderItemsCard extends StatelessWidget {
  const OrderItemsCard({
    super.key,
    required this.items,
    required this.missionState,
    required this.totalPrice,
    this.isDark = true,
  });

  final List<OrderItem> items;
  final MissionState missionState;
  final double totalPrice;
  final bool isDark;

  /// Items considered "collected" once delivery is past the preparing stage.
  bool _isCollected(int index) {
    const collectedStates = {
      MissionState.navigatingToUser,
      MissionState.arrived,
      MissionState.awaitingRfid,
      MissionState.rfidVerified,
      MissionState.storageOpened,
      MissionState.deliveryComplete,
      MissionState.returningToBase,
    };
    return collectedStates.contains(missionState);
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 16,
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: 8),
              Text(
                'ORDER ITEMS',
                style: AppTextStyles.labelLarge.copyWith(
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${items.length} items',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 10,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final collected = _isCollected(i);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // checkmark / pending
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: collected
                          ? AppColors.success.withValues(alpha: 0.15)
                          : isDark
                          ? AppColors.surface
                          : AppColors.lightSurface,
                      border: Border.all(
                        color: collected
                            ? AppColors.success
                            : isDark
                            ? AppColors.cardBorder
                            : AppColors.lightCardBorder,
                        width: 1.5,
                      ),
                    ),
                    child: collected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: AppColors.success,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  // name + qty
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            color: collected
                                ? isDark
                                      ? AppColors.textPrimary
                                      : AppColors.lightTextPrimary
                                : isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        Text(
                          'Qty: ${item.quantity}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.textMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // price
                  Text(
                    Formatters.formatPrice(item.subtotal),
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 6),
          Divider(
            color: (isDark ? AppColors.cardBorder : AppColors.lightCardBorder)
                .withValues(alpha: 0.5),
            height: 1,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                Formatters.formatPrice(totalPrice),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
