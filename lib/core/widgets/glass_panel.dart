import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable glassmorphism panel used across dashboard cards.
///
/// [borderRadius] defaults to 20.  Set [glowColor] for a colored border
/// highlight; leave null for the standard muted border.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.glowColor,
    this.isDark = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? glowColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? const Color(0xFF131B2E).withValues(alpha: 0.88)
        : Colors.white.withValues(alpha: 0.92);

    final border = glowColor?.withValues(alpha: 0.35) ??
        (isDark ? AppColors.cardBorder : AppColors.lightCardBorder);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border, width: 1.2),
        boxShadow: [
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
