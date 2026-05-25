import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../shared/models/robot_status.dart';
import '../../../../shared/models/enums.dart';

/// Right-rail card showing real-time robot status with a mini radar pulse.
class RobotLiveStatusCard extends StatefulWidget {
  const RobotLiveStatusCard({
    super.key,
    required this.status,
    required this.isDark,
  });

  final RobotStatus status;
  final bool isDark;

  @override
  State<RobotLiveStatusCard> createState() => _RobotLiveStatusCardState();
}

class _RobotLiveStatusCardState extends State<RobotLiveStatusCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radarCtrl;

  @override
  void initState() {
    super.initState();
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _radarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.status;
    final d = widget.isDark;

    final isOnline =
        s.mode == RobotMode.online || s.mode == RobotMode.autonomous;

    final stateLabel = _missionLabel(s.missionState);
    final batteryColor = s.batteryPercent > 50
        ? AppColors.batteryHigh
        : s.batteryPercent > 20
        ? AppColors.batteryMedium
        : AppColors.batteryLow;

    return GlassPanel(
      isDark: d,
      glowColor: isOnline ? AppColors.primary : AppColors.danger,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Header -----------------------------------------------------
          Row(
            children: [
              Icon(
                Icons.precision_manufacturing_rounded,
                size: 16,
                color: isOnline ? AppColors.primary : AppColors.danger,
              ),
              const SizedBox(width: 8),
              Text(
                'Robot Status',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: d ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // -- Mini radar + battery ---------------------------------------
          Center(
            child: AnimatedBuilder(
              animation: _radarCtrl,
              builder: (context, _) {
                return SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulsating ring
                      _PulseRing(
                        progress: _radarCtrl.value,
                        color: isOnline ? AppColors.primary : AppColors.danger,
                      ),
                      // Inner glow
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              (isOnline ? AppColors.primary : AppColors.danger)
                                  .withValues(alpha: 0.22),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Icon
                      Icon(
                        Icons.smart_toy_rounded,
                        size: 26,
                        color: isOnline
                            ? AppColors.primaryLight
                            : AppColors.danger,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // -- Mode -------------------------------------------------------
          _InfoRow(
            label: 'Mode',
            value: isOnline ? 'Online' : s.mode.name.toUpperCase(),
            valueColor: isOnline ? AppColors.success : AppColors.danger,
            isDark: d,
          ),
          const SizedBox(height: 6),

          // -- Battery ----------------------------------------------------
          _InfoRow(
            label: 'Battery',
            isDark: d,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  s.batteryPercent > 80
                      ? Icons.battery_full_rounded
                      : s.batteryPercent > 20
                      ? Icons.battery_3_bar_rounded
                      : Icons.battery_alert_rounded,
                  size: 14,
                  color: batteryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${s.batteryPercent}%',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: batteryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // -- State ------------------------------------------------------
          _InfoRow(label: 'State', value: stateLabel, isDark: d),
        ],
      ),
    );
  }

  String _missionLabel(MissionState state) {
    switch (state) {
      case MissionState.idle:
        return 'Idle';
      case MissionState.headingToFruit:
        return 'To Fruit';
      case MissionState.visionChecking:
        return 'Checking';
      case MissionState.storing:
        return 'Collecting';
      case MissionState.headingToCustomer:
        return 'Delivering';
      case MissionState.returning:
        return 'Returning';
      case MissionState.rfidAwaiting:
        return 'RFID Wait';
      case MissionState.storageOpened:
        return 'Collect Now';
      default:
        return state.name;
    }
  }
}

// --- Pulse ring --------------------------------------------------------------

class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final size = 80 * (0.5 + 0.5 * progress);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: opacity * 0.4),
          width: 1.5,
        ),
      ),
    );
  }
}

// --- Info row ----------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.isDark,
    this.value,
    this.valueColor,
    this.child,
  });

  final String label;
  final bool isDark;
  final String? value;
  final Color? valueColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isDark
                ? AppColors.textSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        child ??
            Text(
              value ?? '',
              style: AppTextStyles.labelLarge.copyWith(
                color:
                    valueColor ??
                    (isDark
                        ? AppColors.textPrimary
                        : AppColors.lightTextPrimary),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
      ],
    );
  }
}
