import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class WorkerShellScreen extends ConsumerWidget {
  final Widget child;

  const WorkerShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return AppScaffold(
      topBar: _WorkerTopBar(
        workerName: user?.name ?? 'Worker',
        onLogout: () {
          ref.read(authStateProvider.notifier).logout();
          context.go(
            '${RouteNames.transitionSplash}?next=${RouteNames.login}&subtitle=Signing out...',
          );
        },
      ),
      sidebar: _WorkerSidebar(child: child),
      body: child,
    );
  }
}

class _WorkerTopBar extends StatelessWidget {
  final String workerName;
  final VoidCallback onLogout;

  const _WorkerTopBar({required this.workerName, required this.onLogout});

  @override
  Widget build(BuildContext context) {
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
            'Pluto - Worker Panel',
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
              const SizedBox(width: 4),
              Text(workerName, style: AppTextStyles.bodySmall),
              const SizedBox(width: 12),
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
        ],
      ),
    );
  }
}

class _WorkerSidebar extends ConsumerWidget {
  final Widget child;

  const _WorkerSidebar({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();

    return Container(
      width: kSidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border(right: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        children: [
          const SizedBox(height: kDefaultPadding),
          _NavItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            isSelected: location == RouteNames.workerDashboard,
            onTap: () => context.go(RouteNames.workerDashboard),
          ),
          _NavItem(
            icon: Icons.gamepad_outlined,
            label: 'Control',
            isSelected: location == RouteNames.workerControl,
            onTap: () => context.go(RouteNames.workerControl),
          ),
          _NavItem(
            icon: Icons.bug_report_outlined,
            label: 'Debug',
            isSelected: location == RouteNames.debug,
            onTap: () => context.go(RouteNames.debug),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: kDefaultPadding,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          border: isSelected
              ? const Border(
                  left: BorderSide(color: AppColors.primary, width: 3),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
