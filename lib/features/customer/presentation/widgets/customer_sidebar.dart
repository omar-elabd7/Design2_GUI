import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Fixed left-sidebar for the Customer Command Center.
class CustomerSidebar extends ConsumerWidget {
  const CustomerSidebar({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final location = GoRouterState.of(context).uri.toString();

    final bg = isDark
        ? const Color(0xFF0C1322)
        : AppColors.lightSurfaceElevated;

    final borderColor = isDark
        ? const Color(0xFF1A2540)
        : AppColors.lightCardBorder;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        children: [
          // -- Logo -------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: Row(
              children: [
                Image.asset(
                  kLogoPath,
                  width: 34,
                  height: 34,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.smart_toy_rounded,
                    size: 30,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  appName,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          // -- Nav items --------------------------------------------------
          _SidebarItem(
            icon: Icons.dashboard_rounded,
            label: 'Home',
            isSelected: location == RouteNames.customerHome,
            isDark: isDark,
            onTap: () => context.go(RouteNames.customerHome),
          ),
          _SidebarItem(
            icon: Icons.receipt_long_rounded,
            label: 'My Orders',
            isSelected: location.startsWith(RouteNames.orderTracking),
            isDark: isDark,
            onTap: () => context.go(RouteNames.orderTracking),
          ),
          _SidebarItem(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Wallet / Credits',
            isSelected: false,
            isDark: isDark,
            onTap: () {},
          ),
          _SidebarItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            isSelected: false,
            isDark: isDark,
            onTap: () {},
          ),
          _SidebarItem(
            icon: Icons.help_outline_rounded,
            label: 'Help',
            isSelected: false,
            isDark: isDark,
            onTap: () {},
          ),
          _SidebarItem(
            icon: Icons.logout_rounded,
            label: 'Logout',
            isSelected: false,
            isDark: isDark,
            onTap: () {
              ref.read(authStateProvider.notifier).logout();
              context.go(
                '${RouteNames.transitionSplash}?next=${RouteNames.login}&subtitle=Signing out...',
              );
            },
            isDestructive: true,
          ),

          const Spacer(),

          // -- User mini card ---------------------------------------------
          if (user != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
              child: _UserMiniCard(
                name: user.name,
                rfidId: user.rfidCardId,
                credits: user.credits,
                isDark: isDark,
              ),
            ),
        ],
      ),
    );
  }
}

// --- Sidebar nav item --------------------------------------------------------

class _SidebarItem extends StatefulWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final activeColor =
        widget.isDestructive ? AppColors.danger : AppColors.primary;

    final Color textColor;
    if (widget.isSelected) {
      textColor = activeColor;
    } else if (_hovering) {
      textColor = widget.isDark
          ? AppColors.textPrimary
          : AppColors.lightTextPrimary;
    } else {
      textColor = widget.isDark
          ? AppColors.textSecondary
          : AppColors.lightTextSecondary;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? activeColor.withValues(alpha: 0.12)
                : _hovering
                    ? (widget.isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.04))
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: textColor),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textColor,
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- User mini card at bottom ------------------------------------------------

class _UserMiniCard extends StatelessWidget {
  const _UserMiniCard({
    required this.name,
    required this.rfidId,
    required this.credits,
    required this.isDark,
  });

  final String name;
  final String rfidId;
  final double credits;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.primary.withValues(alpha: 0.06);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.22),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '...',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.credit_card_rounded,
                          size: 10,
                          color: AppColors.primary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'RFID Linked',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary.withValues(alpha: 0.7),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.monetization_on_rounded,
                  size: 13,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 5),
                Text(
                  '${credits.toStringAsFixed(1)} EGP',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
