import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/glass_panel.dart';
import '../../../../../shared/models/enums.dart';
import '../../../../../core/utils/extensions.dart';

/// Robot telemetry card: mode, battery, storage, connection.
class RobotTelemetryCard extends StatelessWidget {
  const RobotTelemetryCard({
    super.key,
    required this.mode,
    required this.batteryPercent,
    required this.storageState,
    required this.isConnected,
    required this.missionState,
    this.isDark = true,
  });

  final RobotMode mode;
  final int batteryPercent;
  final StorageState storageState;
  final bool isConnected;
  final MissionState missionState;
  final bool isDark;

  Color _batteryColor() {
    if (batteryPercent > 50) return AppColors.success;
    if (batteryPercent > 20) return AppColors.warning;
    return AppColors.danger;
  }

  String _speedLabel() {
    switch (missionState) {
      case MissionState.navigatingToUser:
      case MissionState.returningToBase:
        return '0.8 m/s';
      case MissionState.preparingOrder:
        return '0.3 m/s';
      case MissionState.idle:
      case MissionState.arrived:
      case MissionState.awaitingRfid:
      case MissionState.rfidVerified:
      case MissionState.storageOpened:
      case MissionState.deliveryComplete:
        return '0.0 m/s';
      default:
        return '0.0 m/s';
    }
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
              const Icon(Icons.smart_toy_outlined,
                  size: 16, color: AppColors.primaryLight),
              const SizedBox(width: 8),
              Text('ROBOT STATUS',
                  style: AppTextStyles.labelLarge
                      .copyWith(letterSpacing: 1.2, fontSize: 11)),
              const Spacer(),
              _ConnectionDot(isConnected: isConnected),
            ],
          ),
          const SizedBox(height: 14),

          // -- Mode --
          _TelemetryRow(
            icon: Icons.settings_rounded,
            label: 'Mode',
            value: mode.label,
            valueColor: mode.color,
          ),
          const SizedBox(height: 10),

          // -- Battery --
          _TelemetryRow(
            icon: Icons.battery_std_rounded,
            label: 'Battery',
            trailing: _BatteryBar(
              percent: batteryPercent,
              color: _batteryColor(),
            ),
          ),
          const SizedBox(height: 10),

          // -- Speed --
          _TelemetryRow(
            icon: Icons.speed_rounded,
            label: 'Speed',
            value: _speedLabel(),
            valueColor: AppColors.textPrimary,
          ),
          const SizedBox(height: 10),

          // -- Storage --
          _TelemetryRow(
            icon: Icons.inventory_2_outlined,
            label: 'Storage',
            value: storageState.label,
            valueColor: storageState.color,
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
class _ConnectionDot extends StatefulWidget {
  const _ConnectionDot({required this.isConnected});
  final bool isConnected;

  @override
  State<_ConnectionDot> createState() => _ConnectionDotState();
}

class _ConnectionDotState extends State<_ConnectionDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isConnected ? AppColors.success : AppColors.danger;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3 + _ctrl.value * 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          widget.isConnected ? 'CONNECTED' : 'OFFLINE',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 9,
            color: color,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
class _TelemetryRow extends StatelessWidget {
  const _TelemetryRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueColor,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Color? valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(label,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
        ),
        Expanded(
          child: trailing ??
              Text(
                value ?? '',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 12,
                  color: valueColor ?? AppColors.textPrimary,
                ),
                textAlign: TextAlign.right,
              ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
class _BatteryBar extends StatelessWidget {
  const _BatteryBar({required this.percent, required this.color});
  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        Text(
          '$percent%',
          style:
              AppTextStyles.labelLarge.copyWith(fontSize: 12, color: color),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          height: 14,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                      color: color.withValues(alpha: 0.4), width: 1),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent / 100,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
