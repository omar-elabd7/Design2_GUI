import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Smart hero banner -- the first visual the customer sees after the greeting.
///
/// Contains a large gradient card with brand messaging, quick stat chips,
/// a mini robot pulse icon and a "Start Order" CTA.
class HeroDeliveryBanner extends StatefulWidget {
  const HeroDeliveryBanner({
    super.key,
    required this.isDark,
    required this.onStartOrder,
    required this.isRobotOnline,
    required this.avgDeliveryMin,
  });

  final bool isDark;
  final VoidCallback onStartOrder;
  final bool isRobotOnline;
  final int avgDeliveryMin;

  @override
  State<HeroDeliveryBanner> createState() => _HeroDeliveryBannerState();
}

class _HeroDeliveryBannerState extends State<HeroDeliveryBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDark
              ? [
                  const Color(0xFF0F2218),
                  const Color(0xFF0D1A28),
                  const Color(0xFF0C1322),
                ]
              : [
                  const Color(0xFFE7F6ED),
                  const Color(0xFFEBF5F1),
                  const Color(0xFFF5F7FA),
                ],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: widget.isDark ? 0.28 : 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: widget.isDark ? 0.12 : 0.06),
            blurRadius: 36,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // -- Left -- text content --------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Autonomous Fruit Delivery',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: widget.isDark
                        ? AppColors.textPrimary
                        : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Order fresh items and let Pluto deliver them to you',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: widget.isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 18),

                // -- Stat chips -------------------------------------------
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _StatChip(
                      icon: Icons.circle,
                      iconColor: widget.isRobotOnline
                          ? AppColors.success
                          : AppColors.textMuted,
                      label: widget.isRobotOnline
                          ? 'Robot Online'
                          : 'Robot Offline',
                      isDark: widget.isDark,
                    ),
                    _StatChip(
                      icon: Icons.schedule_rounded,
                      iconColor: AppColors.info,
                      label: '~${widget.avgDeliveryMin} min delivery',
                      isDark: widget.isDark,
                    ),
                    _StatChip(
                      icon: Icons.verified_user_rounded,
                      iconColor: AppColors.primaryLight,
                      label: 'RFID Secure Pickup',
                      isDark: widget.isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // -- Right -- robot pulse + CTA --------------------------------
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mini robot radar pulse
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, _) {
                  final t = _pulseCtrl.value;
                  return SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer ring
                        Container(
                          width: 72 * (0.7 + 0.3 * t),
                          height: 72 * (0.7 + 0.3 * t),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary
                                  .withValues(alpha: 0.3 * (1 - t)),
                              width: 1.5,
                            ),
                          ),
                        ),
                        // Inner glow
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.25),
                                AppColors.primary.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                        // Robot icon
                        Icon(
                          Icons.smart_toy_rounded,
                          size: 28,
                          color: widget.isRobotOnline
                              ? AppColors.primaryLight
                              : AppColors.textMuted,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // CTA
              _StartOrderButton(
                isDark: widget.isDark,
                onTap: widget.onStartOrder,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Stat chip ---------------------------------------------------------------

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// --- CTA Button --------------------------------------------------------------

class _StartOrderButton extends StatefulWidget {
  const _StartOrderButton({required this.isDark, required this.onTap});
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_StartOrderButton> createState() => _StartOrderButtonState();
}

class _StartOrderButtonState extends State<_StartOrderButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary
                    .withValues(alpha: _hovering ? 0.50 : 0.30),
                blurRadius: _hovering ? 18 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.rocket_launch_rounded,
                  size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Start Order',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

