import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/models/robot_status.dart';
import '../../../../features/robot_status/presentation/providers/robot_status_provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.lightBackground,
      body: Stack(
        children: [
          // -- Subtle grid background ----------------------------------------
          Positioned.fill(child: _GridBackground(isDark: isDark)),

          // -- Top-right ambient glow ----------------------------------------
          Positioned(
            top: -120,
            right: -80,
            child: _AmbientGlow(
              radius: 320,
              color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.07),
            ),
          ),

          // -- Bottom-left ambient glow --------------------------------------
          Positioned(
            bottom: -100,
            left: -60,
            child: _AmbientGlow(
              radius: 260,
              color: AppColors.primaryLight.withValues(
                alpha: isDark ? 0.08 : 0.05,
              ),
            ),
          ),

          // -- Main layout ---------------------------------------------------
          Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(flex: 55, child: _LeftPanel(isDark: isDark)),
                    Expanded(flex: 45, child: _RightPanel(isDark: isDark)),
                  ],
                ),
              ),
              _StatusBar(isDark: isDark),
            ],
          ),

          // -- Theme toggle --------------------------------------------------
          Positioned(
            top: 16,
            right: 24,
            child: _ThemeToggle(
              isDark: isDark,
              onToggle: () =>
                  ref.read(themeModeProvider.notifier).state = !isDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LEFT PANEL
// ---------------------------------------------------------------------------

class _LeftPanel extends StatelessWidget {
  final bool isDark;
  const _LeftPanel({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0A1628),
                  AppColors.backgroundDark,
                  const Color(0xFF0D1F0F),
                ]
              : [
                  const Color(0xFFE8F5EE),
                  AppColors.lightBackground,
                  const Color(0xFFEDF5F0),
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 28, right: 28),
            child: Row(children: [_LogoWidget(isDark: isDark)]),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 40, left: 32, right: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  appTagline,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  appSubTagline,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Expanded(child: _RobotSection()),
        ],
      ),
    );
  }
}

// --- Logo ---------------------------------------------------------------------

class _LogoWidget extends StatelessWidget {
  final bool isDark;
  const _LogoWidget({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          kLogoPath,
          width: 48,
          height: 48,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.smart_toy_rounded, size: 44, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          appName,
          style: AppTextStyles.headlineLarge.copyWith(
            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ROBOT -- floating + three pulsating rings + scan arc
// ---------------------------------------------------------------------------

class _RobotSection extends StatefulWidget {
  const _RobotSection();

  @override
  State<_RobotSection> createState() => _RobotSectionState();
}

class _RobotSectionState extends State<_RobotSection>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _ring1Ctrl;
  late final AnimationController _ring2Ctrl;
  late final AnimationController _ring3Ctrl;
  late final AnimationController _scanCtrl;

  late final Animation<double> _floatAnim;
  late final Animation<double> _ring1Anim;
  late final Animation<double> _ring2Anim;
  late final Animation<double> _ring3Anim;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);

    _ring1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _ring2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _ring3Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    // Stagger: ring2 starts at 1/3, ring3 at 2/3
    _ring2Ctrl.forward(from: 1 / 3);
    _ring2Ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) _ring2Ctrl.repeat();
    });
    _ring3Ctrl.forward(from: 2 / 3);
    _ring3Ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) _ring3Ctrl.repeat();
    });

    _floatAnim = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _ring1Anim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ring1Ctrl, curve: Curves.easeOut));

    _ring2Anim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ring2Ctrl, curve: Curves.easeOut));

    _ring3Anim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ring3Ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _ring1Ctrl.dispose();
    _ring2Ctrl.dispose();
    _ring3Ctrl.dispose();
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _floatAnim,
          _ring1Anim,
          _ring2Anim,
          _ring3Anim,
          _scanCtrl,
        ]),
        builder: (context, _) {
          return Transform.translate(
            offset: Offset(0, _floatAnim.value),
            child: SizedBox(
              width: 560,
              height: 560,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Three expanding pulsating rings
                  _ExpandingRing(progress: _ring1Anim.value, maxRadius: 270),
                  _ExpandingRing(progress: _ring2Anim.value, maxRadius: 230),
                  _ExpandingRing(progress: _ring3Anim.value, maxRadius: 190),

                  // Inner glow blob
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),

                  // Rotating scan arc
                  CustomPaint(
                    size: const Size(380, 380),
                    painter: _ScanArcPainter(progress: _scanCtrl.value),
                  ),

                  // Robot image (or placeholder)
                  Image.asset(
                    kRobotImagePath,
                    width: 490,
                    height: 490,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const _RobotPlaceholder(),
                  ),

                  // Ground shadow
                  Positioned(
                    bottom: 12,
                    child: Container(
                      width: 300,
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.22),
                            AppColors.primary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Ring that expands outward and fades -- creates the "pulsating" glow effect.
class _ExpandingRing extends StatelessWidget {
  final double progress; // 0 ? 1
  final double maxRadius;

  const _ExpandingRing({required this.progress, required this.maxRadius});

  @override
  Widget build(BuildContext context) {
    final r = maxRadius * progress;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    return Container(
      width: r * 2,
      height: r * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: opacity * 0.48),
          width: 2.0,
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
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: start,
        endAngle: start + sweep,
        colors: [
          AppColors.primary.withValues(alpha: 0.0),
          AppColors.primaryLight.withValues(alpha: 0.65),
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
  bool shouldRepaint(_ScanArcPainter o) => o.progress != progress;
}

class _RobotPlaceholder extends StatelessWidget {
  const _RobotPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 560,
      height: 560,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow circle
          Container(
            width: 420,
            height: 420,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.22),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
                stops: const [0.45, 1.0],
              ),
            ),
          ),
          // Robot body silhouette
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Head
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.55),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  size: 110,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 12),
              // Body
              Container(
                width: 130,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.40),
                    width: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Wheels / base
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [_Wheel(), const SizedBox(width: 40), _Wheel()],
              ),
            ],
          ),
          // Drop-in label
          Positioned(
            bottom: 12,
            child: Text(
              'Drop robot.png in assets/images/',
              style: TextStyle(
                fontSize: 9,
                color: AppColors.primaryLight.withValues(alpha: 0.45),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.20),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// RIGHT PANEL -- glassmorphism card
// ---------------------------------------------------------------------------

class _RightPanel extends StatelessWidget {
  final bool isDark;
  const _RightPanel({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, minWidth: 300),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark
                    ? const Color(0xFF151E2E).withValues(alpha: 0.93)
                    : Colors.white.withValues(alpha: 0.93),
                border: Border.all(
                  color: AppColors.primary.withValues(
                    alpha: isDark ? 0.25 : 0.18,
                  ),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: isDark ? 0.15 : 0.10,
                    ),
                    blurRadius: 48,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                    blurRadius: 32,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back',
                    style: AppTextStyles.displayMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Login to continue',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _LoginFormV1(isDark: isDark),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      appSuiteLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LOGIN FORM V1
// ---------------------------------------------------------------------------

class _LoginFormV1 extends ConsumerStatefulWidget {
  final bool isDark;
  const _LoginFormV1({required this.isDark});

  @override
  ConsumerState<_LoginFormV1> createState() => _LoginFormV1State();
}

class _LoginFormV1State extends ConsumerState<_LoginFormV1> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  UserRole _selectedRole = UserRole.customer;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(authStateProvider.notifier)
        .login(_usernameCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    final user = ref.read(authStateProvider).user;
    if (user != null) {
      final dest = user.role == UserRole.customer
          ? RouteNames.customerHome
          : RouteNames.workerDashboard;
      context.go(
        '${RouteNames.transitionSplash}'
        '?next=${Uri.encodeComponent(dest)}'
        '&subtitle=${Uri.encodeComponent('Welcome to Pluto...')}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final d = widget.isDark;

    final inputFill = d ? const Color(0xFF1A2535) : AppColors.lightInputFill;
    final inputBorder = d ? AppColors.cardBorder : AppColors.lightInputBorder;
    final textColor = d ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final hintColor = d ? AppColors.textMuted : AppColors.lightTextMuted;
    final iconColor = d
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InputField(
            controller: _usernameCtrl,
            hint: 'Username',
            prefixIcon: Icons.person_outline_rounded,
            fillColor: inputFill,
            borderColor: inputBorder,
            textColor: textColor,
            hintColor: hintColor,
            iconColor: iconColor,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter username' : null,
          ),
          const SizedBox(height: 14),
          _InputField(
            controller: _passwordCtrl,
            hint: 'Password',
            prefixIcon: Icons.lock_outline_rounded,
            fillColor: inputFill,
            borderColor: inputBorder,
            textColor: textColor,
            hintColor: hintColor,
            iconColor: iconColor,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: iconColor,
                size: 18,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Enter password' : null,
          ),
          const SizedBox(height: 20),
          _RoleToggle(
            selected: _selectedRole,
            isDark: d,
            onChanged: (r) => setState(() => _selectedRole = r),
          ),
          const SizedBox(height: 24),
          if (authState.error != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.30),
                ),
              ),
              child: Text(
                authState.error!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.danger,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
          _SignInButton(isLoading: authState.isLoading, onPressed: _submit),
        ],
      ),
    );
  }
}

// --- Input Field -------------------------------------------------------------

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final Color fillColor;
  final Color borderColor;
  final Color textColor;
  final Color hintColor;
  final Color iconColor;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    required this.fillColor,
    required this.borderColor,
    required this.textColor,
    required this.hintColor,
    required this.iconColor,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: AppTextStyles.bodyMedium.copyWith(color: textColor),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: hintColor),
        prefixIcon: Icon(prefixIcon, color: iconColor, size: 18),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
      ),
    );
  }
}

// --- Role Toggle -------------------------------------------------------------

class _RoleToggle extends StatelessWidget {
  final UserRole selected;
  final bool isDark;
  final void Function(UserRole) onChanged;

  const _RoleToggle({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2535) : AppColors.lightInputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.cardBorder : AppColors.lightInputBorder,
        ),
      ),
      child: Row(
        children: [
          _RoleOption(
            label: 'Customer',
            isSelected: selected == UserRole.customer,
            isDark: isDark,
            onTap: () => onChanged(UserRole.customer),
          ),
          _RoleOption(
            label: 'Store Worker',
            isSelected: selected == UserRole.worker,
            isDark: isDark,
            onTap: () => onChanged(UserRole.worker),
          ),
        ],
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _RoleOption({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? AppColors.textSecondary
                          : AppColors.lightTextSecondary),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Sign In Button -----------------------------------------------------------

class _SignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SignInButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.primaryLight,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.40),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// STATUS BAR  — live data from WebSocket via robotStatusProvider
// ---------------------------------------------------------------------------

class _StatusBar extends ConsumerWidget {
  final bool isDark;
  const _StatusBar({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(robotStatusProvider);
    final bg = isDark
        ? Colors.black.withValues(alpha: 0.45)
        : Colors.white.withValues(alpha: 0.70);

    // ── Derive display values from live status ──────────────────────────────
    final isConnected = status.isConnected;

    // Navigation / mode chip
    final (navIcon, navColor, navLabel) = _navChip(status);

    // Battery chip
    final battery = status.batteryPercent;
    final batColor = battery > 50
        ? AppColors.success
        : battery > 20
        ? AppColors.warning
        : AppColors.danger;
    final batIcon = battery > 80
        ? Icons.battery_full_rounded
        : battery > 50
        ? Icons.battery_5_bar_rounded
        : battery > 20
        ? Icons.battery_3_bar_rounded
        : Icons.battery_alert_rounded;
    final batLabel = isConnected ? 'Battery $battery%' : 'Battery --';

    // Mission / RFID chip
    final (rfidIcon, rfidColor, rfidLabel) = _rfidChip(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _StatusChip(
            icon: navIcon,
            iconColor: navColor,
            label: navLabel,
            isDark: isDark,
          ),
          const SizedBox(width: 28),
          _StatusChip(
            icon: batIcon,
            iconColor: batColor,
            label: batLabel,
            isDark: isDark,
          ),
          const SizedBox(width: 28),
          _StatusChip(
            icon: rfidIcon,
            iconColor: rfidColor,
            label: rfidLabel,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// Returns (icon, color, label) for the navigation/mode chip.
  (IconData, Color, String) _navChip(RobotStatus s) {
    if (!s.isConnected) {
      return (Icons.circle_outlined, AppColors.textMuted, 'Robot Offline');
    }
    return switch (s.missionState) {
      MissionState.headingToFruit ||
      MissionState.headingToCustomer ||
      MissionState.returning => (
        Icons.navigation_rounded,
        AppColors.success,
        'Navigating',
      ),
      MissionState.rfidAwaiting => (
        Icons.nfc_rounded,
        AppColors.warning,
        'Awaiting RFID',
      ),
      MissionState.storageOpened => (
        Icons.verified_rounded,
        AppColors.success,
        'Storage Open',
      ),
      MissionState.storageClosed => (
        Icons.check_circle_rounded,
        AppColors.success,
        'Delivery Done',
      ),
      MissionState.failed => (
        Icons.error_rounded,
        AppColors.danger,
        'Mission Failed',
      ),
      MissionState.idle => (
        Icons.circle,
        AppColors.success,
        'Navigation Active',
      ),
      _ => (Icons.circle, AppColors.primaryLight, s.missionState.name),
    };
  }

  /// Returns (icon, color, label) for the RFID/mission chip.
  (IconData, Color, String) _rfidChip(RobotStatus s) {
    if (!s.isConnected) {
      return (
        Icons.credit_card_off_outlined,
        AppColors.textMuted,
        'RFID Offline',
      );
    }
    if (s.faultType != FaultType.none) {
      return (
        Icons.warning_amber_rounded,
        AppColors.danger,
        'Fault: ${s.faultType.name}',
      );
    }
    if (s.missionState == MissionState.rfidAwaiting) {
      return (Icons.nfc_rounded, AppColors.warning, 'Tap RFID Card');
    }
    if (s.activeOrderId != null) {
      return (
        Icons.credit_card_rounded,
        AppColors.primaryLight,
        'Order: ${s.activeOrderId}',
      );
    }
    return (Icons.credit_card_outlined, AppColors.success, 'RFID Ready');
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isDark;

  const _StatusChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: iconColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isDark
                ? AppColors.textSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// THEME TOGGLE
// ---------------------------------------------------------------------------

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const _ThemeToggle({required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A2535).withValues(alpha: 0.88)
              : Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 16,
              color: isDark ? AppColors.secondary : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              isDark ? 'Light' : 'Dark',
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GRID BACKGROUND
// ---------------------------------------------------------------------------

class _GridBackground extends StatelessWidget {
  final bool isDark;
  const _GridBackground({required this.isDark});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GridPainter(isDark: isDark));
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: isDark ? 0.04 : 0.035)
      ..strokeWidth = 0.7;

    final dotPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.09);

    const sp = 52.0;
    for (double x = 0; x < size.width; x += sp) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += sp) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    // Accent dots at intersections
    for (double x = 0; x < size.width; x += sp) {
      for (double y = 0; y < size.height; y += sp) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter o) => o.isDark != isDark;
}

// ---------------------------------------------------------------------------
// AMBIENT GLOW BLOB
// ---------------------------------------------------------------------------

class _AmbientGlow extends StatelessWidget {
  final double radius;
  final Color color;

  const _AmbientGlow({required this.radius, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
