import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BloodPressureSection extends StatelessWidget {
  final int? systolic;
  final int? diastolic;

  const BloodPressureSection({
    super.key,
    this.systolic,
    this.diastolic,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = systolic != null && diastolic != null;

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
                      color: ClinicalColors.bloodPressure.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.speed,
                      color: ClinicalColors.bloodPressure,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BLOOD PRESSURE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: ClinicalColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Systolic / Diastolic Pressure',
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
                  hasData ? 'RECORDED' : 'UNAVAILABLE',
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
                hasData ? '$systolic' : '--',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  height: 1.0,
                  color: ClinicalColors.textPrimary,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '/',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: ClinicalColors.textTertiary,
                  ),
                ),
              ),
              Text(
                hasData ? '$diastolic' : '--',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  height: 1.0,
                  color: ClinicalColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'mmHg',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ClinicalColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Clinical BP Scale Bar (Ready for data visualization)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ClinicalColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ClinicalColors.borderSubtle),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'STANDARD TARGET (SYS / DIA)',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: ClinicalColors.textTertiary,
                      ),
                    ),
                    Text(
                      '< 120 / 80 mmHg (Normal)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: hasData
                            ? ClinicalColors.healthy
                            : ClinicalColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Gradient Range Track
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 8,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            color: ClinicalColors.healthy.withValues(alpha: hasData ? 0.9 : 0.3),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          flex: 1,
                          child: Container(
                            color: ClinicalColors.warning.withValues(alpha: hasData ? 0.9 : 0.3),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          flex: 1,
                          child: Container(
                            color: ClinicalColors.heart.withValues(alpha: hasData ? 0.9 : 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Honest Data Notice
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
                        ? 'Blood pressure telemetry active'
                        : 'Blood pressure data unavailable • Ready for clinical cuff or supported watch',
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
