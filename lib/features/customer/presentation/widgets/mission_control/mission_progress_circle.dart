import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/asset_paths.dart';
import '../../../../../shared/models/enums.dart';

class MissionProgressCircle extends StatefulWidget {
  const MissionProgressCircle({
    super.key,
    required this.missionState,
    required this.faultType,
    required this.batteryPercent,
    this.isDark = true,
  });

  final MissionState missionState;
  final FaultType faultType;
  final int batteryPercent;
  final bool isDark;

  @override
  State<MissionProgressCircle> createState() => _MissionProgressCircleState();
}

class _MissionProgressCircleState extends State<MissionProgressCircle>
    with TickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late AnimationController _rotateCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _radarCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _updateProgress();
  }

  @override
  void didUpdateWidget(covariant MissionProgressCircle old) {
    super.didUpdateWidget(old);
    if (old.missionState != widget.missionState) _updateProgress();
  }

  void _updateProgress() {
    _progressCtrl.animateTo(_stateProgress(), curve: Curves.easeInOutCubic);
  }

  double _stateProgress() {
    switch (widget.missionState) {
      case MissionState.idle:
        return 0.0;
      case MissionState.missionReceived:
        return 0.10;
      case MissionState.headingToFruit:
        return 0.22;
      case MissionState.visionChecking:
        return 0.35;
      case MissionState.storing:
        return 0.48;
      case MissionState.headingToCustomer:
        return 0.62;
      case MissionState.rfidAwaiting:
        return 0.74;
      case MissionState.storageOpened:
        return 0.85;
      case MissionState.storageClosed:
        return 1.0;
      case MissionState.returning:
        return 1.0;
      case MissionState.failed:
        return 0.0;
    }
  }

  Color _ringColor() {
    if (widget.faultType != FaultType.none) return AppColors.danger;
    switch (widget.missionState) {
      case MissionState.idle:
        return widget.isDark ? AppColors.textMuted : AppColors.lightTextMuted;
      case MissionState.headingToFruit:
      case MissionState.headingToCustomer:
      case MissionState.returning:
        return const Color(0xFF42A5F5);
      case MissionState.visionChecking:
      case MissionState.storing:
        return AppColors.secondary;
      case MissionState.rfidAwaiting:
        return AppColors.warning;
      case MissionState.storageOpened:
      case MissionState.storageClosed:
        return AppColors.success;
      case MissionState.failed:
        return AppColors.danger;
      default:
        return AppColors.primaryLight;
    }
  }

  String _contextMessage() {
    if (widget.faultType != FaultType.none) {
      switch (widget.faultType) {
        case FaultType.obstacleBlocked:
          return 'Obstacle detected - rerouting...';
        case FaultType.lowBattery:
          return 'Low battery: ${widget.batteryPercent}% remaining';
        case FaultType.criticalBattery:
          return 'CRITICAL - returning to base';
        case FaultType.outOfStock:
          return 'Item out of stock';
        case FaultType.storageFault:
          return 'Storage compartment fault';
        case FaultType.communicationLost:
          return 'Communication lost';
        case FaultType.missionCancelled:
          return 'Mission cancelled';
        default:
          return '';
      }
    }
    switch (widget.missionState) {
      case MissionState.idle:
        return 'Waiting for mission...';
      case MissionState.missionReceived:
        return 'Mission accepted! Initializing...';
      case MissionState.headingToFruit:
        return 'Heading to fruit stock area...';
      case MissionState.visionChecking:
        return 'Checking stock availability...';
      case MissionState.storing:
        return 'Collecting fruit into storage...';
      case MissionState.headingToCustomer:
        return 'On the way to your location!';
      case MissionState.rfidAwaiting:
        return 'Please scan your RFID card';
      case MissionState.storageOpened:
        return 'Storage open - collect your items!';
      case MissionState.storageClosed:
        return 'Delivery complete 🎉';
      case MissionState.returning:
        return 'Robot returning to home position';
      case MissionState.failed:
        return 'Mission failed';
    }
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _rotateCtrl.dispose();
    _pulseCtrl.dispose();
    _radarCtrl.dispose();
    _particleCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _ringColor();
    const double vizSize = 460;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // -- Robot Radar Visualizer --
        SizedBox(
          width: vizSize,
          height: vizSize,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _progressCtrl,
              _rotateCtrl,
              _pulseCtrl,
              _radarCtrl,
              _particleCtrl,
              _floatCtrl,
            ]),
            builder: (_, __) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // -- Particle dots --
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ParticlePainter(
                        phase: _particleCtrl.value,
                        color: color,
                      ),
                    ),
                  ),

                  // -- 3 staggered radar rings --
                  _RadarRing(
                    progress: _radarCtrl.value,
                    maxR: vizSize / 2 - 10,
                    delay: 0.00,
                    color: color,
                  ),
                  _RadarRing(
                    progress: _radarCtrl.value,
                    maxR: vizSize / 2 - 40,
                    delay: 0.33,
                    color: color,
                  ),
                  _RadarRing(
                    progress: _radarCtrl.value,
                    maxR: vizSize / 2 - 75,
                    delay: 0.66,
                    color: color,
                  ),

                  // -- Progress arc + scan dot --
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RingPainter(
                        progress: _progressCtrl.value,
                        color: color,
                        rotation: _rotateCtrl.value * 2 * pi,
                        glowOpacity: 0.15 + _pulseCtrl.value * 0.25,
                        isDark: widget.isDark,
                      ),
                    ),
                  ),

                  // -- Inner glow halo --
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          color.withValues(alpha: 0.08),
                          color.withValues(alpha: 0.02),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),

                  // -- Pulsing border circle --
                  Container(
                    width: 185 + _pulseCtrl.value * 8,
                    height: 185 + _pulseCtrl.value * 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(
                          alpha: 0.2 + _pulseCtrl.value * 0.15,
                        ),
                        width: 1.5,
                      ),
                    ),
                  ),

                  // -- Floating robot image --
                  Transform.translate(
                    offset: Offset(0, -5 + _floatCtrl.value * 10),
                    child: Image.asset(
                      kRobotImagePath,
                      width: 420,
                      height: 420,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.smart_toy_rounded, size: 72, color: color),
                    ),
                  ),

                  // -- Rotating scan arc --
                  Transform.rotate(
                    angle: _rotateCtrl.value * 2 * pi,
                    child: CustomPaint(
                      size: const Size(200, 200),
                      painter: _ScanArcPainter(color: color),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            _contextMessage(),
            key: ValueKey<String>(_contextMessage()),
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeOutCubic,
          child: Text(
            '${(_stateProgress() * 100).round()}% complete',
            key: ValueKey<int>((_stateProgress() * 100).round()),
            style: AppTextStyles.bodySmall.copyWith(
              color: widget.isDark
                  ? AppColors.textSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// RADAR RING  ? 3 staggered expanding + fading rings
// -----------------------------------------------------------------------------
class _RadarRing extends StatelessWidget {
  const _RadarRing({
    required this.progress,
    required this.maxR,
    required this.delay,
    required this.color,
  });
  final double progress;
  final double maxR;
  final double delay;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final phase = (progress + delay) % 1.0;
    final radius = maxR * phase;
    final opacity = (1.0 - phase) * 0.35;
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: opacity.clamp(0.0, 1.0)),
          width: 1.5,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PARTICLE DOTS ? floating ambient dots
// -----------------------------------------------------------------------------
class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.phase, required this.color});
  final double phase;
  final Color color;

  static final _rng = Random(99);
  static final _dots = List.generate(
    22,
    (_) => (
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      r: 1.0 + _rng.nextDouble() * 1.4,
      speed: 0.25 + _rng.nextDouble() * 0.6,
      alpha: 0.10 + _rng.nextDouble() * 0.20,
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _dots) {
      final yOff = (p.y + phase * p.speed) % 1.0;
      canvas.drawCircle(
        Offset(p.x * size.width, yOff * size.height),
        p.r,
        Paint()..color = color.withValues(alpha: p.alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      phase != old.phase || color != old.color;
}

// -----------------------------------------------------------------------------
// SCAN ARC ? rotating wedge around the robot
// -----------------------------------------------------------------------------
class _ScanArcPainter extends CustomPainter {
  _ScanArcPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 6,
      pi / 3,
      true,
      Paint()
        ..shader = SweepGradient(
          startAngle: -pi / 6,
          endAngle: pi / 6,
          colors: [
            Colors.transparent,
            color.withValues(alpha: 0.12),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(covariant _ScanArcPainter old) => color != old.color;
}

// -----------------------------------------------------------------------------
// PROGRESS RING + rotating dot
// -----------------------------------------------------------------------------
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.rotation,
    required this.glowOpacity,
    required this.isDark,
  });

  final double progress;
  final Color color;
  final double rotation;
  final double glowOpacity;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const strokeWidth = 6.0;

    // track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: isDark ? 0.06 : 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // progress arc
    final sweepAngle = 2 * pi * progress;
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        Paint()
          ..shader = SweepGradient(
            startAngle: 0,
            endAngle: sweepAngle,
            colors: [color.withValues(alpha: 0.4), color],
            transform: const GradientRotation(-pi / 2),
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }

    // rotating scan dot
    final dotAngle = rotation - pi / 2;
    final dotPos = Offset(
      center.dx + radius * cos(dotAngle),
      center.dy + radius * sin(dotAngle),
    );
    canvas.drawCircle(
      dotPos,
      3.5,
      Paint()
        ..color = color.withValues(alpha: 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(dotPos, 2, Paint()..color = color);

    // outer glow
    canvas.drawCircle(
      center,
      radius + 6,
      Paint()
        ..color = color.withValues(alpha: glowOpacity * 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      progress != old.progress ||
      color != old.color ||
      rotation != old.rotation ||
      glowOpacity != old.glowOpacity ||
      isDark != old.isDark;
}
