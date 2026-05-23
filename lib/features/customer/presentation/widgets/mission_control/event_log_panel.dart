import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/glass_panel.dart';
import '../../../../../shared/models/mission_update.dart';
import '../../../../../shared/models/enums.dart';

/// Scrollable real-time event log panel showing mission updates.
class EventLogPanel extends StatefulWidget {
  const EventLogPanel({super.key, required this.updates, this.isDark = true});

  final List<MissionUpdate> updates;
  final bool isDark;

  @override
  State<EventLogPanel> createState() => _EventLogPanelState();
}

class _EventLogPanelState extends State<EventLogPanel> {
  final ScrollController _scroll = ScrollController();

  @override
  void didUpdateWidget(covariant EventLogPanel old) {
    super.didUpdateWidget(old);
    if (widget.updates.length != old.updates.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: 14,
      isDark: widget.isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.article_outlined,
                  size: 16, color: AppColors.primaryLight),
              const SizedBox(width: 8),
              Text('EVENT LOG',
                  style: AppTextStyles.labelLarge
                      .copyWith(letterSpacing: 1.2, fontSize: 11)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${widget.updates.length}',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 10,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: widget.updates.isEmpty
                ? Center(
                    child: Text('Waiting for mission events...',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: widget.isDark ? AppColors.textMuted : AppColors.lightTextMuted)),
                  )
                : ListView.builder(
                    controller: _scroll,
                    itemCount: widget.updates.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (_, i) {
                      final u = widget.updates[i];
                      return _LogEntry(update: u, isDark: widget.isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
class _LogEntry extends StatelessWidget {
  const _LogEntry({required this.update, this.isDark = true});
  final MissionUpdate update;
  final bool isDark;

  Color _dotColor() {
    if (update.faultType != null && update.faultType != FaultType.none) {
      return AppColors.danger;
    }
    switch (update.state) {
      case MissionState.deliveryComplete:
      case MissionState.rfidVerified:
      case MissionState.storageOpened:
        return AppColors.success;
      case MissionState.navigatingToUser:
      case MissionState.returningToBase:
        return const Color(0xFF42A5F5);
      case MissionState.awaitingRfid:
      case MissionState.arrived:
        return AppColors.warning;
      case MissionState.rfidFailed:
      case MissionState.obstacleBlocked:
      case MissionState.lowBattery:
      case MissionState.failed:
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm:ss').format(update.timestamp);
    final color = _dotColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // timestamp
            SizedBox(
            width: 58,
            child: Text(time,
                style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: isDark ? AppColors.textMuted : AppColors.lightTextMuted)),
          ),
          // dot
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // message
          Expanded(
            child: Text(
              update.message,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                color: update.faultType != null &&
                        update.faultType != FaultType.none
                    ? AppColors.danger
                    : isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
