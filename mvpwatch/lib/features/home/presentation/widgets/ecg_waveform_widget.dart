import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class EcgWaveformWidget extends StatefulWidget {
  final int bpm;
  final double height;
  final Color? color;
  final bool isLive;

  const EcgWaveformWidget({
    super.key,
    required this.bpm,
    this.height = 70,
    this.color,
    this.isLive = true,
  });

  @override
  State<EcgWaveformWidget> createState() => _EcgWaveformWidgetState();
}

class _EcgWaveformWidgetState extends State<EcgWaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    // 60 / BPM gives duration per beat in seconds.
    final durationMs = widget.bpm > 30 ? (60000 / widget.bpm).round() : 1200;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs.clamp(500, 2000)),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant EcgWaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bpm != widget.bpm) {
      final durationMs = widget.bpm > 30 ? (60000 / widget.bpm).round() : 1200;
      _controller.duration = Duration(milliseconds: durationMs.clamp(500, 2000));
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waveColor = widget.color ?? ClinicalColors.heart;

    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: _EcgPainter(
              progress: _controller.value,
              color: waveColor,
              isLive: widget.isLive && widget.bpm > 0,
            ),
          );
        },
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isLive;

  _EcgPainter({
    required this.progress,
    required this.color,
    required this.isLive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final midY = h * 0.55;

    // Draw subtle grid lines (clinical monitor feel)
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    const gridSpacing = 16.0;
    for (double x = 0; x < w; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    final wavePath = Path();
    final pointCount = w.toInt();
    if (pointCount <= 0) return;

    // Build continuous ECG profile
    // Standard ECG cycle: P wave (atrium), PR segment, QRS complex (ventricles), ST segment, T wave (repolarization)
    bool started = false;

    for (int i = 0; i <= pointCount; i++) {
      final x = i.toDouble();
      // Wave travels across the screen
      final phase = ((x / w) - progress) % 1.0;
      final cycle = phase < 0 ? phase + 1.0 : phase;

      double dy = 0.0;

      if (isLive) {
        if (cycle >= 0.15 && cycle < 0.23) {
          // P wave (gentle bump)
          final pPhase = (cycle - 0.15) / 0.08;
          dy = -math.sin(pPhase * math.pi) * (h * 0.15);
        } else if (cycle >= 0.28 && cycle < 0.31) {
          // Q wave (small dip)
          final qPhase = (cycle - 0.28) / 0.03;
          dy = math.sin(qPhase * math.pi) * (h * 0.12);
        } else if (cycle >= 0.31 && cycle < 0.36) {
          // R wave (sharp tall peak)
          final rPhase = (cycle - 0.31) / 0.05;
          dy = -math.sin(rPhase * math.pi) * (h * 0.52);
        } else if (cycle >= 0.36 && cycle < 0.40) {
          // S wave (deep downward spike)
          final sPhase = (cycle - 0.36) / 0.04;
          dy = math.sin(sPhase * math.pi) * (h * 0.24);
        } else if (cycle >= 0.46 && cycle < 0.60) {
          // T wave (smooth rounded bump)
          final tPhase = (cycle - 0.46) / 0.14;
          dy = -math.sin(tPhase * math.pi) * (h * 0.22);
        }
      } else {
        // Flatline or resting subtle wave when no live signal
        dy = math.sin(cycle * math.pi * 4) * 2.0;
      }

      final y = midY + dy;
      if (!started) {
        wavePath.moveTo(x, y);
        started = true;
      } else {
        wavePath.lineTo(x, y);
      }
    }

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    // Primary stroke
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(wavePath, glowPaint);
    canvas.drawPath(wavePath, linePaint);

    // Leading scan point indicator dot
    final scanX = (progress * w);
    final scanPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final scanAura = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(scanX, midY), 6.0, scanAura);
    canvas.drawCircle(Offset(scanX, midY), 3.0, scanPaint);
  }

  @override
  bool shouldRepaint(covariant _EcgPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isLive != isLive;
  }
}
