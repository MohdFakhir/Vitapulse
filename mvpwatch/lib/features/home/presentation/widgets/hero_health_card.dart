import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'ecg_waveform_widget.dart';

class HeroHealthCard extends StatefulWidget {
  final int heartRate;
  final List<int> history;
  final VoidCallback? onTap;

  const HeroHealthCard({
    super.key,
    required this.heartRate,
    required this.history,
    this.onTap,
  });

  @override
  State<HeroHealthCard> createState() => _HeroHealthCardState();
}

class _HeroHealthCardState extends State<HeroHealthCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    final bpm = widget.heartRate > 35 ? widget.heartRate : 72;
    final periodMs = (60000 / bpm).round().clamp(500, 1400);

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: periodMs),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant HeroHealthCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.heartRate != widget.heartRate) {
      final bpm = widget.heartRate > 35 ? widget.heartRate : 72;
      final periodMs = (60000 / bpm).round().clamp(500, 1400);
      _pulseController.duration = Duration(milliseconds: periodMs);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getHeartStatus(int bpm) {
    if (bpm <= 0) return 'Awaiting telemetry';
    if (bpm < 60) return 'Resting rhythm';
    if (bpm <= 80) return 'Optimal normal';
    if (bpm <= 100) return 'Normal rhythm';
    return 'Elevated';
  }

  @override
  Widget build(BuildContext context) {
    final isLive = widget.heartRate > 0;
    final displayBpm = isLive ? '${widget.heartRate}' : '72';
    final statusText = _getHeartStatus(widget.heartRate > 0 ? widget.heartRate : 72);

    int minBpm = 61;
    int avgBpm = 72;
    int maxBpm = 94;

    if (widget.history.isNotEmpty) {
      minBpm = widget.history.reduce(math.min);
      maxBpm = widget.history.reduce(math.max);
      final sum = widget.history.reduce((a, b) => a + b);
      avgBpm = (sum / widget.history.length).round();
    } else if (widget.heartRate > 0) {
      minBpm = widget.heartRate - 6;
      avgBpm = widget.heartRate;
      maxBpm = widget.heartRate + 12;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF131722), // Deep charcoal background
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: ClinicalColors.heart.withValues(alpha: 0.12),
            blurRadius: 36,
            spreadRadius: -4,
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Background subtle radial glow
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ClinicalColors.heart.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ClinicalColors.oxygen.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Pill & Label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: ClinicalColors.heart.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: ClinicalColors.heart,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'HEALTH OVERVIEW',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isLive
                              ? ClinicalColors.healthy.withValues(alpha: 0.18)
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isLive
                                ? ClinicalColors.healthy.withValues(alpha: 0.4)
                                : Colors.white12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isLive
                                    ? ClinicalColors.healthy
                                    : Colors.white38,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isLive ? 'LIVE' : 'TELEMETRY STANDBY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isLive
                                    ? ClinicalColors.healthy
                                    : Colors.white54,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Center Row: 3D Heart Illustration + Metrics
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 3D Heart Visual with animated pulse scaling
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: ClinicalColors.heart.withValues(alpha: 0.35),
                                    blurRadius: 28,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(65),
                                child: Image.asset(
                                  'assets/images/medical_heart_hero.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFF1E2433),
                                      child: const Center(
                                        child: Icon(
                                          Icons.favorite,
                                          size: 64,
                                          color: ClinicalColors.heart,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(width: 22),

                      // Heart Rate Large Readout & Sub-stats
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Heart Rate',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  displayBpm,
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -1.2,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'BPM',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: ClinicalColors.heart,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ClinicalColors.healthy
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: ClinicalColors.healthy,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_downward,
                                      size: 13,
                                      color: ClinicalColors.healthy,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      '4% vs yesterday',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white60,
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

                  const SizedBox(height: 20),

                  // Mini ECG Waveform strip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'CARDIAC CYCLE TELEMETRY',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.7,
                                color: Colors.white38,
                              ),
                            ),
                            Text(
                              'Continuous Lead II',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        EcgWaveformWidget(
                          bpm: widget.heartRate > 0 ? widget.heartRate : 72,
                          height: 44,
                          color: ClinicalColors.heart,
                          isLive: isLive,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Min / Avg / Max Statistics Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHeroStat(
                          label: 'Min',
                          value: '$minBpm',
                          unit: 'BPM',
                          color: ClinicalColors.sleep,
                        ),
                        Container(
                          width: 1,
                          height: 26,
                          color: Colors.white12,
                        ),
                        _buildHeroStat(
                          label: 'Avg',
                          value: '$avgBpm',
                          unit: 'BPM',
                          color: ClinicalColors.healthy,
                        ),
                        Container(
                          width: 1,
                          height: 26,
                          color: Colors.white12,
                        ),
                        _buildHeroStat(
                          label: 'Max',
                          value: '$maxBpm',
                          unit: 'BPM',
                          color: ClinicalColors.warning,
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

  Widget _buildHeroStat({
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white38,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
