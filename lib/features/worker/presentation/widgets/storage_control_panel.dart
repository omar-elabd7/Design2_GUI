import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../shared/models/enums.dart';
import '../providers/worker_control_provider.dart';

class StorageControlPanel extends ConsumerWidget {
  const StorageControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageAsync = ref.watch(workerStorageStateProvider);
    final currentState =
        storageAsync.asData?.value ?? StorageState.closed;

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
              const Icon(Icons.inventory_2_outlined,
                  color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 8),
              const Text('Storage', style: AppTextStyles.headlineSmall),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: currentState.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  currentState.label,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: currentState.color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Open',
                  icon: Icons.lock_open_outlined,
                  variant: currentState == StorageState.open
                      ? AppButtonVariant.ghost
                      : AppButtonVariant.primary,
                  onPressed: currentState == StorageState.open ||
                          currentState == StorageState.opening
                      ? null
                      : () => ref
                          .read(workerControlProvider.notifier)
                          .openStorage(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Close',
                  icon: Icons.lock_outlined,
                  variant: currentState == StorageState.closed
                      ? AppButtonVariant.ghost
                      : AppButtonVariant.danger,
                  onPressed: currentState == StorageState.closed ||
                          currentState == StorageState.closing
                      ? null
                      : () => ref
                          .read(workerControlProvider.notifier)
                          .closeStorage(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
