import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/models/enums.dart';
import '../providers/worker_control_provider.dart';

class RobotModePanel extends ConsumerWidget {
  const RobotModePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(workerControlProvider);

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
            children: [
              const Icon(Icons.settings_remote_outlined,
                  color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 8),
              const Text('Robot Mode', style: AppTextStyles.headlineSmall),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: mode.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  mode.label,
                  style: AppTextStyles.labelSmall.copyWith(color: mode.color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Online',
                  icon: Icons.wifi,
                  variant: mode == RobotMode.online || mode == RobotMode.autonomous
                      ? AppButtonVariant.primary
                      : AppButtonVariant.outline,
                  small: true,
                  onPressed: () =>
                      ref.read(workerControlProvider.notifier).setOnline(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'Offline',
                  icon: Icons.wifi_off,
                  variant: mode == RobotMode.offline
                      ? AppButtonVariant.danger
                      : AppButtonVariant.outline,
                  small: true,
                  onPressed: () =>
                      ref.read(workerControlProvider.notifier).setOffline(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Manual',
                  icon: Icons.gamepad_outlined,
                  variant: mode == RobotMode.manual
                      ? AppButtonVariant.secondary
                      : AppButtonVariant.outline,
                  small: true,
                  onPressed: () =>
                      ref.read(workerControlProvider.notifier).setManual(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'Autonomous',
                  icon: Icons.auto_mode,
                  variant: mode == RobotMode.autonomous
                      ? AppButtonVariant.primary
                      : AppButtonVariant.outline,
                  small: true,
                  onPressed: () =>
                      ref.read(workerControlProvider.notifier).setAutonomous(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
