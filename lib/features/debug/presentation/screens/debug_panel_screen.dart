import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/models/mission_update.dart';
import '../../../robot_status/presentation/providers/robot_status_provider.dart';
import '../../../robot_status/presentation/providers/mission_stream_provider.dart';

// ─── palette (matches worker dashboard) ──────────────────────────────────────
const _kGreen = Color(0xFF2ECC8E);
const _kBg = Color(0xFF0A0F1A);
const _kCard = Color(0xFF0F1825);
const _kCardBorder = Color(0xFF1A2A3A);
const _kCardBorderGreen = Color(0xFF1A3A2A);

// =============================================================================
//  DebugPanelScreen
// =============================================================================

class DebugPanelScreen extends ConsumerStatefulWidget {
  const DebugPanelScreen({super.key});

  @override
  ConsumerState<DebugPanelScreen> createState() => _DebugPanelScreenState();
}

class _DebugPanelScreenState extends ConsumerState<DebugPanelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // ── animated grid bg ─────────────────────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, __) =>
                  CustomPaint(painter: _DebugGridPainter(phase: _bgCtrl.value)),
            ),
          ),
          // ── content ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader(),
                const SizedBox(height: 14),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT — raw state only
                      Expanded(flex: 42, child: _RawStateCard()),
                      const SizedBox(width: 12),
                      // RIGHT — live status + event log
                      Expanded(
                        flex: 58,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _LiveStatusCard(),
                            const SizedBox(height: 12),
                            Expanded(child: _EventLogCard()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  Page header
// =============================================================================

class _PageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: const Icon(
            Icons.bug_report_rounded,
            color: AppColors.warning,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DEBUG CONSOLE',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.warning,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Simulate robot events · inspect live state',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.warning,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warning.withValues(alpha: 0.6),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'DEV BUILD · v2.5.0',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
//  Simulators section
// =============================================================================
//  Raw state card
// =============================================================================

class _RawStateCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(robotStatusProvider);

    final rows = [
      _KV(
        'connected',
        s.isConnected ? 'true' : 'false',
        s.isConnected ? _kGreen : AppColors.danger,
      ),
      _KV('mode', s.mode.name, s.mode.color),
      _KV('mission_state', s.missionState.name, AppColors.textSecondary),
      _KV(
        'storage_state',
        s.storageState.name,
        s.storageState == StorageState.open
            ? AppColors.warning
            : AppColors.textSecondary,
      ),
      _KV(
        'battery_pct',
        '${s.batteryPercent}',
        s.batteryPercent < 20 ? AppColors.danger : _kGreen,
      ),
      _KV(
        'fault',
        s.faultType == FaultType.none ? 'none' : s.faultType.name,
        s.faultType != FaultType.none ? AppColors.danger : AppColors.textMuted,
      ),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.data_object_rounded,
            label: 'Raw State',
            accent: Color(0xFF42A5F5),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF060D14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _kCardBorder),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: rows.map((kv) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Text(
                          '${kv.key}:',
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: AppColors.textMuted,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          kv.value,
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                            color: kv.color,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KV {
  const _KV(this.key, this.value, this.color);
  final String key;
  final String value;
  final Color color;
}

// =============================================================================
//  Live status card
// =============================================================================

class _LiveStatusCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(robotStatusProvider);
    final pct = s.batteryPercent;
    final batColor = pct < 20
        ? AppColors.batteryLow
        : pct < 40
        ? AppColors.batteryMedium
        : _kGreen;
    final hasFault = s.faultType != FaultType.none;

    return _Card(
      glowBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.monitor_heart_rounded,
            label: 'Live Status',
            accent: _kGreen,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'MODE',
                  value: s.mode.label,
                  color: s.mode.color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  label: 'MISSION',
                  value: s.missionState.label,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  label: 'STORAGE',
                  value: s.storageState.label,
                  color: s.storageState == StorageState.open
                      ? AppColors.warning
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                pct < 20
                    ? Icons.battery_alert_rounded
                    : Icons.battery_charging_full_rounded,
                color: batColor,
                size: 14,
              ),
              const SizedBox(width: 6),
              const Text(
                'Battery  ',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 7,
                    backgroundColor: _kCardBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(batColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: batColor,
                ),
              ),
            ],
          ),
          if (hasFault) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.danger,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FAULT · ${s.faultType.name.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF08141E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  Event log card
// =============================================================================

class _EventLogCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_EventLogCard> createState() => _EventLogCardState();
}

class _EventLogCardState extends ConsumerState<_EventLogCard> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final updates = ref.watch(missionUpdatesProvider).asData?.value ?? const [];

    ref.listen(missionUpdatesProvider, (_, next) {
      final list = next.asData?.value;
      if (list != null && list.isNotEmpty) {
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
    });

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SectionHeader(
                icon: Icons.terminal_rounded,
                label: 'Mission Log',
                accent: _kGreen,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _kGreen.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${updates.length} events',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _kGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF060D14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _kCardBorder),
              ),
              padding: const EdgeInsets.all(10),
              child: updates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 28,
                            color: AppColors.textMuted.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Waiting for mission events...',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      itemCount: updates.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (_, i) => _LogRow(update: updates[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.update});
  final MissionUpdate update;

  Color _dotColor() {
    if (update.faultType != null && update.faultType != FaultType.none) {
      return AppColors.danger;
    }
    switch (update.state) {
      case MissionState.storageClosed:
      case MissionState.storageOpened:
        return _kGreen;
      case MissionState.headingToFruit:
      case MissionState.headingToCustomer:
      case MissionState.returning:
        return const Color(0xFF42A5F5);
      case MissionState.rfidAwaiting:
      case MissionState.visionChecking:
        return AppColors.warning;
      case MissionState.failed:
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm:ss').format(update.timestamp);
    final color = _dotColor();
    final isFault =
        update.faultType != null && update.faultType != FaultType.none;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 5),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              update.message,
              style: TextStyle(
                fontSize: 11,
                color: isFault ? AppColors.danger : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  Shared card + section header
// =============================================================================

class _Card extends StatelessWidget {
  const _Card({required this.child, this.glowBorder = false});
  final Widget child;
  final bool glowBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: glowBorder ? _kCardBorderGreen : _kCardBorder,
          width: glowBorder ? 1.2 : 1,
        ),
        boxShadow: glowBorder
            ? [
                BoxShadow(
                  color: _kGreen.withValues(alpha: 0.06),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.accent,
  });
  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: accent, size: 16),
        const SizedBox(width: 7),
        Text(label, style: AppTextStyles.headlineSmall),
      ],
    );
  }
}

// =============================================================================
//  Animated grid background (amber-tinted for debug mode)
// =============================================================================

class _DebugGridPainter extends CustomPainter {
  _DebugGridPainter({required this.phase});
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    const step = 52.0;

    final linePaint = Paint()
      ..color = const Color(0xFF1A1A0E).withValues(alpha: 0.6)
      ..strokeWidth = 0.6;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final dotPaint = Paint()..color = AppColors.warning.withValues(alpha: 0.05);
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.4, dotPaint);
      }
    }

    final sweepX = phase * (size.width + 240) - 120;
    final glowH = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.warning.withValues(alpha: 0.03),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(sweepX - 120, 0, 240, size.height));
    canvas.drawRect(Rect.fromLTWH(sweepX - 120, 0, 240, size.height), glowH);

    final rPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.warning.withValues(alpha: 0.04),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width, 0),
              radius: size.height * 0.55,
            ),
          );
    canvas.drawRect(Offset.zero & size, rPaint);
  }

  @override
  bool shouldRepaint(_DebugGridPainter old) => old.phase != phase;
}
