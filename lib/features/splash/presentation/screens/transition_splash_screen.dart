import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';


class TransitionSplashScreen extends StatefulWidget {
  const TransitionSplashScreen({
    super.key,
    required this.nextRoute,
    this.subtitle = 'Preparing systems...',
  });

  /// Full path to navigate to when the animation finishes.
  final String nextRoute;

  /// Text shown beneath the robot.
  final String subtitle;

  @override
  State<TransitionSplashScreen> createState() =>
      _TransitionSplashScreenState();
}

class _TransitionSplashScreenState extends State<TransitionSplashScreen>
    with TickerProviderStateMixin {
  // -- Controllers ------------------------------------------------------------
  late final AnimationController _fadeInCtrl;
  late final AnimationController _radarCtrl;
  late final AnimationController _progressCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _fadeOutCtrl;

  late final Animation<double> _fadeIn;
  late final Animation<double> _robotSlide;
  late final Animation<double> _progress;
  late final Animation<double> _fadeOut;

  // -- Particle positions (generated once) ------------------------------------
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    final rng = math.Random(42);
    _particles = List.generate(14, (_) {
      final angle = rng.nextDouble() * 2 * math.pi;
      final radius = 80 + rng.nextDouble() * 60;
      return _Particle(angle: angle, radius: radius, size: 2 + rng.nextDouble() * 2.5);
    });

    // 1) Fade-in
    _fadeInCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = CurvedAnimation(parent: _fadeInCtrl, curve: Curves.easeOut);
    _robotSlide = Tween<double>(begin: 18, end: 0).animate(
      CurvedAnimation(parent: _fadeInCtrl, curve: Curves.easeOut),
    );

    // 2) Radar ? infinite
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // 3) Progress
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _progress = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);

    // 4) Particles
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat();

    // 5) Fade-out
    _fadeOutCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _fadeOutCtrl, curve: Curves.easeIn),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    _fadeInCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _progressCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    await _fadeOutCtrl.forward();
    if (!mounted) return;
    context.go(widget.nextRoute);
  }

  @override
  void dispose() {
    _fadeInCtrl.dispose();
    _radarCtrl.dispose();
    _progressCtrl.dispose();
    _particleCtrl.dispose();
    _fadeOutCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: FadeTransition(
        opacity: _fadeOut,
        child: Center(
          child: FadeTransition(
            opacity: _fadeIn,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _radarCtrl,
                _progressCtrl,
                _particleCtrl,
                _robotSlide,
              ]),
              builder: (context, _) => _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // -- Robot + radar + particles --------------------------------
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Radar rings
              ..._buildRadarRings(),

              // Particles
              ..._buildParticles(),

              // Robot image (floating)
              Transform.translate(
                offset: Offset(0, _robotSlide.value),
                child: Image.asset(
                  kRobotImagePath,
                  width: 360,
                  height: 360,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.smart_toy_rounded,
                    size: 72,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // -- Subtitle ------------------------------------------------
        Text(
          widget.subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 20),

        // -- Progress bar --------------------------------------------
        SizedBox(
          width: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress.value,
              minHeight: 4,
              backgroundColor: AppColors.surface,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRadarRings() {
    final t = _radarCtrl.value;
    return List.generate(3, (i) {
      final phase = (t + i * 0.33) % 1.0;
      final radius = 60 + phase * 80;
      final opacity = (1 - phase).clamp(0.0, 0.35);
      return Positioned.fill(
        child: Center(
          child: Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryLight.withValues(alpha: opacity),
                width: 1.2,
              ),
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildParticles() {
    final t = _particleCtrl.value;
    return _particles.map((p) {
      final a = p.angle + t * 2 * math.pi * 0.3;
      final dx = math.cos(a) * p.radius;
      final dy = math.sin(a) * p.radius;
      final opacity = (0.15 + 0.35 * math.sin(t * math.pi * 2 + p.angle))
          .clamp(0.0, 0.5);
      return Positioned(
        left: 140 + dx - p.size / 2,
        top: 140 + dy - p.size / 2,
        child: Container(
          width: p.size,
          height: p.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryLight.withValues(alpha: opacity),
          ),
        ),
      );
    }).toList();
  }
}

class _Particle {
  final double angle;
  final double radius;
  final double size;
  const _Particle({
    required this.angle,
    required this.radius,
    required this.size,
  });
}
