import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../shared/models/order.dart';
import '../../../../shared/models/enums.dart';

/// Right-rail card showing the last / active order timeline.
class ActiveOrderCard extends StatelessWidget {
  const ActiveOrderCard({
    super.key,
    required this.isDark,
    this.activeOrder,
  });

  final bool isDark;
  final Order? activeOrder;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      isDark: isDark,
      glowColor: activeOrder != null ? AppColors.info : null,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Header -----------------------------------------------------
          Row(
            children: [
              Icon(
                Icons.local_shipping_rounded,
                size: 16,
                color: activeOrder != null ? AppColors.info : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                'Active Order',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimary
                      : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (activeOrder == null)
            _EmptyState(isDark: isDark)
          else
            _OrderTimeline(order: activeOrder!, isDark: isDark),
        ],
      ),
    );
  }
}

// --- Empty state -------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 28,
              color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
            ),
            const SizedBox(height: 8),
            Text(
              'No active order',
              style: AppTextStyles.bodySmall.copyWith(
                color:
                    isDark ? AppColors.textMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Order timeline ----------------------------------------------------------

class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({required this.order, required this.isDark});
  final Order order;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final steps = _timelineSteps;
    final activeIdx = _activeStepIndex(order.status);

    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          _TimelineStep(
            label: steps[i].label,
            icon: steps[i].icon,
            isActive: i <= activeIdx,
            isCurrent: i == activeIdx,
            isLast: i == steps.length - 1,
            isDark: isDark,
          ),
      ],
    );
  }

  int _activeStepIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.accepted:
        return 0;
      case OrderStatus.preparing:
        return 1;
      case OrderStatus.navigating:
        return 2;
      case OrderStatus.arrived:
        return 3;
      case OrderStatus.waitingRfid:
        return 4;
      case OrderStatus.unlocked:
      case OrderStatus.completed:
        return 5;
      default:
        return 0;
    }
  }

  static const _timelineSteps = [
    (label: 'Order Placed', icon: Icons.receipt_long_rounded),
    (label: 'Preparing', icon: Icons.inventory_2_rounded),
    (label: 'Navigating', icon: Icons.navigation_rounded),
    (label: 'Arrived', icon: Icons.location_on_rounded),
    (label: 'Awaiting RFID', icon: Icons.credit_card_rounded),
    (label: 'Complete', icon: Icons.check_circle_rounded),
  ];
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isCurrent,
    required this.isLast,
    required this.isDark,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final bool isCurrent;
  final bool isLast;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;
    final inactiveColor =
        isDark ? AppColors.textMuted : AppColors.lightTextMuted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -- Dot + line ---------------------------------------------------
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: isCurrent ? 12 : 8,
                height: isCurrent ? 12 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? activeColor : inactiveColor,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
              if (!isLast)
                Container(
                  width: 1.5,
                  height: 22,
                  color: isActive
                      ? activeColor.withValues(alpha: 0.4)
                      : inactiveColor.withValues(alpha: 0.3),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // -- Label --------------------------------------------------------
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isActive
                    ? (isDark
                        ? AppColors.textPrimary
                        : AppColors.lightTextPrimary)
                    : inactiveColor,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
