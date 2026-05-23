import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/teleop_panel.dart';
import '../widgets/storage_control_panel.dart';
import '../widgets/robot_mode_panel.dart';
import '../widgets/battery_status_card.dart';
import '../widgets/worker_status_panel.dart';

class WorkerDashboardScreen extends ConsumerWidget {
  const WorkerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return AppScaffold(
      topBar: _WorkerTopBar(workerName: user?.name ?? 'Worker'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      const TeleopPanel(),
                      const SizedBox(height: kDefaultPadding),
                      const StorageControlPanel(),
                    ],
                  ),
                ),
                const SizedBox(width: kDefaultPadding),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      const WorkerStatusPanel(),
                      const SizedBox(height: kDefaultPadding),
                      const BatteryStatusCard(),
                      const SizedBox(height: kDefaultPadding),
                      const RobotModePanel(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkerTopBar extends ConsumerWidget {
  final String workerName;

  const _WorkerTopBar({required this.workerName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: kTopBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.precision_manufacturing,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            'Pluto - Worker',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(workerName, style: AppTextStyles.bodySmall),
              const SizedBox(width: kDefaultPadding),
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                tooltip: 'Logout',
                onPressed: () {
                  ref.read(authStateProvider.notifier).logout();
                  context.go(
                    '${RouteNames.transitionSplash}?next=${RouteNames.login}&subtitle=Signing out...',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
