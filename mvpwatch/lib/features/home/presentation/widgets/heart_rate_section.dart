import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import 'ecg_waveform_widget.dart';

class HeartRateSection extends StatelessWidget {
  final int heartRate;
  final List<int> history;

  const HeartRateSection({
    super.key,
    required this.heartRate,
    required this.history,
  });

  String _getHeartRateStatus(int bpm) {
    if (bpm <= 0) return 'Awaiting Data';
    if (bpm < 60) return 'Resting / Low';
    if (bpm <= 80) return 'Optimal Rhythm';
    if (bpm <= 100) return 'Normal Rhythm';
    return 'Elevated Rhythm';
  }

  Color _getStatusColor(int bpm) {
    if (bpm <= 0) return ClinicalColors.textTertiary;
    if (bpm < 60) return ClinicalColors.sleep;
    if (bpm <= 80) return ClinicalColors.healthy;
    if (bpm <= 100) return ClinicalColors.oxygen;
    return ClinicalColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final isLive = heartRate > 0;
    final statusText = _getHeartRateStatus(heartRate);
    final statusColor = _getStatusColor(heartRate);

    // Calculate real stats from recorded history without fabricating
    int? minBpm;
    int? maxBpm;
    int? avgBpm;

    if (history.isNotEmpty) {
      minBpm = history.reduce(math.min);
      maxBpm = history.reduce(math.max);
      final sum = history.reduce((a, b) => a + b);
      avgBpm = (sum / history.length).round();
    } else if (heartRate > 0) {
      minBpm = heartRate;
      maxBpm = heartRate;
      avgBpm = heartRate;
    }

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
          // Section header with live indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ClinicalColors.heartLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.monitor_heart,
                      color: ClinicalColors.heart,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HEART RATE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: ClinicalColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Continuous Biometric Monitor',
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
                  color: isLive
                      ? ClinicalColors.heartLight
                      : ClinicalColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isLive
                        ? ClinicalColors.heart.withValues(alpha: 0.3)
                        : ClinicalColors.border,
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
                            ? ClinicalColors.heart
                            : ClinicalColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isLive ? 'LIVE' : 'STANDBY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
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

          const SizedBox(height: 20),

          // Primary readout: BPM & Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                isLive ? '$heartRate' : '--',
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  height: 1.0,
                  color: ClinicalColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'BPM',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ClinicalColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ECG Waveform strip
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: ClinicalColors.surfaceMuted,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LEAD II ECG TELEMETRY',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                          color: ClinicalColors.textTertiary,
                        ),
                      ),
                      Text(
                        '25mm/s • 10mm/mV',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: ClinicalColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  EcgWaveformWidget(
                    bpm: heartRate,
                    height: 56,
                    color: ClinicalColors.heart,
                    isLive: isLive,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Heart Rate History Graph (from real data)
          if (history.length >= 2) ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT TREND',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: ClinicalColors.textTertiary,
                  ),
                ),
                Text(
                  'Past readings',
                  style: TextStyle(
                    fontSize: 11,
                    color: ClinicalColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: ClinicalColors.borderSubtle,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (history.length - 1).toDouble(),
                  minY: (history.reduce(math.min) - 5).toDouble().clamp(30, 200),
                  maxY: (history.reduce(math.max) + 5).toDouble().clamp(40, 220),
                  lineBarsData: [
                    LineChartBarData(
                      spots: history
                          .asMap()
                          .entries
                          .map((e) =>
                              FlSpot(e.key.toDouble(), e.value.toDouble()))
                          .toList(),
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: ClinicalColors.heart,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            ClinicalColors.heart.withValues(alpha: 0.22),
                            ClinicalColors.heart.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: Text(
                isLive
                    ? 'Recording trend points...'
                    : 'Waiting for smartwatch telemetry to plot trend.',
                style: const TextStyle(
                  fontSize: 11,
                  color: ClinicalColors.textSecondary,
                ),
              ),
            ),
          ],

          // Min / Max / Average metrics row (Real data calculated)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: ClinicalColors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ClinicalColors.borderSubtle),
            ),
            child: Row(
              children: [
                _buildStatPill(
                  label: 'MIN BPM',
                  value: minBpm != null ? '$minBpm' : '--',
                  color: ClinicalColors.sleep,
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: ClinicalColors.border,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                _buildStatPill(
                  label: 'AVG BPM',
                  value: avgBpm != null ? '$avgBpm' : '--',
                  color: ClinicalColors.healthy,
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: ClinicalColors.border,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                _buildStatPill(
                  label: 'MAX BPM',
                  value: maxBpm != null ? '$maxBpm' : '--',
                  color: ClinicalColors.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: ClinicalColors.textTertiary,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ClinicalColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
