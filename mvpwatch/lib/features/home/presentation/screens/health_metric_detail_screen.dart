import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/ecg_waveform_widget.dart';

enum MetricType { heartRate, spo2, bloodPressure, temperature }

class HealthMetricDetailScreen extends StatefulWidget {
  final MetricType initialMetric;
  final int currentHeartRate;
  final List<int> heartRateHistory;

  const HealthMetricDetailScreen({
    super.key,
    this.initialMetric = MetricType.heartRate,
    this.currentHeartRate = 72,
    this.heartRateHistory = const [],
  });

  @override
  State<HealthMetricDetailScreen> createState() =>
      _HealthMetricDetailScreenState();
}

class _HealthMetricDetailScreenState extends State<HealthMetricDetailScreen> {
  late MetricType _selectedMetric;
  int _selectedPeriod = 1; // 0: Today, 1: 7 Days, 2: 30 Days

  @override
  void initState() {
    super.initState();
    _selectedMetric = widget.initialMetric;
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Scaffold(
      backgroundColor: ClinicalColors.background,
      appBar: AppBar(
        backgroundColor: ClinicalColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: ClinicalColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          config.screenTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: ClinicalColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            color: ClinicalColors.textSecondary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exporting biometric PDF clinical report...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Metric Switcher Chips
                  _buildMetricChips(),

                  const SizedBox(height: 28),

                  // Large Metric Header
                  Text(
                    config.metricCategory,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: config.accentColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Big Typography Value
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        config.displayValue,
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2.0,
                          height: 1.0,
                          color: ClinicalColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        config.unit,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: ClinicalColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: config.statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: config.statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: config.statusColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          config.statusText,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: config.statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Period Selector (Today, 7 Days, 30 Days)
                  _buildPeriodSelector(),

                  const SizedBox(height: 24),

                  // Visualization Card: ECG Waveform or Large Trend Chart
                  _buildVisualCard(config),

                  const SizedBox(height: 20),

                  // Statistics Row: Average, Minimum, Maximum
                  _buildStatsCards(config),

                  const SizedBox(height: 20),

                  // Clinical Telemetry Detail Card
                  _buildClinicalTelemetryCard(config),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: MetricType.values.map((type) {
          final isSelected = type == _selectedMetric;
          final info = _getChipInfo(type);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    info.icon,
                    size: 15,
                    color: isSelected ? Colors.white : info.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    info.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : ClinicalColors.textPrimary,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              selectedColor: info.color,
              backgroundColor: ClinicalColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? info.color : ClinicalColors.border,
                ),
              ),
              showCheckmark: false,
              onSelected: (selected) {
                if (selected) setState(() => _selectedMetric = type);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    const periods = ['Today', '7 Days', '30 Days'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ClinicalColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ClinicalColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(periods.length, (index) {
          final isSelected = _selectedPeriod == index;
          return InkWell(
            onTap: () => setState(() => _selectedPeriod = index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected ? ClinicalColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                periods[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? ClinicalColors.textPrimary
                      : ClinicalColors.textSecondary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVisualCard(_DetailConfig config) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ClinicalColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ClinicalColors.border),
        boxShadow: ClinicalColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedMetric == MetricType.heartRate
                    ? 'REAL-TIME ECG WAVEFORM'
                    : 'PERIOD TELEMETRY CURVE',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: ClinicalColors.textTertiary,
                ),
              ),
              Text(
                _selectedMetric == MetricType.heartRate
                    ? 'Lead II • 25mm/s'
                    : 'Recorded Samples',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ClinicalColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedMetric == MetricType.heartRate) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: const Color(0xFF0F172A),
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                child: EcgWaveformWidget(
                  bpm: widget.currentHeartRate > 0 ? widget.currentHeartRate : 72,
                  height: 90,
                  color: ClinicalColors.heart,
                  isLive: true,
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              height: 160,
              width: double.infinity,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: ClinicalColors.borderSubtle,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: config.spots,
                      isCurved: true,
                      color: config.accentColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            config.accentColor.withValues(alpha: 0.25),
                            config.accentColor.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsCards(_DetailConfig config) {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            'Average',
            config.avg,
            config.unit,
            ClinicalColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatBox(
            'Minimum',
            config.min,
            config.unit,
            ClinicalColors.sleep,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatBox(
            'Maximum',
            config.max,
            config.unit,
            config.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(
    String label,
    String value,
    String unit,
    Color valueColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: ClinicalColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ClinicalColors.border),
        boxShadow: ClinicalColors.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ClinicalColors.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: ClinicalColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalTelemetryCard(_DetailConfig config) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ClinicalColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ClinicalColors.border),
        boxShadow: ClinicalColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: config.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.health_and_safety_outlined,
                  color: config.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Clinical Reference & Target',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ClinicalColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            config.clinicalInsight,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: ClinicalColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          // Target range bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 8,
              color: ClinicalColors.surfaceMuted,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.75,
                child: Container(
                  color: config.accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                config.normalRangeStart,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ClinicalColors.textTertiary,
                ),
              ),
              Text(
                config.normalRangeEnd,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ClinicalColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _ChipInfo _getChipInfo(MetricType type) {
    switch (type) {
      case MetricType.heartRate:
        return _ChipInfo('Heart Rate', Icons.favorite, ClinicalColors.heart);
      case MetricType.spo2:
        return _ChipInfo('SpO₂', Icons.air, ClinicalColors.oxygen);
      case MetricType.bloodPressure:
        return _ChipInfo('Blood Pressure', Icons.speed, ClinicalColors.bloodPressure);
      case MetricType.temperature:
        return _ChipInfo('Temp', Icons.thermostat, ClinicalColors.warning);
    }
  }

  _DetailConfig _getConfig() {
    switch (_selectedMetric) {
      case MetricType.heartRate:
        final hr = widget.currentHeartRate > 0 ? widget.currentHeartRate : 72;
        return _DetailConfig(
          screenTitle: 'Heart Rate Monitor',
          metricCategory: 'HEART RATE',
          displayValue: '$hr',
          unit: 'BPM',
          statusText: 'Optimal Rhythm',
          statusColor: ClinicalColors.healthy,
          accentColor: ClinicalColors.heart,
          avg: '71',
          min: '61',
          max: '94',
          clinicalInsight:
              'Rhythm is sinus-stabilized. No ectopic beats detected in the current telemetry window.',
          normalRangeStart: 'Normal Resting: 60 BPM',
          normalRangeEnd: 'Upper Active: 100 BPM',
          spots: const [
            FlSpot(0, 68),
            FlSpot(1, 64),
            FlSpot(2, 75),
            FlSpot(3, 72),
            FlSpot(4, 78),
            FlSpot(5, 70),
            FlSpot(6, 72),
          ],
        );
      case MetricType.spo2:
        return _DetailConfig(
          screenTitle: 'Blood Oxygen (SpO₂)',
          metricCategory: 'BLOOD OXYGEN',
          displayValue: '98',
          unit: '%',
          statusText: 'Normal Saturation',
          statusColor: ClinicalColors.healthy,
          accentColor: ClinicalColors.oxygen,
          avg: '98.2',
          min: '96',
          max: '99',
          clinicalInsight:
              'Arterial hemoglobin saturation is within optimal respiratory range (95–100%).',
          normalRangeStart: 'Min Target: 95%',
          normalRangeEnd: 'Ideal: 100%',
          spots: const [
            FlSpot(0, 98),
            FlSpot(1, 99),
            FlSpot(2, 97),
            FlSpot(3, 98),
            FlSpot(4, 98),
            FlSpot(5, 99),
            FlSpot(6, 98),
          ],
        );
      case MetricType.bloodPressure:
        return _DetailConfig(
          screenTitle: 'Blood Pressure',
          metricCategory: 'BLOOD PRESSURE',
          displayValue: '118/76',
          unit: 'mmHg',
          statusText: 'Normal Systolic/Diastolic',
          statusColor: ClinicalColors.healthy,
          accentColor: ClinicalColors.bloodPressure,
          avg: '119/77',
          min: '114/72',
          max: '124/80',
          clinicalInsight:
              'Arterial pressure reading is optimal (<120 / <80 mmHg), demonstrating low cardiovascular strain.',
          normalRangeStart: 'Optimal: 120/80 mmHg',
          normalRangeEnd: 'Elevated: 130/80 mmHg',
          spots: const [
            FlSpot(0, 116),
            FlSpot(1, 118),
            FlSpot(2, 122),
            FlSpot(3, 119),
            FlSpot(4, 117),
            FlSpot(5, 120),
            FlSpot(6, 118),
          ],
        );
      case MetricType.temperature:
        return _DetailConfig(
          screenTitle: 'Body Temperature',
          metricCategory: 'TEMPERATURE',
          displayValue: '98.4',
          unit: '°F',
          statusText: 'Afebrile / Normal',
          statusColor: ClinicalColors.healthy,
          accentColor: ClinicalColors.warning,
          avg: '98.5',
          min: '97.9',
          max: '98.7',
          clinicalInsight:
              'Basal core temperature reflects normal diurnal variation with no indication of systemic inflammation.',
          normalRangeStart: 'Lower Norm: 97.0°F',
          normalRangeEnd: 'Upper Norm: 99.0°F',
          spots: const [
            FlSpot(0, 98.1),
            FlSpot(1, 97.9),
            FlSpot(2, 98.4),
            FlSpot(3, 98.6),
            FlSpot(4, 98.5),
            FlSpot(5, 98.3),
            FlSpot(6, 98.4),
          ],
        );
    }
  }
}

class _ChipInfo {
  final String title;
  final IconData icon;
  final Color color;

  const _ChipInfo(this.title, this.icon, this.color);
}

class _DetailConfig {
  final String screenTitle;
  final String metricCategory;
  final String displayValue;
  final String unit;
  final String statusText;
  final Color statusColor;
  final Color accentColor;
  final String avg;
  final String min;
  final String max;
  final String clinicalInsight;
  final String normalRangeStart;
  final String normalRangeEnd;
  final List<FlSpot> spots;

  const _DetailConfig({
    required this.screenTitle,
    required this.metricCategory,
    required this.displayValue,
    required this.unit,
    required this.statusText,
    required this.statusColor,
    required this.accentColor,
    required this.avg,
    required this.min,
    required this.max,
    required this.clinicalInsight,
    required this.normalRangeStart,
    required this.normalRangeEnd,
    required this.spots,
  });
}
