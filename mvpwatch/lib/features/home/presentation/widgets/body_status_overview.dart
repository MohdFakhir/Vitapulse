import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BodyStatusOverview extends StatelessWidget {
  final int heartRate;
  final int steps;
  final double sleepHours;

  const BodyStatusOverview({
    super.key,
    required this.heartRate,
    required this.steps,
    required this.sleepHours,
  });

  @override
  Widget build(BuildContext context) {
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
                      color: ClinicalColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.accessibility_new,
                      color: ClinicalColors.textPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BODY STATUS & SYSTEM MATRIX',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: ClinicalColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Integrated Organ & Biosignal Network',
                        style: TextStyle(
                          fontSize: 11,
                          color: ClinicalColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Grid of 6 anatomical organ/metric status nodes
          Row(
            children: [
              _buildMetricNode(
                icon: Icons.favorite,
                name: 'CARDIAC',
                value: heartRate > 0 ? '$heartRate BPM' : 'Standby',
                status: heartRate > 0 ? 'Active' : 'Waiting',
                accentColor: ClinicalColors.heart,
                isAvailable: heartRate > 0,
              ),
              const SizedBox(width: 10),
              _buildMetricNode(
                icon: Icons.air,
                name: 'OXYGEN (SpO₂)',
                value: 'Pending Sync',
                status: 'Unavailable',
                accentColor: ClinicalColors.oxygen,
                isAvailable: false,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMetricNode(
                icon: Icons.compress,
                name: 'RESPIRATION',
                value: 'Guide Active',
                status: 'Paced',
                accentColor: ClinicalColors.respiratory,
                isAvailable: true,
              ),
              const SizedBox(width: 10),
              _buildMetricNode(
                icon: Icons.device_thermostat,
                name: 'TEMPERATURE',
                value: 'Pending Sync',
                status: 'Unavailable',
                accentColor: ClinicalColors.warning,
                isAvailable: false,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMetricNode(
                icon: Icons.directions_walk,
                name: 'KINETIC ACTIVITY',
                value: '$steps Steps',
                status: steps > 0 ? 'Tracking' : 'Resting',
                accentColor: ClinicalColors.healthy,
                isAvailable: steps > 0,
              ),
              const SizedBox(width: 10),
              _buildMetricNode(
                icon: Icons.bedtime,
                name: 'RECOVERY / SLEEP',
                value: sleepHours > 0 ? '${sleepHours}h Logged' : 'No Record',
                status: sleepHours > 0 ? 'Restorative' : 'Waiting',
                accentColor: ClinicalColors.sleep,
                isAvailable: sleepHours > 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricNode({
    required IconData icon,
    required String name,
    required String value,
    required String status,
    required Color accentColor,
    required bool isAvailable,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ClinicalColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAvailable
                ? accentColor.withValues(alpha: 0.25)
                : ClinicalColors.borderSubtle,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: isAvailable ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: isAvailable ? accentColor : ClinicalColors.textTertiary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? accentColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: isAvailable ? accentColor : ClinicalColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: ClinicalColors.textTertiary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isAvailable
                    ? ClinicalColors.textPrimary
                    : ClinicalColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
