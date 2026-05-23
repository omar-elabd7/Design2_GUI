import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/routing/route_names.dart';
import '../providers/cart_provider.dart';

/// Right-rail cart summary card ? always visible.
///
/// Shows total items, total cost, credits left, and checkout button.
class CartSummaryCard extends ConsumerWidget {
  const CartSummaryCard({
    super.key,
    required this.isDark,
    required this.credits,
  });

  final bool isDark;
  final double credits;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalCost = ref.watch(cartTotalProvider);
    final itemCount = ref.watch(cartItemCountProvider);
    final remaining = credits - totalCost;

    return GlassPanel(
      isDark: isDark,
      glowColor: AppColors.primary,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Header -----------------------------------------------------
          Row(
            children: [
              Icon(Icons.shopping_cart_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Cart Summary',
                style: AppTextStyles.headlineSmall.copyWith(
                  color:
                      isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // -- Stats ------------------------------------------------------
          _StatRow(
            label: 'Items',
            value: '$itemCount',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _StatRow(
            label: 'Total Cost',
            value: '${totalCost.toStringAsFixed(1)} EGP',
            isDark: isDark,
            valueColor: AppColors.secondary,
          ),
          const SizedBox(height: 8),
          _StatRow(
            label: 'Credits Left',
            value: '${remaining.toStringAsFixed(1)} EGP',
            isDark: isDark,
            valueColor: remaining < 0 ? AppColors.danger : AppColors.success,
          ),

          const SizedBox(height: 18),

          // -- Checkout button --------------------------------------------
          SizedBox(
            width: double.infinity,
            height: 40,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: itemCount > 0
                      ? [AppColors.primaryDark, AppColors.primary]
                      : [AppColors.textMuted, AppColors.textMuted],
                ),
                borderRadius: BorderRadius.circular(11),
                boxShadow: itemCount > 0
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton(
                onPressed:
                    itemCount > 0 ? () => context.go(RouteNames.checkout) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white54,
                  disabledBackgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: Text(
                  itemCount > 0 ? 'Checkout' : 'Cart Empty',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color:
                isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            color: valueColor ??
                (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
