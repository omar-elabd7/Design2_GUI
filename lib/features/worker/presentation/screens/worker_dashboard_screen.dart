import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/models/mission_update.dart';
import '../../../robot_status/presentation/providers/mission_stream_provider.dart';
import '../../../robot_status/presentation/providers/robot_status_provider.dart';
import '../providers/teleop_provider.dart';
import '../providers/worker_control_provider.dart';

// ─── accent (same in both modes) ─────────────────────────────────────────────
const _kGreen = Color(0xFF2ECC8E);

// ─── palette helpers ─────────────────────────────────────────────────────────
Color _bg(bool d) => d ? const Color(0xFF0A0F1A) : AppColors.lightBackground;
Color _card(bool d) =>
    d ? const Color(0xFF0F1825) : AppColors.lightCardBackground;
Color _cardBorder(bool d) =>
    d ? const Color(0xFF1A2A3A) : AppColors.lightCardBorder;
Color _cardBorderGreen(bool d) =>
    d ? const Color(0xFF1A3A2A) : const Color(0xFFB8E6D4);
Color _btnBase(bool d) => d ? const Color(0xFF0D1F2D) : const Color(0xFFEDF2F7);
Color _textPrimary(bool d) =>
    d ? AppColors.textPrimary : AppColors.lightTextPrimary;
Color _textSecondary(bool d) =>
    d ? AppColors.textSecondary : AppColors.lightTextSecondary;
Color _textMuted(bool d) => d ? AppColors.textMuted : AppColors.lightTextMuted;

// ─── inherited theme propagation ─────────────────────────────────────────────
class _DashTheme extends InheritedWidget {
  const _DashTheme({required this.isDark, required super.child});
  final bool isDark;

  static bool of(BuildContext ctx) =>
      ctx.dependOnInheritedWidgetOfExactType<_DashTheme>()!.isDark;

  @override
  bool updateShouldNotify(_DashTheme old) => old.isDark != isDark;
}

// =============================================================================
//  WorkerDashboardScreen
// =============================================================================

class WorkerDashboardScreen extends ConsumerStatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  ConsumerState<WorkerDashboardScreen> createState() =>
      _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends ConsumerState<WorkerDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider);
    return _DashTheme(
      isDark: isDark,
      child: Scaffold(
        backgroundColor: _bg(isDark),
        body: Stack(
          children: [
            // ── animated background ──────────────────────────────────────────
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bgCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _WorkerGridPainter(
                    phase: _bgCtrl.value,
                    isDark: isDark,
                  ),
                ),
              ),
            ),

            // ── content ──────────────────────────────────────────────────────
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── LEFT ──────────────────────────────────────────────
                    Expanded(
                      flex: 55,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ManualControlCard(pulseCtrl: _pulseCtrl),
                            const SizedBox(height: 12),
                            _StorageCard(),
                            const SizedBox(height: 12),
                            _MechanismCard(),
                            const SizedBox(height: 12),
                            const SizedBox(height: 220, child: _EventLogCard()),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ── RIGHT ─────────────────────────────────────────────
                    Expanded(
                      flex: 45,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _RobotStatusCard(pulseCtrl: _pulseCtrl),
                            const SizedBox(height: 12),
                            _BatteryCard(),
                            const SizedBox(height: 12),
                            _ActiveFaultsCard(),
                            const SizedBox(height: 12),
                            _RobotModeCard(),
                            const SizedBox(height: 12),
                            const _RecentActivityCard(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ), // Positioned.fill
          ],
        ),
      ),
    );
  }
}

// =============================================================================
//  Animated background painter
// =============================================================================

class _WorkerGridPainter extends CustomPainter {
  _WorkerGridPainter({required this.phase, required this.isDark});
  final double phase;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    const step = 52.0;

    // grid lines
    final linePaint = Paint()
      ..color = isDark
          ? const Color(0xFF0E2A1A).withValues(alpha: 0.7)
          : const Color(0xFFDDE9E3).withValues(alpha: 0.9)
      ..strokeWidth = 0.6;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // junction dots
    final dotPaint = Paint()
      ..color = _kGreen.withValues(alpha: isDark ? 0.07 : 0.12);
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.4, dotPaint);
      }
    }

    // horizontal sweep glow
    final sweepX = phase * (size.width + 240) - 120;
    final glowH = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          _kGreen.withValues(alpha: isDark ? 0.055 : 0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(sweepX - 120, 0, 240, size.height));
    canvas.drawRect(Rect.fromLTWH(sweepX - 120, 0, 240, size.height), glowH);

    // vertical drift glow
    final sweepY = ((phase * 1.4) % 1.0) * (size.height + 180) - 90;
    final glowV = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          _kGreen.withValues(alpha: isDark ? 0.03 : 0.02),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, sweepY - 90, size.width, 180));
    canvas.drawRect(Rect.fromLTWH(0, sweepY - 90, size.width, 180), glowV);

    // corner radiant glow (bottom-left)
    final rPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              _kGreen.withValues(alpha: isDark ? 0.06 : 0.04),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(0, size.height),
              radius: size.height * 0.55,
            ),
          );
    canvas.drawRect(Offset.zero & size, rPaint);
  }

  @override
  bool shouldRepaint(_WorkerGridPainter old) =>
      old.phase != phase || old.isDark != isDark;
}

// =============================================================================
//  Manual Control Card
// =============================================================================

class _ManualControlCard extends ConsumerStatefulWidget {
  const _ManualControlCard({required this.pulseCtrl});
  final AnimationController pulseCtrl;

  @override
  ConsumerState<_ManualControlCard> createState() => _ManualControlCardState();
}

class _ManualControlCardState extends ConsumerState<_ManualControlCard> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dir = ref.watch(teleopProvider);
    final n = ref.read(teleopProvider.notifier);
    final isDark = _DashTheme.of(context);

    return _Card(
      child: GestureDetector(
        onTap: () => _focus.requestFocus(),
        child: KeyboardListener(
          focusNode: _focus,
          onKeyEvent: (e) {
            if (e is KeyDownEvent) n.onKeyDown(e.logicalKey);
            if (e is KeyUpEvent) n.onKeyUp(e.logicalKey);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── header ────────────────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.gamepad_rounded, color: _kGreen, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Manual Control',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: _textPrimary(isDark),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'WASD · Q/E rotate · diagonals',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _textMuted(isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── control grid ──────────────────────────────────────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1 : Q  | W  | E
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DpadBtn(
                          icon: Icons.rotate_left_rounded,
                          label: 'Q',
                          active:
                              dir == TeleopDirection.rotateLeft ||
                              dir == TeleopDirection.forwardRotateLeft ||
                              dir == TeleopDirection.backwardRotateLeft ||
                              dir == TeleopDirection.leftRotateLeft ||
                              dir == TeleopDirection.rightRotateLeft,
                          onDown: () =>
                              n.startCommand(TeleopDirection.rotateLeft),
                          onUp: () => n.stopCommand(),
                        ),
                        const SizedBox(width: 8),
                        _DpadBtn(
                          icon: Icons.arrow_upward_rounded,
                          label: 'W',
                          active:
                              dir == TeleopDirection.forward ||
                              dir == TeleopDirection.forwardLeft ||
                              dir == TeleopDirection.forwardRight ||
                              dir == TeleopDirection.forwardRotateLeft ||
                              dir == TeleopDirection.forwardRotateRight,
                          onDown: () => n.startCommand(TeleopDirection.forward),
                          onUp: () => n.stopCommand(),
                        ),
                        const SizedBox(width: 8),
                        _DpadBtn(
                          icon: Icons.rotate_right_rounded,
                          label: 'E',
                          active:
                              dir == TeleopDirection.rotateRight ||
                              dir == TeleopDirection.forwardRotateRight ||
                              dir == TeleopDirection.backwardRotateRight ||
                              dir == TeleopDirection.leftRotateRight ||
                              dir == TeleopDirection.rightRotateRight,
                          onDown: () =>
                              n.startCommand(TeleopDirection.rotateRight),
                          onUp: () => n.stopCommand(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row 2 : A  | STOP | D
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DpadBtn(
                          icon: Icons.arrow_back_rounded,
                          label: 'A',
                          active:
                              dir == TeleopDirection.left ||
                              dir == TeleopDirection.forwardLeft ||
                              dir == TeleopDirection.backwardLeft ||
                              dir == TeleopDirection.leftRotateLeft ||
                              dir == TeleopDirection.leftRotateRight,
                          onDown: () => n.startCommand(TeleopDirection.left),
                          onUp: () => n.stopCommand(),
                        ),
                        const SizedBox(width: 8),
                        _StopBtn(onPressed: () => n.stopCommand()),
                        const SizedBox(width: 8),
                        _DpadBtn(
                          icon: Icons.arrow_forward_rounded,
                          label: 'D',
                          active:
                              dir == TeleopDirection.right ||
                              dir == TeleopDirection.forwardRight ||
                              dir == TeleopDirection.backwardRight ||
                              dir == TeleopDirection.rightRotateLeft ||
                              dir == TeleopDirection.rightRotateRight,
                          onDown: () => n.startCommand(TeleopDirection.right),
                          onUp: () => n.stopCommand(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row 3 : (empty) | S | (empty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 76),
                        _DpadBtn(
                          icon: Icons.arrow_downward_rounded,
                          label: 'S',
                          active:
                              dir == TeleopDirection.backward ||
                              dir == TeleopDirection.backwardLeft ||
                              dir == TeleopDirection.backwardRight ||
                              dir == TeleopDirection.backwardRotateLeft ||
                              dir == TeleopDirection.backwardRotateRight,
                          onDown: () =>
                              n.startCommand(TeleopDirection.backward),
                          onUp: () => n.stopCommand(),
                        ),
                        const SizedBox(width: 76),
                      ],
                    ),
                  ],
                ),
              ),

              // ── current direction label ───────────────────────────────
              const SizedBox(height: 12),
              Center(
                child: Text(
                  dir == TeleopDirection.stop
                      ? '● STOPPED'
                      : '▶ ${dir.name.replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m[0]}').toUpperCase().trim()}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: dir == TeleopDirection.stop
                        ? _textMuted(isDark)
                        : _kGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DpadBtn extends StatelessWidget {
  const _DpadBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onDown,
    required this.onUp,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onDown;
  final VoidCallback onUp;

  @override
  Widget build(BuildContext context) {
    final isDark = _DashTheme.of(context);
    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: active ? _kGreen.withValues(alpha: 0.18) : _btnBase(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? _kGreen : _cardBorder(isDark),
            width: active ? 1.8 : 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _kGreen.withValues(alpha: 0.25),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active ? _kGreen : _textSecondary(isDark),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: active ? _kGreen : _textMuted(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StopBtn extends StatelessWidget {
  const _StopBtn({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.danger.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.danger.withValues(alpha: 0.15),
              blurRadius: 12,
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stop_rounded, color: AppColors.danger, size: 26),
            SizedBox(height: 2),
            Text(
              'STOP',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppColors.danger,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
//  Storage Card
// =============================================================================

class _StorageCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = _DashTheme.of(context);
    final storageAsync = ref.watch(workerStorageStateProvider);
    final state = storageAsync.asData?.value ?? StorageState.closed;
    final isOpen = state == StorageState.open;
    final isTrans =
        state == StorageState.opening || state == StorageState.closing;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_rounded, color: _kGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                'Storage Compartment',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: _textPrimary(isDark),
                ),
              ),
              const Spacer(),
              _StateChip(
                label: state.label,
                color: isOpen
                    ? AppColors.warning
                    : state == StorageState.fault
                    ? AppColors.danger
                    : _textSecondary(isDark),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // storage visual
          Center(
            child: SizedBox(
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // glow ring
                  if (isOpen)
                    Container(
                      width: 140,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _kGreen.withValues(alpha: 0.25),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  Container(
                    width: 130,
                    height: 65,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0B1820)
                          : AppColors.lightInputFill,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isOpen
                            ? _kGreen.withValues(alpha: 0.6)
                            : _cardBorder(isDark),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
                      color: isOpen ? _kGreen : _textSecondary(isDark),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // buttons
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  label: 'Open',
                  icon: Icons.lock_open_rounded,
                  active: isOpen,
                  disabled: isOpen || isTrans,
                  onPressed: isOpen || isTrans
                      ? null
                      : () => ref
                            .read(workerControlProvider.notifier)
                            .openStorage(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionBtn(
                  label: 'Close',
                  icon: Icons.lock_rounded,
                  active: false,
                  danger: true,
                  disabled: !isOpen || isTrans,
                  onPressed: !isOpen || isTrans
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

// =============================================================================
//  Mechanism Card  (store / home positions + gripper)
// =============================================================================

class _MechanismCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = _DashTheme.of(context);
    final n = ref.read(workerControlProvider.notifier);
    final gripperAsync = ref.watch(workerGripperStateProvider);
    final gripperState = gripperAsync.asData?.value ?? GripperState.closed;
    final isGripperOpen = gripperState == GripperState.open;
    final isGripperTrans =
        gripperState == GripperState.opening ||
        gripperState == GripperState.closing;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── header ──────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.precision_manufacturing_rounded,
                color: _kGreen,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Mechanism Control',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: _textPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── mechanism position ──────────────────────────────────────────
          Text(
            'POSITION',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: _textMuted(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  label: 'Store',
                  icon: Icons.inventory_2_rounded,
                  active: false,
                  onPressed: () => n.setMechanismPosition('store'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionBtn(
                  label: 'Home',
                  icon: Icons.home_rounded,
                  active: false,
                  onPressed: () => n.setMechanismPosition('home'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── gripper ─────────────────────────────────────────────────────
          Text(
            'GRIPPER',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: _textMuted(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  label: 'Open Gripper',
                  icon: Icons.open_in_full_rounded,
                  active: isGripperOpen,
                  disabled: isGripperOpen || isGripperTrans,
                  onPressed: isGripperOpen || isGripperTrans
                      ? null
                      : () => n.openGripper(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionBtn(
                  label: 'Close Gripper',
                  icon: Icons.close_fullscreen_rounded,
                  active: false,
                  danger: true,
                  disabled: !isGripperOpen || isGripperTrans,
                  onPressed: !isGripperOpen || isGripperTrans
                      ? null
                      : () => n.closeGripper(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  Robot Status Card (with robot image)
// =============================================================================

class _RobotStatusCard extends ConsumerWidget {
  const _RobotStatusCard({required this.pulseCtrl});
  final AnimationController pulseCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = _DashTheme.of(context);
    final status = ref.watch(robotStatusProvider);

    return _Card(
      glowBorder: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── status rows ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.monitor_heart_rounded,
                      color: _kGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Robot Status',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: _textPrimary(isDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _StatusRow(
                  icon: Icons.settings_rounded,
                  label: 'Mode',
                  value: status.mode.label,
                  valueColor: status.mode.color,
                ),
                const SizedBox(height: 10),
                _StatusRow(
                  icon: Icons.flag_rounded,
                  label: 'Mission',
                  value: status.missionState.label,
                  valueColor: _textPrimary(isDark),
                ),
                const SizedBox(height: 10),
                _StatusRow(
                  icon: Icons.inventory_2_outlined,
                  label: 'Storage',
                  value: status.storageState.label,
                  valueColor: status.storageState == StorageState.open
                      ? AppColors.warning
                      : _textSecondary(isDark),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── robot image ───────────────────────────────────────────────────
          AnimatedBuilder(
            animation: pulseCtrl,
            builder: (_, child) => Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _kGreen.withValues(
                      alpha: 0.12 + pulseCtrl.value * 0.12,
                    ),
                    blurRadius: 28 + pulseCtrl.value * 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: child,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/robot.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final isDark = _DashTheme.of(context);
    return Row(
      children: [
        Icon(icon, size: 13, color: _textMuted(isDark)),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: _textSecondary(isDark),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? _textPrimary(isDark),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
//  Battery Card
// =============================================================================

class _BatteryCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = _DashTheme.of(context);
    final status = ref.watch(robotStatusProvider);
    final pct = status.batteryPercent;
    final isCrit = Helpers.isBatteryCritical(pct);
    final isLow = Helpers.isBatteryLow(pct);
    final color = isCrit
        ? AppColors.batteryLow
        : isLow
        ? AppColors.batteryMedium
        : _kGreen;
    final mins = pct * 2; // rough estimate
    final h = mins ~/ 60;
    final m = mins % 60;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCrit
                    ? Icons.battery_alert_rounded
                    : Icons.battery_charging_full_rounded,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Battery',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: _textPrimary(isDark),
                ),
              ),
              const Spacer(),
              if (isCrit)
                _StateChip(label: 'CRITICAL', color: AppColors.danger)
              else if (isLow)
                _StateChip(label: 'LOW', color: AppColors.warning),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                'Estimated runtime: ${h}h ${m}m',
                style: AppTextStyles.labelSmall.copyWith(
                  color: _textMuted(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 8,
              backgroundColor: _cardBorder(isDark),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  Robot Mode Card
// =============================================================================

class _RobotModeCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = _DashTheme.of(context);
    final mode = ref.watch(workerControlProvider);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: _kGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                'Robot Mode',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: _textPrimary(isDark),
                ),
              ),
              const Spacer(),
              _StateChip(label: mode.label, color: mode.color),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ModeBtn(
                label: 'Online',
                icon: Icons.wifi_rounded,
                active:
                    mode == RobotMode.online || mode == RobotMode.autonomous,
                onTap: () =>
                    ref.read(workerControlProvider.notifier).setOnline(),
              ),
              const SizedBox(width: 8),
              _ModeBtn(
                label: 'Offline',
                icon: Icons.wifi_off_rounded,
                danger: true,
                active: mode == RobotMode.offline,
                onTap: () =>
                    ref.read(workerControlProvider.notifier).setOffline(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ModeBtn(
                label: 'Manual',
                icon: Icons.gamepad_rounded,
                secondary: true,
                active: mode == RobotMode.manual,
                onTap: () =>
                    ref.read(workerControlProvider.notifier).setManual(),
              ),
              const SizedBox(width: 8),
              _ModeBtn(
                label: 'Autonomous',
                icon: Icons.auto_mode_rounded,
                active: mode == RobotMode.autonomous,
                onTap: () =>
                    ref.read(workerControlProvider.notifier).setAutonomous(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeBtn extends StatelessWidget {
  const _ModeBtn({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    this.danger = false,
    this.secondary = false,
  });
  final String label;
  final IconData icon;
  final bool active;
  final bool danger;
  final bool secondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = _DashTheme.of(context);
    final accent = danger
        ? AppColors.danger
        : secondary
        ? AppColors.secondary
        : _kGreen;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? accent.withValues(alpha: 0.15) : _btnBase(isDark),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? accent.withValues(alpha: 0.7)
                  : _cardBorder(isDark),
              width: active ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: active ? accent : _textSecondary(isDark),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? accent : _textSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//  Active Faults Card
// =============================================================================

class _ActiveFaultsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = _DashTheme.of(context);
    final status = ref.watch(robotStatusProvider);
    final fault = status.faultType;
    final hasFault = fault != FaultType.none;

    // Faults that require storekeeper intervention to clear
    const blockerFaults = {FaultType.rfidFailed};
    final isBlocker = blockerFaults.contains(fault);

    final accentColor = isBlocker ? AppColors.danger : AppColors.warning;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── header ──────────────────────────────────────────────────────
          Row(
            children: [
              Icon(
                hasFault
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_rounded,
                color: hasFault ? accentColor : _kGreen,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Active Faults',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: _textPrimary(isDark),
                ),
              ),
              const Spacer(),
              if (hasFault)
                _StateChip(
                  label: isBlocker ? 'BLOCKING' : 'WARNING',
                  color: accentColor,
                ),
            ],
          ),
          const SizedBox(height: 14),

          if (!hasFault)
            // ── no faults ─────────────────────────────────────────────────
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: _kGreen.withValues(alpha: 0.6),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'No active faults',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _textSecondary(isDark),
                  ),
                ),
              ],
            )
          else ...[
            // ── fault row ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentColor.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor,
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fault.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isBlocker
                              ? 'New orders are blocked until cleared'
                              : 'Robot may have limited capability',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: _textMuted(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── clear button ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: _ActionBtn(
                label: 'Clear All Faults',
                icon: Icons.playlist_remove_rounded,
                active: true,
                danger: true,
                onPressed: () =>
                    ref.read(workerControlProvider.notifier).clearFaults(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
//  Recent Activity Card
// =============================================================================

class _RecentActivityCard extends ConsumerWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = _DashTheme.of(context);
    final status = ref.watch(robotStatusProvider);

    // Build activity list from live state
    final items = <_ActivityItem>[
      _ActivityItem(
        label: status.isConnected ? 'Robot connected' : 'Robot disconnected',
        color: status.isConnected ? _kGreen : AppColors.danger,
        time: 'live',
      ),
      _ActivityItem(
        label: 'Battery status: ${status.batteryPercent}%',
        color: Helpers.isBatteryCritical(status.batteryPercent)
            ? AppColors.danger
            : Helpers.isBatteryLow(status.batteryPercent)
            ? AppColors.warning
            : _kGreen,
        time: 'live',
      ),
      _ActivityItem(
        label: 'Storage ${status.storageState.label.toLowerCase()}',
        color: status.storageState == StorageState.open
            ? AppColors.warning
            : _textSecondary(isDark),
        time: 'live',
      ),
      _ActivityItem(
        label: 'Mode: ${status.mode.label}',
        color: status.mode.color,
        time: 'live',
      ),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, color: _kGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                'Recent Activity',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: _textPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.color,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _textSecondary(isDark),
                      ),
                    ),
                  ),
                  Text(
                    item.time,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _textMuted(isDark),
                    ),
                  ),
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  const _ActivityItem({
    required this.label,
    required this.color,
    required this.time,
  });
  final String label;
  final Color color;
  final String time;
}

// =============================================================================
//  Event Log Card
// =============================================================================

class _EventLogCard extends ConsumerStatefulWidget {
  const _EventLogCard();

  @override
  ConsumerState<_EventLogCard> createState() => _EventLogCardState();
}

class _EventLogCardState extends ConsumerState<_EventLogCard> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _DashTheme.of(context);
    final updates = ref.watch(missionUpdatesProvider).asData?.value ?? const [];

    // Auto-scroll to bottom when new events arrive
    ref.listen(missionUpdatesProvider, (_, next) {
      final list = next.asData?.value;
      if (list != null && list.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.animateTo(
              _scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── header ────────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.terminal_rounded, color: _kGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                'Robot Event Log',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: _textPrimary(isDark),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _kGreen.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${updates.length}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _kGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── log list ──────────────────────────────────────────────────────
          Expanded(
            child: updates.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 28,
                          color: _textMuted(isDark).withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Waiting for robot events...',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _textMuted(isDark),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    itemCount: updates.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (_, i) => _LogRow(update: updates[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── single log row ───────────────────────────────────────────────────────────

class _LogRow extends StatelessWidget {
  const _LogRow({required this.update});
  final MissionUpdate update;

  Color _dotColor() {
    if (update.faultType != null && update.faultType != FaultType.none) {
      return AppColors.danger;
    }
    switch (update.state) {
      case MissionState.storageClosed:
      case MissionState.storageOpened:
        return _kGreen;
      case MissionState.headingToFruit:
      case MissionState.headingToCustomer:
      case MissionState.returning:
        return const Color(0xFF42A5F5);
      case MissionState.rfidAwaiting:
      case MissionState.visionChecking:
        return AppColors.warning;
      case MissionState.failed:
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _DashTheme.of(context);
    final time = DateFormat('HH:mm:ss').format(update.timestamp);
    final color = _dotColor();
    final isFault =
        update.faultType != null && update.faultType != FaultType.none;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // timestamp
          Text(
            time,
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              color: _textMuted(isDark),
            ),
          ),
          const SizedBox(width: 8),
          // dot
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 5),
                ],
              ),
            ),
          ),
          const SizedBox(width: 7),
          // message
          Expanded(
            child: Text(
              update.message,
              style: TextStyle(
                fontSize: 11,
                color: isFault ? AppColors.danger : _textPrimary(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  Shared card shell
// =============================================================================

class _Card extends StatelessWidget {
  const _Card({required this.child, this.glowBorder = false});
  final Widget child;
  final bool glowBorder;

  @override
  Widget build(BuildContext context) {
    final isDark = _DashTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: glowBorder ? _cardBorderGreen(isDark) : _cardBorder(isDark),
          width: glowBorder ? 1.2 : 1,
        ),
        boxShadow: glowBorder
            ? [
                BoxShadow(
                  color: _kGreen.withValues(alpha: 0.06),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ]
            : isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }
}

// =============================================================================
//  Shared small widgets
// =============================================================================

class _StateChip extends StatelessWidget {
  const _StateChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.active,
    required this.onPressed,
    this.disabled = false,
    this.danger = false,
  });
  final String label;
  final IconData icon;
  final bool active;
  final bool disabled;
  final bool danger;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = _DashTheme.of(context);
    final accent = danger ? AppColors.danger : _kGreen;
    final eff = disabled ? 0.35 : 1.0;

    return GestureDetector(
      onTap: onPressed,
      child: Opacity(
        opacity: eff,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: active ? accent.withValues(alpha: 0.18) : _btnBase(isDark),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active
                  ? accent.withValues(alpha: 0.7)
                  : _cardBorder(isDark),
              width: active ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? accent : _textSecondary(isDark),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? accent : _textSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
