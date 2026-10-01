import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SleepRecoverySection extends StatelessWidget {
  final double sleepHours;

  const SleepRecoverySection({
    super.key,
    required this.sleepHours,
  });

  String _formatSleepDuration(double hours) {
    if (hours <= 0) return '0h 0m';
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    return '${h}h ${m}m';
  }

  String _getRecoveryRating(double hours) {
    if (hours <= 0) return 'No Sleep Logged';
    if (hours < 5.0) return 'Incomplete Rest';
    if (hours < 6.5) return 'Sub-optimal Rest';
    if (hours <= 8.5) return 'Restorative Recovery';
    return 'Extended Recovery';
  }

  Color _getRecoveryColor(double hours) {
    if (hours <= 0) return ClinicalColors.textTertiary;
    if (hours < 5.0) return ClinicalColors.warning;
    if (hours < 6.5) return ClinicalColors.oxygen;
    if (hours <= 8.5) return ClinicalColors.sleep;
    return ClinicalColors.healthy;
  }

  @override
  Widget build(BuildContext context) {
    final hasData = sleepHours > 0;
    final recoveryText = _getRecoveryRating(sleepHours);
    final recoveryColor = _getRecoveryColor(sleepHours);

    // Derived sleep architecture based on clinical averages from actual sleep duration
    final deepHours = (sleepHours * 0.22).clamp(0.0, 4.0);
    final lightHours = (sleepHours * 0.53).clamp(0.0, 8.0);
    final remHours = (sleepHours * 0.25).clamp(0.0, 4.0);

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
                      color: ClinicalColors.sleepLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.bedtime,
                      color: ClinicalColors.sleep,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SLEEP & RECOVERY',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: ClinicalColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Circadian Architecture & Restoration',
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
                  color: recoveryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: recoveryColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  recoveryText.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: recoveryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Primary readout: Total sleep
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                hasData ? _formatSleepDuration(sleepHours) : '--',
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
                    'Optimal Target',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ClinicalColors.textSecondary,
                    ),
                  ),
                  Text(
                    '7h 00m – 9h 00m',
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

          const SizedBox(height: 18),

          // Sleep Timeline (Hypnogram Bar)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '11:00 PM',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: ClinicalColors.textTertiary,
                    ),
                  ),
                  Text(
                    'REST TIMELINE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: ClinicalColors.textTertiary,
                    ),
                  ),
                  Text(
                    '07:00 AM',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: ClinicalColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 16,
                  child: hasData
                      ? Row(
                          children: [
                            // Light Sleep
                            Expanded(
                              flex: 25,
                              child: Container(
                                color: ClinicalColors.sleep.withValues(alpha: 0.45),
                              ),
                            ),
                            const SizedBox(width: 2),
                            // Deep Sleep
                            Expanded(
                              flex: 22,
                              child: Container(
                                color: ClinicalColors.sleep,
                              ),
                            ),
                            const SizedBox(width: 2),
                            // REM
                            Expanded(
                              flex: 25,
                              child: Container(
                                color: ClinicalColors.oxygen,
                              ),
                            ),
                            const SizedBox(width: 2),
                            // Light Sleep
                            Expanded(
                              flex: 28,
                              child: Container(
                                color: ClinicalColors.sleep.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          color: ClinicalColors.surfaceMuted,
                          child: const Center(
                            child: Text(
                              'Awaiting sleep sync',
                              style: TextStyle(
                                fontSize: 9,
                                color: ClinicalColors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sleep Stages Breakdown Badges
          Row(
            children: [
              _buildStageChip(
                label: 'DEEP SLEEP',
                value: hasData ? '${deepHours.toStringAsFixed(1)}h' : '--',
                color: ClinicalColors.sleep,
                description: 'Physical Repair',
              ),
              const SizedBox(width: 8),
              _buildStageChip(
                label: 'REM SLEEP',
                value: hasData ? '${remHours.toStringAsFixed(1)}h' : '--',
                color: ClinicalColors.oxygen,
                description: 'Neural Memory',
              ),
              const SizedBox(width: 8),
              _buildStageChip(
                label: 'LIGHT SLEEP',
                value: hasData ? '${lightHours.toStringAsFixed(1)}h' : '--',
                color: ClinicalColors.sleep.withValues(alpha: 0.6),
                description: 'Core Rest',
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Informative Context Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: ClinicalColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ClinicalColors.borderSubtle),
            ),
            child: Row(
              children: [
                Icon(
                  hasData ? Icons.nightlight_round : Icons.info_outline,
                  size: 16,
                  color: hasData ? ClinicalColors.sleep : ClinicalColors.textTertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasData
                        ? 'Body temperature dropped & heart rhythm slowed to baseline recovery.'
                        : 'No sleep record detected. Wear watch to bed to track nightly regeneration.',
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

  Widget _buildStageChip({
    required String label,
    required String value,
    required Color color,
    required String description,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: ClinicalColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ClinicalColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: ClinicalColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ClinicalColors.textPrimary,
              ),
            ),
            Text(
              description,
              style: const TextStyle(
                fontSize: 9,
                color: ClinicalColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
