import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/models/mission_update.dart';
import '../../../../infrastructure/dependency_injection/providers.dart';
import '../../../robot_status/presentation/providers/robot_status_provider.dart';
import '../../../robot_status/presentation/providers/mission_stream_provider.dart';
import '../providers/checkout_provider.dart';
import '../widgets/mission_control/mission_header.dart';
import '../widgets/mission_control/mission_timeline.dart';
import '../widgets/mission_control/event_log_panel.dart';
import '../widgets/mission_control/mission_progress_circle.dart';
import '../widgets/mission_control/robot_telemetry_card.dart';
import '../widgets/mission_control/environment_status_card.dart';
import '../widgets/mission_control/order_items_card.dart';
import '../widgets/mission_control/rfid_scan_panel.dart';
import '../widgets/mission_control/mission_alert_banner.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../shared/messages/app_messages.dart';

/// **Pluto Mission Control** -- full 3-zone mission dashboard.
///
/// Dynamic dark/light theme, nav-grid background, debug toolbar.
class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);
    final robotStatus = ref.watch(robotStatusProvider);
    final missionsAsync = ref.watch(missionUpdatesProvider);

    final List<MissionUpdate> missions = missionsAsync.when(
      data: (list) => list,
      loading: () => <MissionUpdate>[],
      error: (_, __) => <MissionUpdate>[],
    );

    final checkoutState = ref.watch(checkoutProvider);
    final order = checkoutState.order;

    final missionState = robotStatus.missionState;
    final faultType = robotStatus.faultType;
    final isComplete =
        missionState == MissionState.storageClosed ||
        missionState == MissionState.returning;
    final hasFault = faultType != FaultType.none;
    final isRfid = missionState == MissionState.rfidAwaiting;
    final isStorageOpen = missionState == MissionState.storageOpened;
    final isVisionFailed = faultType == FaultType.visionFailed;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.lightBackground,
      body: Stack(
        children: [
          // -- Ambient background grid (dark mode only) --
          if (isDark) const Positioned.fill(child: _NavGridBackground()),

          // -- Foreground content --
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ------------------- HEADER -------------------
                Row(
                  children: [
                    Expanded(
                      child: MissionHeader(
                        orderId: orderId,
                        missionState: missionState,
                        faultType: faultType,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _ThemeToggle(isDark: isDark),
                  ],
                ),
                const SizedBox(height: 12),

                // ------------------- BODY -------------------
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -- LEFT: Timeline + Event Log --
                      SizedBox(
                        width: 260,
                        child: Column(
                          children: [
                            MissionTimeline(
                              currentState: missionState,
                              faultType: faultType,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: EventLogPanel(
                                updates: missions,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // -- CENTER: Progress / RFID / Alerts / Complete --
                      Expanded(
                        flex: 3,
                        child: _CenterZone(
                          missionState: missionState,
                          faultType: faultType,
                          batteryPercent: robotStatus.batteryPercent,
                          isRfid: isRfid,
                          isStorageOpen: isStorageOpen,
                          hasFault: hasFault,
                          isComplete: isComplete,
                          isVisionFailed: isVisionFailed,
                          orderId: orderId,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // -- RIGHT: Telemetry + Env + Order Items --
                      SizedBox(
                        width: 240,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              RobotTelemetryCard(
                                mode: robotStatus.mode,
                                batteryPercent: robotStatus.batteryPercent,
                                storageState: robotStatus.storageState,
                                isConnected: robotStatus.isConnected,
                                missionState: missionState,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 12),
                              EnvironmentStatusCard(
                                missionState: missionState,
                                faultType: faultType,
                                isConnected: robotStatus.isConnected,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 12),
                              if (order != null)
                                OrderItemsCard(
                                  items: order.items,
                                  missionState: missionState,
                                  totalPrice: order.totalPrice,
                                  isDark: isDark,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --------------- DEBUG TOOLBAR ---------------
                const SizedBox(height: 10),
                _DebugToolbar(orderId: orderId, isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// NAV-GRID BACKGROUND -- animated grid overlay (dark mode)
// -----------------------------------------------------------------------------
class _NavGridBackground extends StatefulWidget {
  const _NavGridBackground();

  @override
  State<_NavGridBackground> createState() => _NavGridBackgroundState();
}

class _NavGridBackgroundState extends State<_NavGridBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) =>
          CustomPaint(painter: _NavGridPainter(sweepPhase: _ctrl.value)),
    );
  }
}

class _NavGridPainter extends CustomPainter {
  _NavGridPainter({required this.sweepPhase});
  final double sweepPhase;

  @override
  void paint(Canvas canvas, Size size) {
    const step = 56.0;
    final linePaint = Paint()
      ..color = const Color(0xFF1A2540).withValues(alpha: 0.55)
      ..strokeWidth = 0.5;

    // grid lines
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // junction dots
    final dotPaint = Paint()
      ..color = const Color(0xFF2ECC8E).withValues(alpha: 0.08);
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }

    // glow sweep (horizontal)
    final sweepX = sweepPhase * size.width;
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF2ECC8E).withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(sweepX - 120, 0, 240, size.height));
    canvas.drawRect(
      Rect.fromLTWH(sweepX - 120, 0, 240, size.height),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NavGridPainter old) =>
      sweepPhase != old.sweepPhase;
}

// -----------------------------------------------------------------------------
// CENTER ZONE  -- with animated crossfade between state layouts
// -----------------------------------------------------------------------------
class _CenterZone extends StatefulWidget {
  const _CenterZone({
    required this.missionState,
    required this.faultType,
    required this.batteryPercent,
    required this.isRfid,
    required this.isStorageOpen,
    required this.hasFault,
    required this.isComplete,
    required this.isVisionFailed,
    required this.orderId,
    required this.isDark,
  });

  final MissionState missionState;
  final FaultType faultType;
  final int batteryPercent;
  final bool isRfid;
  final bool isStorageOpen;
  final bool hasFault;
  final bool isComplete;
  final bool isVisionFailed;
  final String orderId;
  final bool isDark;

  @override
  State<_CenterZone> createState() => _CenterZoneState();
}

class _CenterZoneState extends State<_CenterZone>
    with SingleTickerProviderStateMixin {
  // A unique key based on the visible "section" so AnimatedSwitcher
  // knows when to trigger the transition.
  String get _layoutKey {
    if (widget.hasFault) return 'fault_${widget.faultType.name}';
    if (widget.isComplete) return 'complete';
    if (widget.isStorageOpen) return 'storage_open';
    if (widget.isRfid) return 'rfid';
    return 'progress_${widget.missionState.name}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: ClipRect(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Column(
              key: ValueKey<String>(_layoutKey),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.hasFault) ...[
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: MissionAlertBanner(
                      missionState: widget.missionState,
                      faultType: widget.faultType,
                      isDark: widget.isDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Vision fail: clean "Return to Dashboard" — looks like a
                  // business outcome, not a system error
                  if (widget.isVisionFailed)
                    Material(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => context.go(RouteNames.customerHome),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.dashboard_rounded,
                                size: 18,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Return to Dashboard',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.warning,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
                if (widget.isComplete && !widget.hasFault) ...[
                  _DeliveryCompleteCard(
                    orderId: widget.orderId,
                    isDark: widget.isDark,
                  ),
                  const SizedBox(height: 24),
                ],
                // -- Storage opened: "I took my order" panel --
                if (widget.isStorageOpen && !widget.hasFault) ...[
                  MissionProgressCircle(
                    missionState: widget.missionState,
                    faultType: widget.faultType,
                    batteryPercent: widget.batteryPercent,
                    isDark: widget.isDark,
                  ),
                  const SizedBox(height: 20),
                  _CollectOrderPanel(isDark: widget.isDark),
                ] else
                // -- RFID state: panel BELOW the robot --
                if (widget.isRfid && !widget.hasFault) ...[
                  MissionProgressCircle(
                    missionState: widget.missionState,
                    faultType: widget.faultType,
                    batteryPercent: widget.batteryPercent,
                    isDark: widget.isDark,
                  ),
                  const SizedBox(height: 20),
                  RfidScanPanel(isDark: widget.isDark),
                ] else if (!widget.isComplete || widget.hasFault)
                  MissionProgressCircle(
                    missionState: widget.missionState,
                    faultType: widget.faultType,
                    batteryPercent: widget.batteryPercent,
                    isDark: widget.isDark,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DEBUG TOOLBAR -- 4 simulation buttons
// -----------------------------------------------------------------------------
class _DebugToolbar extends ConsumerWidget {
  const _DebugToolbar({required this.orderId, required this.isDark});
  final String orderId;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ds = ref.read(mockRobotDataSourceProvider);
    final btnBg = isDark
        ? AppColors.surface.withValues(alpha: 0.7)
        : AppColors.lightSurface.withValues(alpha: 0.85);
    final border = isDark ? AppColors.cardBorder : AppColors.lightCardBorder;
    final textColor = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: btnBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bug_report_rounded, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            'DEBUG',
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 10,
              color: textColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 12),
          // RFID attempt counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'RFID ${ds.rfidAttempts}/${ds.maxRfidAttempts}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.info,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 20),
          _DebugBtn(
            label: '⚠️ Add Obstacle',
            color: AppColors.warning,
            isDark: isDark,
            onTap: () =>
                ref.read(mockRobotDataSourceProvider).simulateObstacle(orderId),
          ),
          const SizedBox(width: 10),
          _DebugBtn(
            label: '✅ Release Obstacle',
            color: AppColors.success,
            isDark: isDark,
            onTap: () => ref.read(mockRobotDataSourceProvider).resetFault(),
          ),
          const SizedBox(width: 10),
          _DebugBtn(
            label: '❌ Wrong RFID',
            color: AppColors.danger,
            isDark: isDark,
            onTap: () =>
                ref.read(mockRobotDataSourceProvider).simulateRfidFail(orderId),
          ),
          const SizedBox(width: 10),
          _DebugBtn(
            label: '✅ Correct RFID',
            color: AppColors.primary,
            isDark: isDark,
            onTap: () => ref
                .read(mockRobotDataSourceProvider)
                .simulateCorrectRfid(orderId),
          ),
        ],
      ),
    );
  }
}

class _DebugBtn extends StatelessWidget {
  const _DebugBtn({
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: isDark ? 0.12 : 0.10),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 11,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DELIVERY COMPLETE CARD
// -----------------------------------------------------------------------------
class _DeliveryCompleteCard extends StatefulWidget {
  const _DeliveryCompleteCard({required this.orderId, required this.isDark});
  final String orderId;
  final bool isDark;

  @override
  State<_DeliveryCompleteCard> createState() => _DeliveryCompleteCardState();
}

class _DeliveryCompleteCardState extends State<_DeliveryCompleteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subText = widget.isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final glowOpacity = 0.08 + _ctrl.value * 0.12;
        return Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.success.withValues(
                alpha: 0.3 + _ctrl.value * 0.2,
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: glowOpacity),
                blurRadius: 32,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 42,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'DELIVERY COMPLETE',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.success,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enjoy your items! The robot is returning to base.',
                style: AppTextStyles.bodyMedium.copyWith(color: subText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Material(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => context.go(RouteNames.customerHome),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.dashboard_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Return to Dashboard',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// _ThemeToggle -- dark / light switch pill
// -------------------------------------------------------------
class _ThemeToggle extends ConsumerWidget {
  const _ThemeToggle({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(themeModeProvider.notifier).state = !isDark,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              size: 18,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            const SizedBox(width: 6),
            Text(
              isDark ? 'Dark' : 'Light',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// _CollectOrderPanel
// =============================================================================

/// Pulsing green card + "I Took My Order" button shown during [storageOpened].
class _CollectOrderPanel extends ConsumerStatefulWidget {
  const _CollectOrderPanel({required this.isDark});
  final bool isDark;

  @override
  ConsumerState<_CollectOrderPanel> createState() => _CollectOrderPanelState();
}

class _CollectOrderPanelState extends ConsumerState<_CollectOrderPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_sent) return;
    setState(() => _sent = true);
    if (kUseLiveBackend) {
      ref.read(webSocketClientProvider).send({'type': kMsgStorageCloseRequest});
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Order collected — closing storage…'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF34C77B);
    final bg = widget.isDark
        ? const Color(0xFF0F2A1E)
        : const Color(0xFFE8FFF4);

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) => Container(
        width: 230,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: green.withValues(alpha: _pulseAnim.value),
            width: 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: green.withValues(alpha: _pulseAnim.value * 0.35),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: child,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, color: green, size: 36),
          const SizedBox(height: 10),
          Text(
            'Storage is Open',
            style: AppTextStyles.labelLarge.copyWith(
              color: green,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Collect your order now',
            style: AppTextStyles.bodySmall.copyWith(
              color: widget.isDark ? Colors.white60 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sent ? null : _onTap,
              icon: Icon(_sent ? Icons.check_circle : Icons.check, size: 18),
              label: Text(_sent ? 'Confirmed' : 'I Took My Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _sent ? Colors.grey.shade600 : green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
