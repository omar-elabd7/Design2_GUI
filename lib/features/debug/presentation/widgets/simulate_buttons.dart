import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/debug_provider.dart';

class SimulateObstacleButton extends ConsumerWidget {
  const SimulateObstacleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(debugProvider);
    return _DebugActionButton(
      label: 'Simulate Obstacle',
      icon: Icons.warning_amber_rounded,
      color: AppColors.warning,
      loading: loading,
      onPressed: () =>
          ref.read(debugProvider.notifier).simulate(DebugEvent.obstacle),
    );
  }
}

class SimulateRfidResultButton extends ConsumerWidget {
  const SimulateRfidResultButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(debugProvider);
    return _DebugActionButton(
      label: 'Simulate RFID Fail',
      icon: Icons.credit_card_off,
      color: AppColors.danger,
      loading: loading,
      onPressed: () =>
          ref.read(debugProvider.notifier).simulate(DebugEvent.rfidFail),
    );
  }
}

class SimulateBatteryDropButton extends ConsumerWidget {
  const SimulateBatteryDropButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(debugProvider);
    return _DebugActionButton(
      label: 'Simulate Low Battery',
      icon: Icons.battery_alert,
      color: AppColors.batteryLow,
      loading: loading,
      onPressed: () =>
          ref.read(debugProvider.notifier).simulate(DebugEvent.lowBattery),
    );
  }
}

class SimulateOutOfStockButton extends ConsumerWidget {
  const SimulateOutOfStockButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(debugProvider);
    return _DebugActionButton(
      label: 'Simulate Out of Stock',
      icon: Icons.inventory_2_outlined,
      color: AppColors.info,
      loading: loading,
      onPressed: () =>
          ref.read(debugProvider.notifier).simulate(DebugEvent.outOfStock),
    );
  }
}

class _DebugActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool loading;
  final VoidCallback onPressed;

  const _DebugActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.12),
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: loading ? null : onPressed,
      icon: loading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Icon(icon, size: 18),
      label: Text(label, style: AppTextStyles.labelMedium),
    );
  }
}
