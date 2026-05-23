import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_panel.dart';

/// Right-rail card showing RFID security status.
class RfidSecurityCard extends StatelessWidget {
  const RfidSecurityCard({
    super.key,
    required this.isDark,
    required this.rfidCardId,
    required this.isLinked,
  });

  final bool isDark;
  final String rfidCardId;
  final bool isLinked;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      isDark: isDark,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Header -----------------------------------------------------
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                size: 16,
                color: isLinked ? AppColors.primaryLight : AppColors.warning,
              ),
              const SizedBox(width: 8),
              Text(
                'RFID Security',
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

          // -- Status row -------------------------------------------------
          Row(
            children: [
              // Shield icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isLinked ? AppColors.primary : AppColors.warning)
                      .withValues(alpha: 0.12),
                ),
                child: Icon(
                  isLinked
                      ? Icons.verified_user_rounded
                      : Icons.gpp_maybe_rounded,
                  size: 18,
                  color: isLinked ? AppColors.primary : AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLinked ? 'Card Linked' : 'Not Linked',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isLinked
                            ? AppColors.primary
                            : AppColors.warning,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLinked
                          ? 'RFID: ${_mask(rfidCardId)}'
                          : 'Link your card to enable pickup',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.lightTextMuted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // -- Explanation ------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Your order will only unlock after\ncard verification at the robot.',
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 9,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _mask(String id) {
    if (id.length <= 4) return id;
    return '????${id.substring(id.length - 4)}';
  }
}
