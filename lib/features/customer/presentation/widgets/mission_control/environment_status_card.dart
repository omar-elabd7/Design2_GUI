import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/glass_panel.dart';
import '../../../../../shared/models/enums.dart';

/// Environment / sensor status card: obstacle, path, navigation sensors.
class EnvironmentStatusCard extends StatelessWidget {
  const EnvironmentStatusCard({
    super.key,
    required this.missionState,
    required this.faultType,
    required this.isConnected,
    this.isDark = true,
  });

  final MissionState missionState;
  final FaultType faultType;
  final bool isConnected;
  final bool isDark;

  _SensorStatus _obstacleStatus() {
    if (faultType == FaultType.obstacleBlocked) {
      return _SensorStatus('BLOCKED', AppColors.danger, Icons.block_rounded);
    }
    if (missionState == MissionState.navigatingToUser ||
        missionState == MissionState.returningToBase) {
      return _SensorStatus(
        'Clear Path',
        AppColors.success,
        Icons.check_circle_outline_rounded,
      );
    }
    return _SensorStatus('Standby', AppColors.textMuted, Icons.circle_outlined);
  }

  _SensorStatus _pathStatus() {
    if (missionState == MissionState.navigatingToUser) {
      return _SensorStatus(
        'A* Routing Active',
        const Color(0xFF42A5F5),
        Icons.route_rounded,
      );
    }
    if (missionState == MissionState.returningToBase) {
      return _SensorStatus(
        'Return Path',
        const Color(0xFF42A5F5),
        Icons.route_rounded,
      );
    }
    if (faultType == FaultType.obstacleBlocked) {
      return _SensorStatus(
        'rerouting...',
        AppColors.warning,
        Icons.alt_route_rounded,
      );
    }
    return _SensorStatus('Idle', AppColors.textMuted, Icons.circle_outlined);
  }

  _SensorStatus _lidarStatus() {
    if (!isConnected) {
      return _SensorStatus(
        'Disconnected',
        AppColors.danger,
        Icons.sensors_off_rounded,
      );
    }
    if (missionState == MissionState.idle) {
      return _SensorStatus(
        'Standby',
        AppColors.textMuted,
        Icons.sensors_rounded,
      );
    }
    return _SensorStatus(
      'Active ? 180?',
      AppColors.success,
      Icons.sensors_rounded,
    );
  }

  _SensorStatus _proximityStatus() {
    if (faultType == FaultType.obstacleBlocked) {
      return _SensorStatus(
        '0.3 m - WARNING',
        AppColors.danger,
        Icons.warning_amber_rounded,
      );
    }
    if (missionState == MissionState.navigatingToUser ||
        missionState == MissionState.returningToBase) {
      return _SensorStatus(
        '> 2.0 m - Safe',
        AppColors.success,
        Icons.radar_rounded,
      );
    }
    return _SensorStatus('Standby', AppColors.textMuted, Icons.radar_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final obstacle = _obstacleStatus();
    final path = _pathStatus();
    final lidar = _lidarStatus();
    final proximity = _proximityStatus();

    return GlassPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.landscape_rounded,
                size: 16,
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: 8),
              Text(
                'ENVIRONMENT',
                style: AppTextStyles.labelLarge.copyWith(
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SensorRow(label: 'Obstacle', status: obstacle),
          const SizedBox(height: 10),
          _SensorRow(label: 'Path', status: path),
          const SizedBox(height: 10),
          _SensorRow(label: 'LiDAR', status: lidar),
          const SizedBox(height: 10),
          _SensorRow(label: 'Proximity', status: proximity),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
class _SensorStatus {
  const _SensorStatus(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

class _SensorRow extends StatelessWidget {
  const _SensorRow({required this.label, required this.status});
  final String label;
  final _SensorStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(status.icon, size: 14, color: status.color),
        const SizedBox(width: 8),
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
          ),
        ),
        Expanded(
          child: Text(
            status.label,
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 11,
              color: status.color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
