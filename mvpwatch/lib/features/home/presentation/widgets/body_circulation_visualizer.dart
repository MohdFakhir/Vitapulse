import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BodyCirculationVisualizer extends StatefulWidget {
  final int heartRate;
  final VoidCallback? onHeartTap;

  const BodyCirculationVisualizer({
    super.key,
    required this.heartRate,
    this.onHeartTap,
  });

  @override
  State<BodyCirculationVisualizer> createState() =>
      _BodyCirculationVisualizerState();
}

class _BodyCirculationVisualizerState extends State<BodyCirculationVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _flowController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Pulse animation frequency matches real heart rate
    final durationMs = widget.heartRate > 35
        ? (60000 / widget.heartRate).round()
        : 1100;

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs.clamp(450, 1600)),
    );

    // Anatomical heartbeat curve: quick systolic contraction followed by brief diastolic recovery
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 0.98)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.98, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_pulseController);

    _pulseController.repeat();

    // Continuous circulation flow loop (arterial & venous flow particles)
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant BodyCirculationVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.heartRate != widget.heartRate) {
      final durationMs = widget.heartRate > 35
          ? (60000 / widget.heartRate).round()
          : 1100;
      _pulseController.duration =
          Duration(milliseconds: durationMs.clamp(450, 1600));
      if (!_pulseController.isAnimating) {
        _pulseController.repeat();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flowController.dispose();
    super.dispose();
  }

  String _getHeartStatus() {
    if (widget.heartRate <= 0) return 'Awaiting Sensor';
    if (widget.heartRate < 60) return 'Resting / Low';
    if (widget.heartRate <= 80) return 'Optimal';
    if (widget.heartRate <= 100) return 'Normal';
    return 'Elevated';
  }

  Color _getStatusColor() {
    if (widget.heartRate <= 0) return ClinicalColors.textTertiary;
    if (widget.heartRate < 60) return ClinicalColors.sleep;
    if (widget.heartRate <= 80) return ClinicalColors.healthy;
    if (widget.heartRate <= 100) return ClinicalColors.oxygen;
    return ClinicalColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _getHeartStatus();
    final statusColor = _getStatusColor();
    final isLive = widget.heartRate > 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ClinicalColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: ClinicalColors.border),
        boxShadow: ClinicalColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Background subtle radial clinical aura
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ClinicalColors.heart.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ClinicalColors.oxygen.withValues(alpha: 0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Content column
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header badge: Medical Command Center
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isLive
                                  ? ClinicalColors.heartLight
                                  : ClinicalColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isLive
                                    ? ClinicalColors.heart.withValues(alpha: 0.3)
                                    : ClinicalColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isLive
                                        ? ClinicalColors.heart
                                        : ClinicalColors.textTertiary,
                                    boxShadow: isLive
                                        ? [
                                            BoxShadow(
                                              color: ClinicalColors.heart
                                                  .withValues(alpha: 0.6),
                                              blurRadius: 6,
                                              spreadRadius: 1,
                                            )
                                          ]
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isLive ? 'LIVE TELEMETRY' : 'DEVICE STANDBY',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: isLive
                                        ? ClinicalColors.heart
                                        : ClinicalColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          statusText.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Torso + Heart Circulation Canvas
                  SizedBox(
                    height: 230,
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: Listenable.merge(
                          [_pulseAnimation, _flowController]),
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(double.infinity, 230),
                          painter: _TorsoCirculationPainter(
                            pulseScale: isLive ? _pulseAnimation.value : 1.0,
                            flowProgress: _flowController.value,
                            heartRate: widget.heartRate,
                            statusColor: statusColor,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Telemetry Status Bar below Visualizer
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: ClinicalColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ClinicalColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 18,
                              color: isLive
                                  ? ClinicalColors.heart
                                  : ClinicalColors.textTertiary,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CARDIAC CYCLE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: ClinicalColors.textTertiary,
                                  ),
                                ),
                                Text(
                                  isLive
                                      ? '${widget.heartRate} BPM • Pulsing'
                                      : 'Waiting for watch data',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ClinicalColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.bloodtype,
                              size: 18,
                              color: isLive
                                  ? ClinicalColors.circulationArtery
                                  : ClinicalColors.textTertiary,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CIRCULATION',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: ClinicalColors.textTertiary,
                                  ),
                                ),
                                Text(
                                  isLive ? 'Active Flow' : 'Resting Baseline',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ClinicalColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TorsoCirculationPainter extends CustomPainter {
  final double pulseScale;
  final double flowProgress;
  final int heartRate;
  final Color statusColor;

  _TorsoCirculationPainter({
    required this.pulseScale,
    required this.flowProgress,
    required this.heartRate,
    required this.statusColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w * 0.48;
    final centerY = h * 0.52;

    // ─── 1. Human Body Silhouette (Torso, Shoulders, Neck) ─────────
    final torsoPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final torsoPath = Path();
    // Neck
    torsoPath.moveTo(centerX - 24, h * 0.08);
    torsoPath.lineTo(centerX - 24, h * 0.16);
    // Left Shoulder
    torsoPath.cubicTo(
      centerX - 35, h * 0.18,
      centerX - 85, h * 0.22,
      centerX - 105, h * 0.32,
    );
    // Left Upper Arm / Lat
    torsoPath.cubicTo(
      centerX - 115, h * 0.40,
      centerX - 95, h * 0.65,
      centerX - 80, h * 0.92,
    );
    // Torso Base
    torsoPath.lineTo(centerX + 80, h * 0.92);
    // Right Upper Arm / Lat
    torsoPath.cubicTo(
      centerX + 95, h * 0.65,
      centerX + 115, h * 0.40,
      centerX + 105, h * 0.32,
    );
    // Right Shoulder
    torsoPath.cubicTo(
      centerX + 85, h * 0.22,
      centerX + 35, h * 0.18,
      centerX + 24, h * 0.16,
    );
    // Neck Right
    torsoPath.lineTo(centerX + 24, h * 0.08);

    canvas.drawPath(torsoPath, torsoPaint);

    // Ribcage / Sternum clinical guideline
    final sternumPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(centerX, h * 0.22),
      Offset(centerX, h * 0.75),
      sternumPaint,
    );

    // Clavicles
    final claviclePath = Path();
    claviclePath.moveTo(centerX - 50, h * 0.22);
    claviclePath.quadraticBezierTo(centerX, h * 0.26, centerX + 50, h * 0.22);
    canvas.drawPath(claviclePath, sternumPaint);

    // ─── 2. Vascular Circulation Paths (Aorta & Veins) ───────────────
    final heartX = centerX - 8;
    final heartY = centerY - 10;

    // Aortic Arch (oxygenated red)
    final aortaPath = Path();
    aortaPath.moveTo(heartX, heartY - 16);
    // Arch upward toward neck and split to shoulders
    aortaPath.cubicTo(
      heartX + 2, heartY - 45,
      heartX + 26, heartY - 50,
      heartX + 22, heartY - 30,
    );
    // Descending aorta
    aortaPath.lineTo(heartX + 16, h * 0.88);

    // Pulmonary / Superior Vena Cava (deoxygenated blue)
    final venaCavaPath = Path();
    venaCavaPath.moveTo(heartX - 18, h * 0.88);
    venaCavaPath.lineTo(heartX - 18, heartY);
    venaCavaPath.cubicTo(
      heartX - 18, heartY - 35,
      heartX - 35, heartY - 45,
      centerX - 55, h * 0.28,
    );

    final carotidRight = Path();
    carotidRight.moveTo(heartX + 18, heartY - 48);
    carotidRight.lineTo(centerX + 14, h * 0.10);

    final carotidLeft = Path();
    carotidLeft.moveTo(heartX + 6, heartY - 46);
    carotidLeft.lineTo(centerX - 14, h * 0.10);

    // Draw vascular base paths
    final arteryVesselPaint = Paint()
      ..color = ClinicalColors.circulationArtery.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final veinVesselPaint = Paint()
      ..color = ClinicalColors.circulationVein.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(aortaPath, arteryVesselPaint);
    canvas.drawPath(carotidRight, arteryVesselPaint);
    canvas.drawPath(carotidLeft, arteryVesselPaint);
    canvas.drawPath(venaCavaPath, veinVesselPaint);

    // ─── 3. Dynamic Circulation Flow Particles ───────────────────────
    final particleRed = Paint()
      ..color = ClinicalColors.circulationArtery
      ..style = PaintingStyle.fill;
    final particleGlow = Paint()
      ..color = ClinicalColors.circulationArtery.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    final particleBlue = Paint()
      ..color = ClinicalColors.circulationVein
      ..style = PaintingStyle.fill;

    // Flow along aorta (descending)
    for (int p = 0; p < 4; p++) {
      final t = (flowProgress + (p * 0.25)) % 1.0;
      final py = (heartY - 20) + t * (h * 0.88 - (heartY - 20));
      final px = heartX + 16 + math.sin(t * math.pi) * 3;
      canvas.drawCircle(Offset(px, py), 4.5, particleGlow);
      canvas.drawCircle(Offset(px, py), 2.2, particleRed);
    }

    // Flow along ascending carotids
    for (int p = 0; p < 2; p++) {
      final t = (flowProgress * 1.2 + (p * 0.5)) % 1.0;
      final py = (heartY - 45) - t * ((heartY - 45) - h * 0.10);
      final px = (heartX + 16) - t * 4;
      canvas.drawCircle(Offset(px, py), 2.0, particleRed);
    }

    // Return flow along vena cava (blue)
    for (int p = 0; p < 3; p++) {
      final t = (1.0 - (flowProgress + (p * 0.33)) % 1.0);
      final py = heartY + (t * (h * 0.88 - heartY));
      final px = heartX - 18;
      canvas.drawCircle(Offset(px, py), 2.0, particleBlue);
    }

    // ─── 4. Anatomical Heart (Left Mediastinum) ─────────────────────
    canvas.save();
    canvas.translate(heartX, heartY);
    canvas.scale(pulseScale);

    // Cardiac Aura / Glow
    final auraPaint = Paint()
      ..color = ClinicalColors.heart.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14.0);
    canvas.drawCircle(Offset.zero, 34.0, auraPaint);

    // Anatomical Heart Path
    final heartPath = Path();
    heartPath.moveTo(0, 8);
    // Left ventricle (apex pointing lower left)
    heartPath.cubicTo(
      -18, -12,
      -34, 10,
      -8, 38,
    );
    // Apex tip
    heartPath.lineTo(0, 42);
    // Right ventricle & atrium
    heartPath.cubicTo(
      8, 38,
      34, 10,
      18, -12,
    );
    // Superior base
    heartPath.cubicTo(
      10, -22,
      -10, -22,
      0, 8,
    );

    final heartFill = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFF334B),
          Color(0xFFE02424),
          Color(0xFF991B1B),
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(const Rect.fromLTWH(-30, -25, 60, 65));

    canvas.drawPath(heartPath, heartFill);

    // Ventricular septum & coronary sulcus highlight
    final sulcusPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final sulcusPath = Path();
    sulcusPath.moveTo(-2, -8);
    sulcusPath.quadraticBezierTo(-8, 14, -4, 38);
    canvas.drawPath(sulcusPath, sulcusPaint);

    canvas.restore();

    // ─── 5. Telemetry Connection Line & Readout Badge ───────────────
    final leaderX = heartX + 28;
    final leaderY = heartY + 8;
    final calloutX = w - 18;

    final leaderPaint = Paint()
      ..color = ClinicalColors.heart.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final leaderPath = Path();
    leaderPath.moveTo(leaderX, leaderY);
    leaderPath.lineTo(leaderX + 32, leaderY - 18);
    leaderPath.lineTo(calloutX - 86, leaderY - 18);

    canvas.drawPath(leaderPath, leaderPaint);
    canvas.drawCircle(Offset(leaderX, leaderY), 3.0, Paint()..color = ClinicalColors.heart);

    // Live Readout Box
    final boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(calloutX - 88, leaderY - 42, 88, 48),
      const Radius.circular(12),
    );

    final boxBg = Paint()..color = ClinicalColors.surface;
    final boxBorder = Paint()
      ..color = ClinicalColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRRect(boxRect, boxBg);
    canvas.drawRRect(boxRect, boxBorder);

    // Draw Text in Readout Box
    final tpLabel = TextPainter(
      text: const TextSpan(
        text: 'HEART RATE',
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: ClinicalColors.textTertiary,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpLabel.paint(canvas, Offset(calloutX - 80, leaderY - 36));

    final hrValueText = heartRate > 0 ? '$heartRate' : '--';
    final tpHr = TextPainter(
      text: TextSpan(
        text: hrValueText,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: ClinicalColors.textPrimary,
        ),
        children: const [
          TextSpan(
            text: ' bpm',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: ClinicalColors.textSecondary,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tpHr.paint(canvas, Offset(calloutX - 80, leaderY - 24));
  }

  @override
  bool shouldRepaint(covariant _TorsoCirculationPainter oldDelegate) {
    return oldDelegate.pulseScale != pulseScale ||
        oldDelegate.flowProgress != flowProgress ||
        oldDelegate.heartRate != heartRate ||
        oldDelegate.statusColor != statusColor;
  }
}
