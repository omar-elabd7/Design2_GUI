import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/glass_panel.dart';
import '../../../../../shared/models/enums.dart';

/// Vertical 7-step mission timeline with glow on active step.
class MissionTimeline extends StatelessWidget {
  const MissionTimeline({
    super.key,
    required this.currentState,
    required this.faultType,
    this.isDark = true,
  });

  final MissionState currentState;
  final FaultType faultType;
  final bool isDark;

  static const _steps = <_TimelineStepData>[
    _TimelineStepData(
      label: 'Order Received',
      icon: Icons.receipt_long_rounded,
      states: {MissionState.missionReceived},
    ),
    _TimelineStepData(
      label: 'Robot Assigned',
      icon: Icons.smart_toy_outlined,
      states: {MissionState.preparingOrder},
    ),
    _TimelineStepData(
      label: 'Navigating to Items',
      icon: Icons.navigation_rounded,
      states: {MissionState.navigatingToUser},
    ),
    _TimelineStepData(
      label: 'Collecting Items',
      icon: Icons.inventory_2_outlined,
      states: {MissionState.arrived},
    ),
    _TimelineStepData(
      label: 'Returning to Drop-off',
      icon: Icons.local_shipping_rounded,
      states: {MissionState.returningToBase},
    ),
    _TimelineStepData(
      label: 'RFID Verification',
      icon: Icons.nfc_rounded,
      states: {
        MissionState.awaitingRfid,
        MissionState.rfidVerified,
        MissionState.rfidFailed,
      },
    ),
    _TimelineStepData(
      label: 'Delivery Complete',
      icon: Icons.check_circle_outline_rounded,
      states: {MissionState.storageOpened, MissionState.deliveryComplete},
    ),
  ];

  int get _currentIndex {
    for (int i = 0; i < _steps.length; i++) {
      if (_steps[i].states.contains(currentState)) return i;
    }
    // fault states ? freeze at navigating
    if (currentState == MissionState.obstacleBlocked ||
        currentState == MissionState.lowBattery ||
        currentState == MissionState.failed) {
      return 2;
    }
    return -1; // idle
  }

  @override
  Widget build(BuildContext context) {
    final activeIdx = _currentIndex;

    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      borderRadius: 16,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.timeline_rounded,
                size: 18,
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: 8),
              Text(
                'MISSION TIMELINE',
                style: AppTextStyles.labelLarge.copyWith(
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_steps.length, (i) {
            final step = _steps[i];
            final isDone = activeIdx > i;
            final isCurrent = activeIdx == i;
            final isLast = i == _steps.length - 1;

            final bool isFault =
                isCurrent &&
                faultType != FaultType.none &&
                (currentState == MissionState.obstacleBlocked ||
                    currentState == MissionState.lowBattery ||
                    currentState == MissionState.failed ||
                    currentState == MissionState.rfidFailed);

            final Color nodeColor = isFault
                ? AppColors.danger
                : isDone
                ? AppColors.success
                : isCurrent
                ? AppColors.primaryLight
                : isDark
                ? AppColors.surface
                : AppColors.lightSurface;

            return _TimelineNode(
              step: step,
              isDone: isDone,
              isCurrent: isCurrent,
              isFault: isFault,
              isLast: isLast,
              nodeColor: nodeColor,
              isDark: isDark,
            );
          }),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
class _TimelineStepData {
  const _TimelineStepData({
    required this.label,
    required this.icon,
    required this.states,
  });
  final String label;
  final IconData icon;
  final Set<MissionState> states;
}

// -----------------------------------------------------------------------------
class _TimelineNode extends StatefulWidget {
  const _TimelineNode({
    required this.step,
    required this.isDone,
    required this.isCurrent,
    required this.isFault,
    required this.isLast,
    required this.nodeColor,
    required this.isDark,
  });

  final _TimelineStepData step;
  final bool isDone;
  final bool isCurrent;
  final bool isFault;
  final bool isLast;
  final Color nodeColor;
  final bool isDark;

  @override
  State<_TimelineNode> createState() => _TimelineNodeState();
}

class _TimelineNodeState extends State<_TimelineNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isCurrent) _glowCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _TimelineNode old) {
    super.didUpdateWidget(old);
    if (widget.isCurrent && !_glowCtrl.isAnimating) {
      _glowCtrl.repeat(reverse: true);
    } else if (!widget.isCurrent && _glowCtrl.isAnimating) {
      _glowCtrl.stop();
      _glowCtrl.value = 0;
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- vertical track --
          SizedBox(
            width: 36,
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _glowCtrl,
                  builder: (_, __) {
                    final glowOpacity = widget.isCurrent
                        ? 0.2 + _glowCtrl.value * 0.5
                        : 0.0;
                    return Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isDone || widget.isCurrent
                            ? widget.nodeColor.withValues(alpha: 0.15)
                            : widget.isDark
                            ? AppColors.surface
                            : AppColors.lightSurface,
                        border: Border.all(
                          color: widget.nodeColor,
                          width: widget.isCurrent ? 2.5 : 1.5,
                        ),
                        boxShadow: widget.isCurrent
                            ? [
                                BoxShadow(
                                  color: widget.nodeColor.withValues(
                                    alpha: glowOpacity,
                                  ),
                                  blurRadius: 14,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        widget.isDone ? Icons.check_rounded : widget.step.icon,
                        size: 16,
                        color: widget.isDone || widget.isCurrent
                            ? widget.nodeColor
                            : widget.isDark
                            ? AppColors.textMuted
                            : AppColors.lightTextMuted,
                      ),
                    );
                  },
                ),
                if (!widget.isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: widget.isDone
                          ? AppColors.success.withValues(alpha: 0.5)
                          : widget.isDark
                          ? AppColors.cardBorder
                          : AppColors.lightCardBorder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // -- label --
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 6, bottom: widget.isLast ? 0 : 18),
              child: Text(
                widget.step.label,
                style: widget.isCurrent
                    ? AppTextStyles.titleMedium.copyWith(
                        color: widget.isFault
                            ? AppColors.danger
                            : AppColors.primaryLight,
                        fontWeight: FontWeight.w700,
                      )
                    : widget.isDone
                    ? AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.success,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: AppColors.success.withValues(
                          alpha: 0.4,
                        ),
                      )
                    : AppTextStyles.bodyMedium.copyWith(
                        color: widget.isDark
                            ? AppColors.textMuted
                            : AppColors.lightTextMuted,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
