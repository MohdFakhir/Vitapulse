import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class OxygenSpo2Section extends StatefulWidget {
  final double? spo2Percentage;

  const OxygenSpo2Section({
    super.key,
    this.spo2Percentage,
  });

  @override
  State<OxygenSpo2Section> createState() => _OxygenSpo2SectionState();
}

class _OxygenSpo2SectionState extends State<OxygenSpo2Section>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasData = widget.spo2Percentage != null && widget.spo2Percentage! > 0;
    final spo2Value = widget.spo2Percentage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: ClinicalColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ClinicalColors.border),
        boxShadow: ClinicalColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ClinicalColors.oxygenLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.air,
                      color: ClinicalColors.oxygen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BLOOD OXYGEN (SpO₂)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: ClinicalColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Arterial Oxygen Saturation',
                        style: TextStyle(
                          fontSize: 11,
                          color: ClinicalColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: hasData
                      ? ClinicalColors.healthyLight
                      : ClinicalColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasData
                        ? ClinicalColors.healthy.withValues(alpha: 0.3)
                        : ClinicalColors.border,
                  ),
                ),
                child: Text(
                  hasData ? 'ACTIVE' : 'PENDING SYNC',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: hasData
                        ? ClinicalColors.healthy
                        : ClinicalColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Primary readout
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                hasData ? '${spo2Value!.toStringAsFixed(0)}%' : '-- %',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  height: 1.0,
                  color: ClinicalColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SpO₂ Normal Range',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ClinicalColors.textSecondary,
                    ),
                  ),
                  Text(
                    '95% – 100%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: hasData
                          ? ClinicalColors.healthy
                          : ClinicalColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Oxygen Waveform Visualizer
          SizedBox(
            height: 60,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                color: ClinicalColors.surfaceMuted,
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _OxygenWavePainter(
                        progress: _waveController.value,
                        isLive: hasData,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Notice banner explaining state honestly
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: hasData
                  ? ClinicalColors.oxygenLight
                  : ClinicalColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ClinicalColors.borderSubtle),
            ),
            child: Row(
              children: [
                Icon(
                  hasData ? Icons.check_circle_outline : Icons.info_outline,
                  size: 16,
                  color: hasData
                      ? ClinicalColors.oxygen
                      : ClinicalColors.textTertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasData
                        ? 'SpO₂ level optimal • Oxygen delivery steady'
                        : 'SpO₂ data unavailable • Waiting for supported device',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: hasData
                          ? ClinicalColors.oxygen
                          : ClinicalColors.textSecondary,
                    ),
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

class _OxygenWavePainter extends CustomPainter {
  final double progress;
  final bool isLive;

  _OxygenWavePainter({required this.progress, required this.isLive});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final midY = h * 0.5;

    final path = Path();
    final glowPath = Path();

    bool started = false;
    for (double x = 0; x <= w; x += 2.0) {
      final t = (x / w) * 3 * math.pi;
      // Gentle breathing wave
      final offset = (progress * 2 * math.pi);
      final amplitude = isLive ? (h * 0.28) : (h * 0.12);
      final y = midY + math.sin(t - offset) * amplitude * math.cos((x / w) * math.pi);

      if (!started) {
        path.moveTo(x, y);
        glowPath.moveTo(x, y);
        started = true;
      } else {
        path.lineTo(x, y);
        glowPath.lineTo(x, y);
      }
    }

    final waveColor = isLive ? ClinicalColors.oxygen : ClinicalColors.textTertiary;

    final glowPaint = Paint()
      ..color = waveColor.withValues(alpha: isLive ? 0.3 : 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    final linePaint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(glowPath, glowPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _OxygenWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isLive != isLive;
  }
}
