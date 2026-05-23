import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/enums.dart';
import '../providers/teleop_provider.dart';

class TeleopPanel extends ConsumerStatefulWidget {
  const TeleopPanel({super.key});

  @override
  ConsumerState<TeleopPanel> createState() => _TeleopPanelState();
}

class _TeleopPanelState extends ConsumerState<TeleopPanel> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyDown(LogicalKeyboardKey key) {
    final notifier = ref.read(teleopProvider.notifier);
    if (key == LogicalKeyboardKey.keyW || key == LogicalKeyboardKey.arrowUp) {
      notifier.startCommand(TeleopDirection.forward);
    } else if (key == LogicalKeyboardKey.keyS ||
        key == LogicalKeyboardKey.arrowDown) {
      notifier.startCommand(TeleopDirection.backward);
    } else if (key == LogicalKeyboardKey.keyA ||
        key == LogicalKeyboardKey.arrowLeft) {
      notifier.startCommand(TeleopDirection.left);
    } else if (key == LogicalKeyboardKey.keyD ||
        key == LogicalKeyboardKey.arrowRight) {
      notifier.startCommand(TeleopDirection.right);
    }
  }

  void _handleKeyUp(LogicalKeyboardKey key) {
    final controlled = {
      LogicalKeyboardKey.keyW,
      LogicalKeyboardKey.keyS,
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.keyD,
      LogicalKeyboardKey.arrowUp,
      LogicalKeyboardKey.arrowDown,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowRight,
    };
    if (controlled.contains(key)) {
      ref.read(teleopProvider.notifier).stopCommand();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeDirection = ref.watch(teleopProvider);

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) _handleKeyDown(event.logicalKey);
          if (event is KeyUpEvent) _handleKeyUp(event.logicalKey);
        },
        child: Container(
          padding: const EdgeInsets.all(kDefaultPadding),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(kCardBorderRadius),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.gamepad_outlined,
                      color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  const Text('Manual Control', style: AppTextStyles.headlineSmall),
                  const Spacer(),
                  Text(
                    'Click panel to focus  ?  W A S D',
                    style: AppTextStyles.labelSmall,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    _DpadButton(
                      icon: Icons.arrow_upward,
                      label: 'W',
                      isActive: activeDirection == TeleopDirection.forward,
                      onPressed: () => ref
                          .read(teleopProvider.notifier)
                          .startCommand(TeleopDirection.forward),
                      onReleased: () =>
                          ref.read(teleopProvider.notifier).stopCommand(),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DpadButton(
                          icon: Icons.arrow_back,
                          label: 'A',
                          isActive: activeDirection == TeleopDirection.left,
                          onPressed: () => ref
                              .read(teleopProvider.notifier)
                              .startCommand(TeleopDirection.left),
                          onReleased: () =>
                              ref.read(teleopProvider.notifier).stopCommand(),
                        ),
                        const SizedBox(width: 6),
                        _StopButton(
                          onPressed: () =>
                              ref.read(teleopProvider.notifier).stopCommand(),
                        ),
                        const SizedBox(width: 6),
                        _DpadButton(
                          icon: Icons.arrow_forward,
                          label: 'D',
                          isActive: activeDirection == TeleopDirection.right,
                          onPressed: () => ref
                              .read(teleopProvider.notifier)
                              .startCommand(TeleopDirection.right),
                          onReleased: () =>
                              ref.read(teleopProvider.notifier).stopCommand(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _DpadButton(
                      icon: Icons.arrow_downward,
                      label: 'S',
                      isActive: activeDirection == TeleopDirection.backward,
                      onPressed: () => ref
                          .read(teleopProvider.notifier)
                          .startCommand(TeleopDirection.backward),
                      onReleased: () =>
                          ref.read(teleopProvider.notifier).stopCommand(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DpadButton extends StatelessWidget {
  const _DpadButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
    required this.onReleased,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;
  final VoidCallback onReleased;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      onTapUp: (_) => onReleased(),
      onTapCancel: onReleased,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color:
              isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.cardBorder,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isActive
                    ? AppColors.textOnPrimary
                    : AppColors.textSecondary,
                size: 22),
            Text(label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isActive
                      ? AppColors.textOnPrimary
                      : AppColors.textMuted,
                )),
          ],
        ),
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  const _StopButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.5)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stop, color: AppColors.danger, size: 22),
            Text('STOP',
                style: TextStyle(fontSize: 9, color: AppColors.danger)),
          ],
        ),
      ),
    );
  }
}
