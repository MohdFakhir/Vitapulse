import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Clean, cinematic ambient background painter for HaloHeart.
/// Completely free of dashed rings, segmented circles, and busy radar animations.
class HaloHeartAmbientPainter extends CustomPainter {
  final double pulseValue;

  HaloHeartAmbientPainter({this.pulseValue = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.38);

    // 1. Deep premium near-black navy background
    final bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF030508),
        Color(0xFF060A13),
        Color(0xFF020407),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final bgPaint = Paint()
      ..shader = bgGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Soft, subtle radial cyan/blue ambient glow positioned directly behind the anatomical heart
    final glowRadius = math.min(size.width, size.height) * 0.55;
    final ambientAlpha = 0.06 + (pulseValue * 0.03); // very subtle breathing glow

    final glowGradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        const Color(0xFF00E5FF).withValues(alpha: ambientAlpha),
        const Color(0xFF0284C7).withValues(alpha: ambientAlpha * 0.5),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 1.0],
    );

    final glowPaint = Paint()
      ..shader = glowGradient.createShader(
        Rect.fromCircle(center: center, radius: glowRadius),
      );
    canvas.drawCircle(center, glowRadius, glowPaint);

    // 3. Faint, elegant background guide circle (thin, continuous, never competing)
    final guideRadius = math.min(size.width, size.height) * 0.34;
    final guidePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75;
    canvas.drawCircle(center, guideRadius, guidePaint);
  }

  @override
  bool shouldRepaint(covariant HaloHeartAmbientPainter oldDelegate) {
    return (oldDelegate.pulseValue - pulseValue).abs() > 0.01;
  }
}

/// A delicate glowing halo ring positioned gracefully above the heart.
class GlowingHaloPainter extends CustomPainter {
  final double pulseValue;

  GlowingHaloPainter({this.pulseValue = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(
      center: center,
      width: size.width - 4,
      height: size.height - 4,
    );

    final alpha = 0.75 + (pulseValue * 0.2);

    // Soft outer glow
    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: alpha * 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawOval(rect, glowPaint);

    // Crisp medical cyan ring
    final ringPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35;
    canvas.drawOval(rect, ringPaint);

    // Specular highlight on front rim
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: alpha * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawArc(rect, 0.4, 2.3, false, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant GlowingHaloPainter oldDelegate) {
    return (oldDelegate.pulseValue - pulseValue).abs() > 0.01;
  }
}

/// A subtle ECG rhythm strip drawn cleanly.
class SubtleEcgPainter extends CustomPainter {
  final double progress;

  SubtleEcgPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final midY = size.height / 2;
    final w = size.width;

    path.moveTo(0, midY);
    path.lineTo(w * 0.32, midY);
    // P wave
    path.quadraticBezierTo(w * 0.36, midY - 3, w * 0.40, midY);
    path.lineTo(w * 0.46, midY);
    // Q-R-S complex
    path.lineTo(w * 0.48, midY + 4);
    path.lineTo(w * 0.52, midY - 14);
    path.lineTo(w * 0.56, midY + 6);
    path.lineTo(w * 0.59, midY);
    // T wave
    path.lineTo(w * 0.65, midY);
    path.quadraticBezierTo(w * 0.70, midY - 5, w * 0.75, midY);
    path.lineTo(w, midY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SubtleEcgPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
