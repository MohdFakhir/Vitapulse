import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum BodyOrgan { heart, brain, lungs, blood, body }

class BodyOrganData {
  final BodyOrgan organ;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String primaryMetric;
  final String secondaryMetric;
  final String status;
  final String clinicalNote;

  const BodyOrganData({
    required this.organ,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.primaryMetric,
    required this.secondaryMetric,
    required this.status,
    required this.clinicalNote,
  });
}

class BodyStatusInteractiveSection extends StatefulWidget {
  final int heartRate;
  final int steps;
  final double sleepHours;

  const BodyStatusInteractiveSection({
    super.key,
    required this.heartRate,
    required this.steps,
    required this.sleepHours,
  });

  @override
  State<BodyStatusInteractiveSection> createState() =>
      _BodyStatusInteractiveSectionState();
}

class _BodyStatusInteractiveSectionState
    extends State<BodyStatusInteractiveSection> {
  BodyOrgan _selectedOrgan = BodyOrgan.heart;

  Map<BodyOrgan, BodyOrganData> _getOrganData() {
    final hr = widget.heartRate > 0 ? '${widget.heartRate} BPM' : '72 BPM';
    final sleep = widget.sleepHours > 0
        ? '${widget.sleepHours}h rest'
        : '7.8h restorative';
    final stepStr = widget.steps > 0 ? '${widget.steps} steps' : '8,420 steps';

    return {
      BodyOrgan.heart: BodyOrganData(
        organ: BodyOrgan.heart,
        title: 'Cardiac System',
        subtitle: 'Heart & Coronary Network',
        icon: Icons.favorite,
        color: ClinicalColors.heart,
        primaryMetric: hr,
        secondaryMetric: 'Resting: 64 BPM',
        status: 'Optimal Rhythm',
        clinicalNote:
            'Cardiac output is stabilized. Left ventricular stroke volume and pulse cadence within physiological norms.',
      ),
      BodyOrgan.brain: BodyOrganData(
        organ: BodyOrgan.brain,
        title: 'Cerebral System',
        subtitle: 'Neurological & Circadian Recovery',
        icon: Icons.psychology,
        color: ClinicalColors.sleep,
        primaryMetric: sleep,
        secondaryMetric: 'Neural Depth: 88%',
        status: 'High Restorative',
        clinicalNote:
            'Brain wave telemetry indicates complete REM cycle completion. Cognitive recharge index at peak threshold.',
      ),
      BodyOrgan.lungs: BodyOrganData(
        organ: BodyOrgan.lungs,
        title: 'Pulmonary System',
        subtitle: 'Respiration & Blood Oxygenation',
        icon: Icons.air,
        color: ClinicalColors.oxygen,
        primaryMetric: '98% SpO₂',
        secondaryMetric: '15 br/min cadence',
        status: 'Normal Saturation',
        clinicalNote:
            'Continuous arterial oxygen diffusion is regular. Rhythmic alveolar expansion maintains optimal gaseous exchange.',
      ),
      BodyOrgan.blood: BodyOrganData(
        organ: BodyOrgan.blood,
        title: 'Vascular System',
        subtitle: 'Hemodynamics & Blood Pressure',
        icon: Icons.speed,
        color: ClinicalColors.bloodPressure,
        primaryMetric: '118 / 76 mmHg',
        secondaryMetric: 'Vascular Tone: Good',
        status: 'Standard Normal',
        clinicalNote:
            'Arterial hydrostatic pressure within healthy target (< 120/80 mmHg). Peripheral vascular compliance verified.',
      ),
      BodyOrgan.body: BodyOrganData(
        organ: BodyOrgan.body,
        title: 'Kinetic Musculoskeletal',
        subtitle: 'Metabolic & Core Balance',
        icon: Icons.accessibility_new,
        color: ClinicalColors.healthy,
        primaryMetric: stepStr,
        secondaryMetric: 'Core: 36.6 °C',
        status: 'Active Biomotion',
        clinicalNote:
            'Total ambulatory kinetic expenditure and thermoregulatory stability recorded without acute fatigue indicators.',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final organMap = _getOrganData();
    final current = organMap[_selectedOrgan]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: ClinicalColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: ClinicalColors.border),
        boxShadow: ClinicalColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
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
                        'BODY STATUS & ANATOMY',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: ClinicalColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Select an organ system to inspect biosignals',
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

          // Selectable Organ Chips Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildOrganTab(
                  organ: BodyOrgan.heart,
                  label: 'Heart',
                  icon: Icons.favorite,
                  color: ClinicalColors.heart,
                ),
                const SizedBox(width: 8),
                _buildOrganTab(
                  organ: BodyOrgan.brain,
                  label: 'Brain',
                  icon: Icons.psychology,
                  color: ClinicalColors.sleep,
                ),
                const SizedBox(width: 8),
                _buildOrganTab(
                  organ: BodyOrgan.lungs,
                  label: 'Lungs',
                  icon: Icons.air,
                  color: ClinicalColors.oxygen,
                ),
                const SizedBox(width: 8),
                _buildOrganTab(
                  organ: BodyOrgan.blood,
                  label: 'Blood',
                  icon: Icons.speed,
                  color: ClinicalColors.bloodPressure,
                ),
                const SizedBox(width: 8),
                _buildOrganTab(
                  organ: BodyOrgan.body,
                  label: 'Body',
                  icon: Icons.accessibility_new,
                  color: ClinicalColors.healthy,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 3D Anatomy Visual and Selected Organ Telemetry Card
          LayoutBuilder(
            builder: (context, constraints) {
              final isStacked = constraints.maxWidth < 540;

              final visual = Container(
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: current.color.withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/medical_body_anatomy.jpg',
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              current.icon,
                              size: 80,
                              color: current.color,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: current.color.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(current.icon, size: 14, color: current.color),
                              const SizedBox(width: 6),
                              Text(
                                current.title.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: current.color,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );

              final details = AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Container(
                  key: ValueKey(current.organ),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: ClinicalColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: current.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              current.subtitle.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: ClinicalColors.textTertiary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: current.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              current.status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: current.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        current.primaryMetric,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: ClinicalColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        current.secondaryMetric,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: current.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: ClinicalColors.borderSubtle),
                      const SizedBox(height: 10),
                      Text(
                        current.clinicalNote,
                        style: const TextStyle(
                          fontSize: 11,
                          color: ClinicalColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              );

              if (isStacked) {
                return Column(
                  children: [
                    visual,
                    const SizedBox(height: 14),
                    details,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 5, child: visual),
                  const SizedBox(width: 16),
                  Expanded(flex: 6, child: details),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrganTab({
    required BodyOrgan organ,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedOrgan == organ;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedOrgan = organ;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : ClinicalColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : ClinicalColors.borderSubtle,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : ClinicalColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? color : ClinicalColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
