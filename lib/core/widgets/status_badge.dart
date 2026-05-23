import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.showDot = true,
    this.small = false,
  });

  final String label;
  final Color color;
  final bool showDot;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final textStyle = small ? AppTextStyles.labelSmall : AppTextStyles.labelMedium;
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
    final dotSize = small ? 6.0 : 7.0;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: small ? 4 : 5),
          ],
          Text(
            label,
            style: textStyle.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
