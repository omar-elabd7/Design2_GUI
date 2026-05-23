import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../shared/models/enums.dart';
import '../../../robot_status/presentation/providers/robot_status_provider.dart';
import '../../../robot_status/presentation/providers/mission_stream_provider.dart';
import '../../../robot_status/presentation/widgets/battery_indicator.dart';
import '../../../robot_status/presentation/widgets/fault_banner.dart';
import '../../../robot_status/presentation/widgets/storage_state_chip.dart';
import '../../../robot_status/presentation/widgets/robot_status_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/simulate_buttons.dart';

class DebugPanelScreen extends ConsumerWidget {
  const DebugPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(robotStatusProvider);
    final missions = ref.watch(missionUpdatesProvider);

    return AppScaffold(
      topBar: _DebugTopBar(
        onLogout: () {
          ref.read(authStateProvider.notifier).logout();
          context.go(
            '${RouteNames.transitionSplash}?next=${RouteNames.login}&subtitle=Signing out...',
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Debug Panel', style: AppTextStyles.headlineMedium),
            const SizedBox(height: kSmallPadding),
            Text(
              'Simulate robot events for UI testing.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            const Divider(color: AppColors.cardBorder),
            const SizedBox(height: kDefaultPadding),
            const Text('Event Simulators', style: AppTextStyles.titleMedium),
            const SizedBox(height: kSmallPadding),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                SimulateObstacleButton(),
                SimulateBatteryDropButton(),
                SimulateRfidResultButton(),
                SimulateOutOfStockButton(),
              ],
            ),
            const SizedBox(height: kLargePadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live Robot State',
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: kSmallPadding),
                      const RobotStatusCard(),
                      const SizedBox(height: kSmallPadding),
                      BatteryIndicator(percent: status.batteryPercent),
                      const SizedBox(height: kSmallPadding),
                      Row(
                        children: [
                          const Text(
                            'Storage: ',
                            style: AppTextStyles.bodySmall,
                          ),
                          const StorageStateChip(),
                        ],
                      ),
                      const SizedBox(height: kSmallPadding),
                      const FaultBanner(),
                    ],
                  ),
                ),
                const SizedBox(width: kDefaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mission Log',
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: kSmallPadding),
                      Container(
                        height: 320,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(
                            kCardBorderRadius,
                          ),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: missions.when(
                          data: (list) => list.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No mission updates',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                )
                              : ListView.separated(
                                  reverse: true,
                                  padding: const EdgeInsets.all(8),
                                  itemCount: list.length,
                                  separatorBuilder: (_, __) => const Divider(
                                    color: AppColors.cardBorder,
                                    height: 1,
                                  ),
                                  itemBuilder: (_, i) {
                                    final m = list[list.length - 1 - i];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color:
                                                  m.state == MissionState.failed
                                                  ? AppColors.danger
                                                  : AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              m.message,
                                              style: AppTextStyles.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('$e')),
                        ),
                      ),
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

class _DebugTopBar extends ConsumerWidget {
  final VoidCallback onLogout;

  const _DebugTopBar({required this.onLogout});

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
          const Icon(Icons.bug_report, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          const Text('Debug Panel', style: AppTextStyles.titleMedium),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: AppColors.textSecondary,
              size: 18,
            ),
            tooltip: 'Logout',
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}
