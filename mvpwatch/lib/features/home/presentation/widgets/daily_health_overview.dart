import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DailyHealthOverview extends StatelessWidget {
  final int steps;
  final int stepGoal;
  final double calories;
  final double waterIntake;
  final double waterGoal;
  final double runningDistance;
  final VoidCallback onAddWater;

  const DailyHealthOverview({
    super.key,
    required this.steps,
    required this.stepGoal,
    required this.calories,
    required this.waterIntake,
    required this.waterGoal,
    required this.runningDistance,
    required this.onAddWater,
  });

  @override
  Widget build(BuildContext context) {
    final stepProgress = stepGoal > 0 ? (steps / stepGoal).clamp(0.0, 1.0) : 0.0;
    final waterProgress = waterGoal > 0 ? (waterIntake / waterGoal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'DAILY BIOMETRIC & ACTIVITY LOG',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: ClinicalColors.textTertiary,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 1. Steps Card (Wide)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: ClinicalColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: ClinicalColors.border),
            boxShadow: ClinicalColors.cardShadow,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          value: stepProgress,
                          strokeWidth: 6,
                          backgroundColor: ClinicalColors.surfaceMuted,
                          color: ClinicalColors.healthy,
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(
                        Icons.directions_walk,
                        color: ClinicalColors.healthy,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DAILY STEPS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: ClinicalColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$steps',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: ClinicalColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '/ $stepGoal target',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ClinicalColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(stepProgress * 100).toInt()}% completed',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ClinicalColors.healthy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. Supporting Secondary Stats Grid: Calories, Water, Distance
        Row(
          children: [
            // Calories
            Expanded(
              child: _buildSmallStatCard(
                icon: Icons.local_fire_department,
                iconColor: ClinicalColors.warning,
                label: 'CALORIES',
                value: '${calories.toInt()}',
                unit: 'kcal burned',
              ),
            ),
            const SizedBox(width: 12),
            // Distance
            Expanded(
              child: _buildSmallStatCard(
                icon: Icons.map,
                iconColor: ClinicalColors.oxygen,
                label: 'DISTANCE',
                value: runningDistance.toStringAsFixed(1),
                unit: 'km travelled',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 3. Water Intake Card (Interactive +0.25L preserved)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: ClinicalColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: ClinicalColors.border),
            boxShadow: ClinicalColors.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ClinicalColors.oxygenLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: ClinicalColors.oxygen,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HYDRATION LEVEL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: ClinicalColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${waterIntake.toStringAsFixed(2)} / ${waterGoal.toStringAsFixed(1)} L',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: ClinicalColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: waterProgress,
                        minHeight: 6,
                        backgroundColor: ClinicalColors.surfaceMuted,
                        color: ClinicalColors.oxygen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Add Water Action Button
              InkWell(
                onTap: onAddWater,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: ClinicalColors.oxygenLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ClinicalColors.oxygen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.add, color: ClinicalColors.oxygen, size: 18),
                      SizedBox(height: 2),
                      Text(
                        '+0.25L',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: ClinicalColors.oxygen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ClinicalColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ClinicalColors.border),
        boxShadow: ClinicalColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: ClinicalColors.textTertiary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: ClinicalColors.textPrimary,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 10,
              color: ClinicalColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
