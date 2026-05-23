import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/routing/route_names.dart';

// --- Boot sequence messages ------------------------------------------------
const _bootSteps = [
  (msg: 'Connecting to Robot Controller...', target: 0.18),
  (msg: 'Loading Navigation Engine...', target: 0.38),
  (msg: 'Initializing RFID Module...', target: 0.58),
  (msg: 'Preparing Control Interface...', target: 0.78),
  (msg: 'Launching Pluto...', target: 0.95),
  (msg: 'System Ready ...', target: 1.00),
];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // -- controllers ----------------------------------------------------------
  late final AnimationController _fadeInCtrl;   // logo + title fade
  late final AnimationController _radarCtrl;    // radar rings
  late final AnimationController _progressCtrl; // progress bar
  late final AnimationController _particleCtrl; // scanning dots
  late final AnimationController _finalPulseCtrl; // final pulse at 100%
  late final AnimationController _screenFadeCtrl; // screen fade-out

  // -- animations ------------------------------------------------------------
  late final Animation<double> _logoFade;
  late final Animation<double> _logoSlide;
  late final Animation<double> _robotFade;
  late final Animation<double> _progress;
  late final Animation<double> _screenFade;

  int _stepIndex = 0;
  bool _systemReady = false;

  @override
  void initState() {
    super.initState();

    // 1) Fade-in -- logo + title slide up in first 0.6s
    _fadeInCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoFade = CurvedAnimation(parent: _fadeInCtrl, curve: Curves.easeOut);
    _logoSlide = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: _fadeInCtrl, curve: Curves.easeOut),
    );
    _robotFade = CurvedAnimation(
      parent: _fadeInCtrl,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    // 2) Radar -- infinite repeat
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    // 3) Progress -- drives boot step ticker
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _progress = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeInOut,
    );
    _progressCtrl.addListener(_onProgressTick);

    // 4) Particle / scanning dots -- infinite slow drift
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // 5) Final pulse at 100%
    _finalPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 6) Screen fade-out to login
    _screenFadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _screenFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _screenFadeCtrl, curve: Curves.easeIn),
    );

    _startSequence();
  }

  void _onProgressTick() {
    final p = _progressCtrl.value;
    for (int i = 0; i < _bootSteps.length; i++) {
      if (p >= _bootSteps[i].target && i > _stepIndex) {
        if (mounted) setState(() => _stepIndex = i);
      }
    }
  }

  Future<void> _startSequence() async {
    // Slight delay, then fade in
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _fadeInCtrl.forward();

    // Start progress after logo fades in
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _progressCtrl.forward();

    // Wait for progress to finish
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    // "System Ready" state + final pulse
    setState(() => _systemReady = true);
    _finalPulseCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // Fade out screen ? navigate
    await _screenFadeCtrl.forward();
    if (!mounted) return;
    context.go(RouteNames.login);
  }

  @override
  void dispose() {
    _fadeInCtrl.dispose();
    _radarCtrl.dispose();
    _progressCtrl.dispose();
    _particleCtrl.dispose();
    _finalPulseCtrl.dispose();
    _screenFadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _screenFade,
      builder: (_, child) => Opacity(opacity: _screenFade.value, child: child),
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1220),
        body: Stack(
          children: [
            // -- Background layers ----------------------------------------
            const Positioned.fill(child: _BackgroundGradient()),
            Positioned.fill(child: _NavGridPainter(ctrl: _particleCtrl)),
            const _EdgeVignette(),

            // -- Particle dots --------------------------------------------
            Positioned.fill(
              child: _ParticleDots(animation: _particleCtrl),
            ),

            // -- Main content ---------------------------------------------
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo + title block
                  AnimatedBuilder(
                    animation: _fadeInCtrl,
                    builder: (_, __) => Opacity(
                      opacity: _logoFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _logoSlide.value),
                        child: _LogoBlock(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Robot + radar rings -- fills remaining space
                  Expanded(
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _robotFade,
                        _radarCtrl,
                        _finalPulseCtrl,
                      ]),
                      builder: (_, __) => Opacity(
                        opacity: _robotFade.value,
                        child: _RobotRadarSection(
                          radarAnim: _radarCtrl,
                          finalPulse: _finalPulseCtrl,
                        ),
                      ),
                    ),
                  ),

                  // Boot progress section
                  AnimatedBuilder(
                    animation: _progress,
                    builder: (_, __) => _BootProgress(
                      progress: _progress.value,
                      stepIndex: _stepIndex,
                      systemReady: _systemReady,
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BACKGROUND GRADIENT
// ---------------------------------------------------------------------------

class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B1220), // deep navy
            Color(0xFF0F1A2E), // slightly lighter navy
            Color(0xFF080D16), // near black
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NAV GRID BACKGROUND (CustomPaint -- grid + path lines)
// ---------------------------------------------------------------------------

class _NavGridPainter extends StatelessWidget {
  final AnimationController ctrl;
  const _NavGridPainter({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => CustomPaint(
        painter: _NavGridCustomPainter(phase: ctrl.value),
      ),
    );
  }
}

class _NavGridCustomPainter extends CustomPainter {
  final double phase;
  _NavGridCustomPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    // -- Faint grid -----------------------------------------------------
    final gridPaint = Paint()
      ..color = const Color(0xFF2ECC71).withValues(alpha: 0.032)
      ..strokeWidth = 0.6;

    const spacing = 56.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // -- Intersection dots ----------------------------------------------
    final dotPaint = Paint()
      ..color = const Color(0xFF38D9A9).withValues(alpha: 0.10);
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.4, dotPaint);
      }
    }

    // -- Animated teal glow sweep (moving horizontally) -----------------
    final glowX = size.width * phase;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF38D9A9).withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(glowX, size.height * 0.6),
          radius: 280,
        ),
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);

    // -- Robot navigation path lines ------------------------------------
    final pathPaint = Paint()
      ..color = const Color(0xFF2ECC71).withValues(alpha: 0.09)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Horizontal path
    canvas.drawLine(Offset(0, cy + 80), Offset(size.width, cy + 80), pathPaint);
    // Two vertical lines
    canvas.drawLine(Offset(cx - 120, 0), Offset(cx - 120, size.height), pathPaint);
    canvas.drawLine(Offset(cx + 120, 0), Offset(cx + 120, size.height), pathPaint);

    // Path junction markers
    final junctionPaint = Paint()
      ..color = const Color(0xFF2ECC71).withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final pt in [
      Offset(cx - 120, cy + 80),
      Offset(cx + 120, cy + 80),
    ]) {
      canvas.drawCircle(pt, 5, junctionPaint);
    }
  }

  @override
  bool shouldRepaint(_NavGridCustomPainter old) => old.phase != phase;
}

// ---------------------------------------------------------------------------
// EDGE VIGNETTE
// ---------------------------------------------------------------------------

class _EdgeVignette extends StatelessWidget {
  const _EdgeVignette();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.55),
            ],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PARTICLE SCANNING DOTS
// ---------------------------------------------------------------------------

class _ParticleDots extends StatelessWidget {
  final Animation<double> animation;
  const _ParticleDots({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => CustomPaint(
        painter: _ParticlePainter(phase: animation.value),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double phase;
  // Fixed random-ish positions seeded deterministically
  static final _rng = math.Random(42);
  static final _particles = List.generate(28, (_) => (
    x: _rng.nextDouble(),
    y: _rng.nextDouble(),
    r: 1.2 + _rng.nextDouble() * 1.6,
    speed: 0.3 + _rng.nextDouble() * 0.7,
    alpha: 0.12 + _rng.nextDouble() * 0.25,
  ));

  _ParticlePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final yOff = (p.y + phase * p.speed) % 1.0;
      final paint = Paint()
        ..color = const Color(0xFF38D9A9).withValues(alpha: p.alpha);
      canvas.drawCircle(Offset(p.x * size.width, yOff * size.height), p.r, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.phase != phase;
}

// ---------------------------------------------------------------------------
// LOGO BLOCK (top center)
// ---------------------------------------------------------------------------

class _LogoBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo image
        Image.asset(
          kLogoPath,
          width: 64,
          height: 64,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF2ECC71).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Color(0xFF2ECC71),
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 14),
        // App name
        const Text(
          appName,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: Color(0xFFEAF2FF),
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 6),
        // Tagline
        const Text(
          appTagline,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2ECC71),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        // Sub-tagline with bullets
        const Text(
          'Order  |  Track  |  Control  |  Verify',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF8899BB),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ROBOT + RADAR RINGS SECTION
// ---------------------------------------------------------------------------

class _RobotRadarSection extends StatelessWidget {
  final AnimationController radarAnim;
  final AnimationController finalPulse;

  const _RobotRadarSection({
    required this.radarAnim,
    required this.finalPulse,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 520,
        height: 520,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // -- Radar rings (3 staggered) ------------------------------
            _RadarRing(progress: radarAnim.value, maxR: 250, delay: 0.00),
            _RadarRing(progress: radarAnim.value, maxR: 210, delay: 0.33),
            _RadarRing(progress: radarAnim.value, maxR: 170, delay: 0.66),

            // -- Final pulse ring (on system ready) ---------------------
            AnimatedBuilder(
              animation: finalPulse,
              builder: (_, __) => Opacity(
                opacity: (1.0 - finalPulse.value).clamp(0.0, 1.0),
                child: Container(
                  width: 300 + finalPulse.value * 200,
                  height: 300 + finalPulse.value * 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2ECC71)
                          .withValues(alpha: 0.6 * (1 - finalPulse.value)),
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),

            // -- Inner glow halo -----------------------------------------
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2ECC71).withValues(alpha: 0.12),
                    const Color(0xFF38D9A9).withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),

            // -- Rotating scan arc ---------------------------------------
            AnimatedBuilder(
              animation: radarAnim,
              builder: (_, __) => CustomPaint(
                size: const Size(360, 360),
                painter: _ScanArcPainter(progress: radarAnim.value),
              ),
            ),

            // -- Robot image ---------------------------------------------
            Image.asset(
              kRobotImagePath,
              width: 380,
              height: 380,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const _SplashRobotPlaceholder(),
            ),

            // -- Ground shadow -------------------------------------------
            Positioned(
              bottom: 16,
              child: Container(
                width: 260,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2ECC71).withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Radar ring: expands from center outward, fades as it grows.
/// `delay` offsets the progress so rings are staggered.
class _RadarRing extends StatelessWidget {
  final double progress;
  final double maxR;
  final double delay;

  const _RadarRing({
    required this.progress,
    required this.maxR,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final p = ((progress + delay) % 1.0);
    final r = maxR * p;
    final opacity = (1.0 - p).clamp(0.0, 1.0);
    return Container(
      width: r * 2,
      height: r * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF2ECC71).withValues(alpha: opacity * 0.50),
          width: 1.8,
        ),
      ),
    );
  }
}

class _ScanArcPainter extends CustomPainter {
  final double progress;
  _ScanArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const sweep = math.pi * 0.45;
    final start = progress * math.pi * 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + sweep,
        colors: [
          const Color(0xFF2ECC71).withValues(alpha: 0.0),
          const Color(0xFF38D9A9).withValues(alpha: 0.70),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ScanArcPainter old) => old.progress != progress;
}

class _SplashRobotPlaceholder extends StatelessWidget {
  const _SplashRobotPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF2ECC71).withValues(alpha: 0.14),
            Colors.transparent,
          ],
        ),
      ),
      child: const Icon(
        Icons.smart_toy_rounded,
        size: 140,
        color: Color(0xFF38D9A9),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BOOT PROGRESS SECTION
// ---------------------------------------------------------------------------

class _BootProgress extends StatelessWidget {
  final double progress;
  final int stepIndex;
  final bool systemReady;

  const _BootProgress({
    required this.progress,
    required this.stepIndex,
    required this.systemReady,
  });

  @override
  Widget build(BuildContext context) {
    final currentMsg = stepIndex < _bootSteps.length
        ? _bootSteps[stepIndex].msg
        : _bootSteps.last.msg;

    final pct = (progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80),
      child: Column(
        children: [
          // Status message
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: Text(
              currentMsg,
              key: ValueKey(stepIndex),
              style: TextStyle(
                fontSize: 13,
                color: systemReady
                    ? const Color(0xFF2ECC71)
                    : const Color(0xFF8899BB),
                fontWeight: systemReady ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Progress bar
          Stack(
            children: [
              // Track
              Container(
                height: 7,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2535),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
              ),
              // Fill
              AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                height: 7,
                width: (MediaQuery.of(context).size.width - 160) * progress,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2ECC71), Color(0xFF38D9A9)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2ECC71).withValues(alpha: 0.55),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Block characters
              Text(
                _buildBlocks(progress),
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFF2ECC71).withValues(alpha: 0.70),
                  fontFamily: 'monospace',
                  letterSpacing: 1,
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: systemReady
                      ? const Color(0xFF2ECC71)
                      : const Color(0xFF8899BB),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the ------------------ block string
  String _buildBlocks(double progress) {
    const total = 22;
    final n = (progress * total).round().clamp(0, total);
    // ignore: prefer_interpolation_to_compose_strings
    return '█' * n + '░' * (total - n);
  }
}

