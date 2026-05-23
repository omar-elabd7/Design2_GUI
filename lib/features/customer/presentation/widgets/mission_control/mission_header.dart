import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/glass_panel.dart';
import '../../../../../shared/models/enums.dart';

/// Top header bar for Mission Control:
/// Order ID | live robot-status pulse | ETA | optional cancel.
class MissionHeader extends StatefulWidget {
  const MissionHeader({
    super.key,
    required this.orderId,
    required this.missionState,
    required this.faultType,
    this.onCancel,
    this.isDark = true,
  });

  final String orderId;
  final MissionState missionState;
  final FaultType faultType;
  final VoidCallback? onCancel;
  final bool isDark;

  @override
  State<MissionHeader> createState() => _MissionHeaderState();
}

class _MissionHeaderState extends State<MissionHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // -- helpers ----------------------------------------------------------
  Color _statusColor() {
    if (widget.faultType != FaultType.none) return AppColors.danger;
    switch (widget.missionState) {
      case MissionState.idle:
        return AppColors.textMuted;
      case MissionState.missionReceived:
      case MissionState.preparingOrder:
        return AppColors.info;
      case MissionState.navigatingToUser:
      case MissionState.returningToBase:
        return const Color(0xFF42A5F5); // blue motion
      case MissionState.arrived:
      case MissionState.awaitingRfid:
        return AppColors.warning;
      case MissionState.rfidVerified:
      case MissionState.storageOpened:
      case MissionState.deliveryComplete:
        return AppColors.success;
      case MissionState.rfidFailed:
      case MissionState.obstacleBlocked:
      case MissionState.lowBattery:
      case MissionState.failed:
        return AppColors.danger;
    }
  }

  String _statusLabel() {
    if (widget.faultType != FaultType.none) return 'ALERT';
    switch (widget.missionState) {
      case MissionState.idle:
        return 'IDLE';
      case MissionState.missionReceived:
        return 'ORDER RECEIVED';
      case MissionState.preparingOrder:
        return 'PREPARING';
      case MissionState.navigatingToUser:
        return 'EN ROUTE';
      case MissionState.arrived:
        return 'ARRIVED';
      case MissionState.awaitingRfid:
        return 'RFID REQUIRED';
      case MissionState.rfidVerified:
        return 'RFID OK';
      case MissionState.storageOpened:
        return 'STORAGE OPEN';
      case MissionState.deliveryComplete:
        return 'COMPLETE';
      case MissionState.returningToBase:
        return 'RTB';
      case MissionState.rfidFailed:
        return 'RFID FAIL';
      case MissionState.obstacleBlocked:
        return 'BLOCKED';
      case MissionState.lowBattery:
        return 'LOW BATTERY';
      case MissionState.failed:
        return 'FAILED';
    }
  }

  String _etaLabel() {
    switch (widget.missionState) {
      case MissionState.idle:
      case MissionState.deliveryComplete:
      case MissionState.returningToBase:
      case MissionState.failed:
        return '--';
      case MissionState.missionReceived:
        return '~5 min';
      case MissionState.preparingOrder:
        return '~4 min';
      case MissionState.navigatingToUser:
        return '~3 min';
      case MissionState.arrived:
      case MissionState.awaitingRfid:
      case MissionState.rfidVerified:
      case MissionState.storageOpened:
        return '< 1 min';
      case MissionState.rfidFailed:
      case MissionState.obstacleBlocked:
      case MissionState.lowBattery:
        return 'Delayed';
    }
  }

  bool get _canCancel {
    const nonCancellable = {
      MissionState.deliveryComplete,
      MissionState.returningToBase,
      MissionState.idle,
    };
    return !nonCancellable.contains(widget.missionState);
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      borderRadius: 16,
      glowColor: color,
      isDark: widget.isDark,
      child: Row(
        children: [
          // -- order badge --
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.surface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.isDark ? AppColors.cardBorder : AppColors.lightCardBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long_rounded,
                    size: 16,
                    color: widget.isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                const SizedBox(width: 6),
                Text(
                  'ORDER ${widget.orderId.length > 8 ? widget.orderId.substring(0, 8).toUpperCase() : widget.orderId.toUpperCase()}',
                  style: AppTextStyles.labelLarge
                      .copyWith(letterSpacing: 1.2, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // -- live status pulse + label --
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) {
              final scale = 1.0 + _pulseCtrl.value * 0.4;
              return Container(
                width: 10 * scale,
                height: 10 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            _statusLabel(),
            style: AppTextStyles.labelLarge.copyWith(
              color: color,
              fontSize: 13,
              letterSpacing: 1.0,
            ),
          ),

          const Spacer(),

          // -- ETA --
          _InfoChip(
            icon: Icons.timer_outlined,
            label: 'ETA',
            value: _etaLabel(),
            isDark: widget.isDark,
          ),

          const SizedBox(width: 12),

          // -- Mission state name --
          _InfoChip(
            icon: Icons.smart_toy_outlined,
            label: 'STATE',
            value: widget.missionState.name
                .replaceAllMapped(
                    RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
                .toUpperCase(),
            isDark: widget.isDark,
          ),

          if (_canCancel && widget.onCancel != null) ...[
            const SizedBox(width: 16),
            _CancelButton(onPressed: widget.onCancel!),
          ],
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    this.isDark = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.surface : AppColors.lightSurface)
            .withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14,
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: AppTextStyles.bodySmall
                      .copyWith(fontSize: 9, letterSpacing: 1.0)),
              Text(value,
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.danger.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel_outlined,
                  size: 15, color: AppColors.danger),
              const SizedBox(width: 6),
              Text('CANCEL',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.danger, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
