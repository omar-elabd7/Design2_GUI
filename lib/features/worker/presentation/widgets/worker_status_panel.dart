import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../../../robot_status/presentation/providers/robot_status_provider.dart';
import '../../../robot_status/presentation/widgets/fault_banner.dart';
import '../../../robot_status/presentation/widgets/storage_state_chip.dart';

class WorkerStatusPanel extends ConsumerWidget {
  const WorkerStatusPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(robotStatusProvider);

    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(kCardBorderRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Robot Status', style: AppTextStyles.titleMedium),
              _ConnectionDot(isConnected: status.isConnected),
            ],
          ),
          const SizedBox(height: kSmallPadding),
          const Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: kSmallPadding),
          _StatusRow(
            label: 'Mode',
            value: status.mode.label,
            valueColor: status.mode.color,
          ),
          const SizedBox(height: 8),
          _StatusRow(label: 'Mission', value: status.missionState.label),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Storage ', style: AppTextStyles.bodySmall),
              const StorageStateChip(),
            ],
          ),
          const SizedBox(height: kSmallPadding),
          const FaultBanner(),
        ],
      ),
    );
  }
}

class _ConnectionDot extends StatelessWidget {
  final bool isConnected;

  const _ConnectionDot({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isConnected ? AppColors.success : AppColors.danger,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isConnected ? 'Connected' : 'Disconnected',
          style: AppTextStyles.labelSmall.copyWith(
            color: isConnected ? AppColors.success : AppColors.danger,
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatusRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
