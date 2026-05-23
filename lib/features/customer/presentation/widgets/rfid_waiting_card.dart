import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class RfidWaitingCard extends StatefulWidget {
  const RfidWaitingCard({super.key});

  @override
  State<RfidWaitingCard> createState() => _RfidWaitingCardState();
}

class _RfidWaitingCardState extends State<RfidWaitingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.6, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kLargePadding),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Opacity(
              opacity: _pulseAnimation.value,
              child: child,
            ),
            child: const Icon(
              Icons.contactless,
              color: AppColors.warning,
              size: 56,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap Your RFID Card',
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Hold your RFID card near the robot\'s reader to verify your identity and unlock your delivery.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Timeout in ${kRfidVerificationTimeoutSec}s',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
