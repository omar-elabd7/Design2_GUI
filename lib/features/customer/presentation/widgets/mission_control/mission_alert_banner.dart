import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/models/enums.dart';

/// Contextual alert banner for error / warning mission states.
class MissionAlertBanner extends StatefulWidget {
  const MissionAlertBanner({
    super.key,
    required this.missionState,
    required this.faultType,
    this.onRetry,
    this.onCancel,
    this.isDark = true,
  });

  final MissionState missionState;
  final FaultType faultType;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;
  final bool isDark;

  @override
  State<MissionAlertBanner> createState() => _MissionAlertBannerState();
}

class _MissionAlertBannerState extends State<MissionAlertBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashCtrl;

  @override
  void initState() {
    super.initState();
    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flashCtrl.dispose();
    super.dispose();
  }

  _AlertData? _alertData() {
    switch (widget.faultType) {
      case FaultType.obstacleBlocked:
        return _AlertData(
          icon: Icons.block_rounded,
          title: 'OBSTACLE DETECTED',
          message:
              'The robot has encountered an obstacle on its path. '
              'It will attempt to reroute automatically.',
          color: AppColors.warning,
          showRetry: true,
        );
      case FaultType.lowBattery:
        return _AlertData(
          icon: Icons.battery_alert_rounded,
          title: 'LOW BATTERY WARNING',
          message:
              'Robot battery is critically low. '
              'It may need to return to base for charging.',
          color: AppColors.warning,
          showRetry: false,
        );
      case FaultType.criticalBattery:
        return _AlertData(
          icon: Icons.battery_0_bar_rounded,
          title: 'CRITICAL BATTERY',
          message:
              'Robot is returning to base. Your order will be rescheduled.',
          color: AppColors.danger,
          showRetry: false,
        );
      case FaultType.outOfStock:
        return _AlertData(
          icon: Icons.remove_shopping_cart_rounded,
          title: 'ITEM OUT OF STOCK',
          message: 'One or more items in your order are unavailable.',
          color: AppColors.danger,
          showRetry: false,
          showCancel: true,
        );
      case FaultType.rfidFailed:
        return _AlertData(
          icon: Icons.nfc_rounded,
          title: 'RFID VERIFICATION FAILED',
          message: 'Your RFID card was not recognized. Please try again.',
          color: AppColors.danger,
          showRetry: true,
        );
      case FaultType.storageFault:
        return _AlertData(
          icon: Icons.error_outline_rounded,
          title: 'STORAGE COMPARTMENT FAULT',
          message: 'The robot\'s storage compartment has malfunctioned.',
          color: AppColors.danger,
          showRetry: true,
        );
      case FaultType.communicationLost:
        return _AlertData(
          icon: Icons.wifi_off_rounded,
          title: 'COMMUNICATION LOST',
          message: 'Lost connection to the robot. Attempting to reconnect...',
          color: AppColors.danger,
          showRetry: true,
        );
      case FaultType.missionCancelled:
        return _AlertData(
          icon: Icons.cancel_rounded,
          title: 'MISSION CANCELLED',
          message: 'This delivery mission has been cancelled.',
          color: AppColors.textSecondary,
          showRetry: false,
        );
      case FaultType.visionFailed:
        return _AlertData(
          icon: Icons.no_food_rounded,
          title: 'ITEM UNAVAILABLE',
          message:
              'Unfortunately, this fruit is currently out of stock. '
              'Your credits have been refunded.',
          color: AppColors.warning,
          showRetry: false,
          showCancel: false,
        );
      case FaultType.none:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final alert = _alertData();
    if (alert == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _flashCtrl,
      builder: (_, __) {
        final borderOpacity = 0.3 + _flashCtrl.value * 0.4;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: alert.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: alert.color.withValues(alpha: borderOpacity),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: alert.color.withValues(alpha: 0.1),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(alert.icon, color: alert.color, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      alert.title,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: alert.color,
                        letterSpacing: 1.0,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                alert.message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: widget.isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary,
                  fontSize: 12,
                ),
              ),
              if (alert.showRetry || alert.showCancel) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (alert.showRetry && widget.onRetry != null)
                      _ActionBtn(
                        label: 'RETRY',
                        color: alert.color,
                        icon: Icons.refresh_rounded,
                        onTap: widget.onRetry!,
                      ),
                    if (alert.showRetry && alert.showCancel)
                      const SizedBox(width: 10),
                    if (alert.showCancel && widget.onCancel != null)
                      _ActionBtn(
                        label: 'CANCEL ORDER',
                        color: AppColors.danger,
                        icon: Icons.cancel_outlined,
                        onTap: widget.onCancel!,
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
class _AlertData {
  const _AlertData({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    this.showRetry = false,
    this.showCancel = false,
  });
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final bool showRetry;
  final bool showCancel;
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 11,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
