import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';

/// RFID scan panel ? large NFC wave animation with countdown.
/// Only visible during `awaitingRfid` state.
class RfidScanPanel extends StatefulWidget {
  const RfidScanPanel({super.key, this.isDark = true});

  final bool isDark;

  @override
  State<RfidScanPanel> createState() => _RfidScanPanelState();
}

class _RfidScanPanelState extends State<RfidScanPanel>
    with TickerProviderStateMixin {
  late AnimationController _waveCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _countdownCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _countdownCtrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: kRfidVerificationTimeoutSec),
    )..forward();
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _glowCtrl.dispose();
    _countdownCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // -- NFC Wave Animation --
        SizedBox(
          width: 200,
          height: 200,
          child: AnimatedBuilder(
            animation: Listenable.merge([_waveCtrl, _glowCtrl]),
            builder: (_, __) {
              return CustomPaint(
                painter: _NfcWavePainter(
                  waveProgress: _waveCtrl.value,
                  glowIntensity: _glowCtrl.value,
                ),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primaryLight.withValues(alpha: 0.2),
                          AppColors.primaryLight.withValues(alpha: 0.05),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.primaryLight.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLight.withValues(
                              alpha: 0.2 + _glowCtrl.value * 0.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.nfc_rounded,
                      size: 36,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // -- "SCAN YOUR RFID CARD" --
        Text(
          'SCAN YOUR RFID CARD',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primaryLight,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Hold your card near the robot\'s sensor',
          style:
              AppTextStyles.bodySmall.copyWith(
                  color: widget.isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
        ),

        const SizedBox(height: 16),

        // -- Countdown --
        AnimatedBuilder(
          animation: _countdownCtrl,
          builder: (_, __) {
            final remaining = (kRfidVerificationTimeoutSec *
                    (1.0 - _countdownCtrl.value))
                .ceil();
            final isLow = remaining <= 10;
            return Column(
              children: [
                // progress bar
                SizedBox(
                  width: 180,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: 1.0 - _countdownCtrl.value,
                      backgroundColor: widget.isDark ? AppColors.surface : AppColors.lightSurface,
                      valueColor: AlwaysStoppedAnimation(
                        isLow ? AppColors.warning : AppColors.primaryLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${remaining}s remaining',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 12,
                    color: isLow ? AppColors.warning
                        : widget.isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
class _NfcWavePainter extends CustomPainter {
  _NfcWavePainter({
    required this.waveProgress,
    required this.glowIntensity,
  });

  final double waveProgress;
  final double glowIntensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw 3 expanding rings
    for (int i = 0; i < 3; i++) {
      final phase = (waveProgress + i * 0.33) % 1.0;
      final radius = 36.0 + phase * 60.0;
      final opacity = (1.0 - phase) * 0.5;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = AppColors.primaryLight.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    // Draw NFC arc indicators
    for (int i = 0; i < 3; i++) {
      final arcRadius = 40.0 + i * 14.0;
      final opacity = 0.3 + glowIntensity * 0.4 - i * 0.1;
      if (opacity <= 0) continue;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        -pi / 4,
        pi / 2,
        false,
        Paint()
          ..color = AppColors.primaryLight.withValues(alpha: opacity.clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NfcWavePainter old) =>
      waveProgress != old.waveProgress || glowIntensity != old.glowIntensity;
}
