import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';

class CreditCardWidget extends StatelessWidget {
  const CreditCardWidget({
    super.key,
    required this.name,
    required this.credits,
    required this.rfidCardId,
  });

  final String name;
  final double credits;
  final String rfidCardId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Available Credits',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.textOnPrimary.withValues(alpha: 0.8))),
              const Icon(Icons.contactless, color: AppColors.textOnPrimary, size: 22),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.formatCredits(credits),
            style: AppTextStyles.creditAmount
                .copyWith(color: AppColors.textOnPrimary),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card Holder',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textOnPrimary.withValues(alpha: 0.7))),
                  Text(name,
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.textOnPrimary)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('RFID',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.textOnPrimary.withValues(alpha: 0.7))),
                  Text(rfidCardId.substring(rfidCardId.length - 6),
                      style: AppTextStyles.monospace
                          .copyWith(color: AppColors.textOnPrimary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
