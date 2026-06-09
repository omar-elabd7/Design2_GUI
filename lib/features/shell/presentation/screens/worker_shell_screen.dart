import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../robot_status/presentation/providers/robot_status_provider.dart';

// ─── palette (matches worker dashboard) ──────────────────────────────────────
const _kGreen = Color(0xFF2ECC8E);
const _kSidebarBg = Color(0xFF080E18);
const _kTopBarBg = Color(0xFF0A1220);
const _kBorder = Color(0xFF142030);
const _kBorderGreen = Color(0xFF0F2820);

class WorkerShellScreen extends ConsumerStatefulWidget {
  final Widget child;
  const WorkerShellScreen({super.key, required this.child});

  @override
  ConsumerState<WorkerShellScreen> createState() => _WorkerShellScreenState();
}

class _WorkerShellScreenState extends ConsumerState<WorkerShellScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final status = ref.watch(robotStatusProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1A),
      body: Column(
        children: [
          // ── top bar ───────────────────────────────────────────────────────
          _TopBar(
            workerName: user?.name ?? 'Worker',
            isConnected: status.isConnected,
            pulseCtrl: _pulseCtrl,
          ),
          // ── body ──────────────────────────────────────────────────────────
          Expanded(
            child: Row(
              children: [
                _Sidebar(workerName: user?.name ?? 'Worker'),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  Top Bar
// =============================================================================

class _TopBar extends ConsumerWidget {
  const _TopBar({
    required this.workerName,
    required this.isConnected,
    required this.pulseCtrl,
  });
  final String workerName;
  final bool isConnected;
  final AnimationController pulseCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: _kTopBarBg,
        border: const Border(
          bottom: BorderSide(color: _kBorderGreen, width: 1),
        ),
      ),
      child: Row(
        children: [
          // logo mark + title
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _kGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kGreen.withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.precision_manufacturing_rounded,
              color: _kGreen,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Pluto',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: _kGreen,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                TextSpan(
                  text: '  ·  Worker Panel',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // connection chip (pulsing)
          AnimatedBuilder(
            animation: pulseCtrl,
            builder: (_, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isConnected
                    ? _kGreen.withValues(alpha: 0.07 + pulseCtrl.value * 0.05)
                    : AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isConnected
                      ? _kGreen.withValues(alpha: 0.35)
                      : AppColors.danger.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isConnected ? _kGreen : AppColors.danger,
                      boxShadow: isConnected
                          ? [
                              BoxShadow(
                                color: _kGreen.withValues(alpha: 0.6),
                                blurRadius: 6,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    isConnected ? 'PLUTO IS CONNECTED' : 'DISCONNECTED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isConnected ? _kGreen : AppColors.danger,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 20),

          // user chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1E2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kGreen.withValues(alpha: 0.15),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 13,
                    color: _kGreen,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  workerName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // logout button
          Tooltip(
            message: 'Logout',
            child: InkWell(
              onTap: () {
                ref.read(authStateProvider.notifier).logout();
                context.go(
                  '${RouteNames.transitionSplash}?next=${RouteNames.login}&subtitle=Signing out...',
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1E2E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kBorder),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  Sidebar
// =============================================================================

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.workerName});
  final String workerName;

  static const _navItems = [
    _NavDef(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      route: RouteNames.workerDashboard,
    ),
    _NavDef(
      icon: Icons.gamepad_rounded,
      label: 'Control',
      route: RouteNames.workerControl,
    ),
    _NavDef(
      icon: Icons.bug_report_rounded,
      label: 'Debug',
      route: RouteNames.debug,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final status = ref.watch(robotStatusProvider);

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: _kSidebarBg,
        border: const Border(right: BorderSide(color: _kBorderGreen)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── robot mini-status ────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1A26),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorderGreen),
            ),
            child: Row(
              children: [
                // robot image
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _kGreen.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _kGreen.withValues(alpha: 0.15),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/robot.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PLUTO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _kGreen,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: status.isConnected
                                  ? _kGreen
                                  : AppColors.danger,
                              boxShadow: status.isConnected
                                  ? [
                                      BoxShadow(
                                        color: _kGreen.withValues(alpha: 0.7),
                                        blurRadius: 5,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            status.isConnected
                                ? 'System Normal'
                                : 'Disconnected',
                            style: TextStyle(
                              fontSize: 10,
                              color: status.isConnected
                                  ? _kGreen
                                  : AppColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── version label ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text(
              'WORKER · v2.5.0',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // ── divider ──────────────────────────────────────────────────────
          Divider(height: 1, color: _kBorderGreen, indent: 12, endIndent: 12),
          const SizedBox(height: 8),

          // ── nav items ────────────────────────────────────────────────────
          ...List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            final selected =
                location == item.route ||
                (item.route != RouteNames.workerDashboard &&
                    location.startsWith(item.route));
            return _NavTile(
              icon: item.icon,
              label: item.label,
              selected: selected,
              onTap: () => context.go(item.route),
            );
          }),

          const Spacer(),

          // ── worker info at bottom ────────────────────────────────────────
          Divider(height: 1, color: _kBorderGreen, indent: 12, endIndent: 12),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kGreen.withValues(alpha: 0.12),
                    border: Border.all(color: _kGreen.withValues(alpha: 0.25)),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 16,
                    color: _kGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workerName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'Worker',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
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

// =============================================================================
//  Nav tile
// =============================================================================

class _NavTile extends StatefulWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.selected || _hovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: widget.selected
                ? _kGreen.withValues(alpha: 0.1)
                : _hovered
                ? const Color(0xFF0C1E2A)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.selected
                  ? _kGreen.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              // icon with glow
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accent
                      ? _kGreen.withValues(alpha: 0.12)
                      : const Color(0xFF0D1A24),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icon,
                  size: 16,
                  color: accent ? _kGreen : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: widget.selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: accent
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
              if (widget.selected) ...[
                const Spacer(),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kGreen,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── nav item definition ─────────────────────────────────────────────────────

class _NavDef {
  const _NavDef({required this.icon, required this.label, required this.route});
  final IconData icon;
  final String label;
  final String route;
}
