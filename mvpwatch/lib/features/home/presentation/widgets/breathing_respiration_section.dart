import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BreathingRespirationSection extends StatefulWidget {
  final int? respirationRate;

  const BreathingRespirationSection({
    super.key,
    this.respirationRate,
  });

  @override
  State<BreathingRespirationSection> createState() =>
      _BreathingRespirationSectionState();
}

class _BreathingRespirationSectionState
    extends State<BreathingRespirationSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    // Typical adult respiratory rate is 12-16 breaths per minute (~4.0 - 5.0 seconds per cycle)
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _expandAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasData = widget.respirationRate != null && widget.respirationRate! > 0;

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
                      color: ClinicalColors.respiratory.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.air_outlined,
                      color: ClinicalColors.respiratory,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RESPIRATORY RATE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: ClinicalColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Pulmonary Expansion & Cadence',
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
                  hasData ? 'ACTIVE' : 'EXPANDING',
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

          // Lungs animation and Readout in side-by-side row
          Row(
            children: [
              // Expanding lungs animation canvas
              SizedBox(
                width: 110,
                height: 100,
                child: AnimatedBuilder(
                  animation: _expandAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _LungsPainter(
                        scale: _expandAnimation.value,
                        isBreathing: true,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 18),
              // Values & Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          hasData ? '${widget.respirationRate}' : '--',
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                            height: 1.0,
                            color: ClinicalColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'br/min',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: ClinicalColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Resting Norm: 12 – 20 br/min',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ClinicalColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedBuilder(
                      animation: _breathController,
                      builder: (context, child) {
                        final isInhaling = _breathController.status ==
                            AnimationStatus.forward;
                        return Text(
                          isInhaling ? 'Inhalation phase...' : 'Exhalation phase...',
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: ClinicalColors.respiratory.withValues(alpha: 0.8),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Status Notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: ClinicalColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ClinicalColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: ClinicalColors.textTertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasData
                        ? 'Respiration cadence synced from watch'
                        : 'Respiratory rate unavailable • Rhythmic breathing guide active',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ClinicalColors.textSecondary,
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

class _LungsPainter extends CustomPainter {
  final double scale;
  final bool isBreathing;

  _LungsPainter({required this.scale, required this.isBreathing});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.52;

    // Trachea
    final tracheaPaint = Paint()
      ..color = ClinicalColors.respiratory.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(cx, h * 0.12), Offset(cx, h * 0.35), tracheaPaint);

    // Bronchi
    final bronchusLeft = Path()
      ..moveTo(cx, h * 0.35)
      ..quadraticBezierTo(cx - 12, h * 0.42, cx - 22, h * 0.46);
    final bronchusRight = Path()
      ..moveTo(cx, h * 0.35)
      ..quadraticBezierTo(cx + 12, h * 0.42, cx + 22, h * 0.46);

    canvas.drawPath(bronchusLeft, tracheaPaint);
    canvas.drawPath(bronchusRight, tracheaPaint);

    // Left Lung (Viewer's left)
    canvas.save();
    canvas.translate(cx - 26, cy);
    canvas.scale(scale);

    final leftLungPath = Path();
    leftLungPath.moveTo(0, -22);
    leftLungPath.cubicTo(
      -18, -20,
      -22, 10,
      -14, 26,
    );
    leftLungPath.quadraticBezierTo(-4, 30, 6, 22);
    leftLungPath.cubicTo(
      2, 12,
      4, -10,
      0, -22,
    );

    final lungFill = Paint()
      ..shader = LinearGradient(
        colors: [
          ClinicalColors.respiratory.withValues(alpha: 0.35),
          ClinicalColors.oxygen.withValues(alpha: 0.15),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(-25, -25, 40, 60));

    final lungStroke = Paint()
      ..color = ClinicalColors.respiratory
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.drawPath(leftLungPath, lungFill);
    canvas.drawPath(leftLungPath, lungStroke);
    canvas.restore();

    // Right Lung (Viewer's right)
    canvas.save();
    canvas.translate(cx + 26, cy);
    canvas.scale(scale);

    final rightLungPath = Path();
    rightLungPath.moveTo(0, -22);
    rightLungPath.cubicTo(
      18, -20,
      22, 10,
      14, 26,
    );
    rightLungPath.quadraticBezierTo(4, 30, -6, 22);
    rightLungPath.cubicTo(
      -2, 12,
      -4, -10,
      0, -22,
    );

    canvas.drawPath(rightLungPath, lungFill);
    canvas.drawPath(rightLungPath, lungStroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LungsPainter oldDelegate) {
    return oldDelegate.scale != scale || oldDelegate.isBreathing != isBreathing;
  }
}
