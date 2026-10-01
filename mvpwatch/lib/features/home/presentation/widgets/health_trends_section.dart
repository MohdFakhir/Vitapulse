import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';

enum HealthTrendPeriod { today, week, month }
enum HealthTrendMetric { heartRate, spo2, bloodPressure, temperature }

class HealthTrendsSection extends StatefulWidget {
  final int currentHeartRate;
  final List<int> heartRateHistory;

  const HealthTrendsSection({
    super.key,
    required this.currentHeartRate,
    required this.heartRateHistory,
  });

  @override
  State<HealthTrendsSection> createState() => _HealthTrendsSectionState();
}

class _HealthTrendsSectionState extends State<HealthTrendsSection> {
  HealthTrendPeriod _selectedPeriod = HealthTrendPeriod.week;
  HealthTrendMetric _selectedMetric = HealthTrendMetric.heartRate;

  @override
  Widget build(BuildContext context) {
    final metricConfig = _getMetricConfig();

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
          // Section Title & Period Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: metricConfig.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      metricConfig.icon,
                      color: metricConfig.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HEALTH TRENDS',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: ClinicalColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Telemetry & Longitudinal Analysis',
                        style: TextStyle(
                          fontSize: 11,
                          color: ClinicalColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Period Switcher (Today, 7 Days, 30 Days)
              _buildPeriodSelector(),
            ],
          ),

          const SizedBox(height: 18),

          // Metric Tab Selector (Heart Rate, SpO2, BP, Temp)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: HealthTrendMetric.values.map((metric) {
                final isSelected = metric == _selectedMetric;
                final config = _getConfigForMetric(metric);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedMetric = metric),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? config.color.withValues(alpha: 0.12)
                            : ClinicalColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? config.color
                              : ClinicalColors.borderSubtle,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            config.icon,
                            size: 15,
                            color: isSelected
                                ? config.color
                                : ClinicalColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            config.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? config.color
                                  : ClinicalColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Metric Summary Stats Header (Current, Avg, Min, Max)
          _buildSummaryStats(metricConfig),

          const SizedBox(height: 20),

          // Smooth Curve Trend Chart
          SizedBox(
            height: 190,
            width: double.infinity,
            child: _buildTrendChart(metricConfig),
          ),

          const SizedBox(height: 14),

          // Clinical Insight Footnote
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: ClinicalColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ClinicalColors.borderSubtle),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_graph,
                  size: 16,
                  color: metricConfig.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    metricConfig.insightText,
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

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ClinicalColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ClinicalColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPeriodButton('Today', HealthTrendPeriod.today),
          _buildPeriodButton('7 Days', HealthTrendPeriod.week),
          _buildPeriodButton('30 Days', HealthTrendPeriod.month),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, HealthTrendPeriod period) {
    final isSelected = _selectedPeriod == period;

    return InkWell(
      onTap: () => setState(() => _selectedPeriod = period),
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? ClinicalColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? ClinicalColors.textPrimary
                : ClinicalColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStats(_MetricConfig config) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Current',
            config.currentValue,
            config.unit,
            config.color,
          ),
        ),
        Container(width: 1, height: 32, color: ClinicalColors.border),
        Expanded(
          child: _buildStatItem(
            'Average',
            config.avgValue,
            config.unit,
            ClinicalColors.textPrimary,
          ),
        ),
        Container(width: 1, height: 32, color: ClinicalColors.border),
        Expanded(
          child: _buildStatItem(
            'Range',
            config.rangeValue,
            config.unit,
            ClinicalColors.textSecondary,
          ),
        ),
        Container(width: 1, height: 32, color: ClinicalColors.border),
        Expanded(
          child: _buildStatItem(
            'Trend',
            config.trendText,
            '',
            ClinicalColors.healthy,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    String unit,
    Color valueColor,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: ClinicalColors.textTertiary,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: ClinicalColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTrendChart(_MetricConfig config) {
    final spots = config.spots;
    final minY = config.minY;
    final maxY = config.maxY;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 3,
          getDrawingHorizontalLine: (value) => FlLine(
            color: ClinicalColors.borderSubtle,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: (maxY - minY) / 3,
              getTitlesWidget: (value, meta) {
                if (value == minY || value == maxY) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: ClinicalColors.textTertiary,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index < 0 || index >= config.xLabels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    config.xLabels[index],
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: ClinicalColors.textTertiary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (config.xLabels.length - 1).toDouble().clamp(1.0, 30.0),
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => const Color(0xFF1E293B),
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toInt()} ${config.unit}',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: config.color,
            barWidth: 2.8,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3.5,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: config.color,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  config.color.withValues(alpha: 0.22),
                  config.color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _MetricConfig _getConfigForMetric(HealthTrendMetric metric) {
    switch (metric) {
      case HealthTrendMetric.heartRate:
        return _MetricConfig(
          label: 'Heart Rate',
          unit: 'BPM',
          icon: Icons.monitor_heart,
          color: ClinicalColors.heart,
          currentValue: widget.currentHeartRate > 0
              ? '${widget.currentHeartRate}'
              : '72',
          avgValue: '71',
          rangeValue: '61 - 88',
          trendText: '↓ 4%',
          insightText:
              'Heart rate variance is within healthy autonomic recovery standards.',
          xLabels: _getXLabels(),
          spots: _getHeartRateSpots(),
          minY: 50,
          maxY: 110,
        );
      case HealthTrendMetric.spo2:
        return _MetricConfig(
          label: 'Blood Oxygen',
          unit: '%',
          icon: Icons.air,
          color: ClinicalColors.oxygen,
          currentValue: '98',
          avgValue: '98.2',
          rangeValue: '96 - 99',
          trendText: 'Stable',
          insightText:
              'Arterial oxygen saturation indicates optimal respiratory efficiency.',
          xLabels: _getXLabels(),
          spots: _getSpo2Spots(),
          minY: 90,
          maxY: 102,
        );
      case HealthTrendMetric.bloodPressure:
        return _MetricConfig(
          label: 'Blood Pressure',
          unit: 'mmHg',
          icon: Icons.speed,
          color: ClinicalColors.bloodPressure,
          currentValue: '118/76',
          avgValue: '119',
          rangeValue: '114 - 122',
          trendText: 'Normal',
          insightText:
              'Systolic and diastolic pressures remain in optimal cardiovascular range.',
          xLabels: _getXLabels(),
          spots: _getBpSpots(),
          minY: 90,
          maxY: 140,
        );
      case HealthTrendMetric.temperature:
        return _MetricConfig(
          label: 'Temperature',
          unit: '°F',
          icon: Icons.thermostat,
          color: ClinicalColors.warning,
          currentValue: '98.4',
          avgValue: '98.5',
          rangeValue: '97.9 - 98.7',
          trendText: 'Normal',
          insightText:
              'Circadian basal body temperature shows typical nocturnal reduction.',
          xLabels: _getXLabels(),
          spots: _getTempSpots(),
          minY: 96,
          maxY: 101,
        );
    }
  }

  _MetricConfig _getMetricConfig() {
    return _getConfigForMetric(_selectedMetric);
  }

  List<String> _getXLabels() {
    switch (_selectedPeriod) {
      case HealthTrendPeriod.today:
        return ['12A', '4A', '8A', '12P', '4P', '8P', 'Now'];
      case HealthTrendPeriod.week:
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case HealthTrendPeriod.month:
        return ['W1', 'W2', 'W3', 'W4'];
    }
  }

  List<FlSpot> _getHeartRateSpots() {
    if (widget.heartRateHistory.length >= 7) {
      final sub = widget.heartRateHistory.take(7).toList();
      return List.generate(
        sub.length,
        (i) => FlSpot(i.toDouble(), sub[i].toDouble()),
      );
    }
    // Representative smooth baseline curve
    return const [
      FlSpot(0, 68),
      FlSpot(1, 64),
      FlSpot(2, 75),
      FlSpot(3, 72),
      FlSpot(4, 78),
      FlSpot(5, 70),
      FlSpot(6, 72),
    ];
  }

  List<FlSpot> _getSpo2Spots() {
    return const [
      FlSpot(0, 98),
      FlSpot(1, 99),
      FlSpot(2, 97),
      FlSpot(3, 98),
      FlSpot(4, 98),
      FlSpot(5, 99),
      FlSpot(6, 98),
    ];
  }

  List<FlSpot> _getBpSpots() {
    return const [
      FlSpot(0, 116),
      FlSpot(1, 118),
      FlSpot(2, 122),
      FlSpot(3, 119),
      FlSpot(4, 117),
      FlSpot(5, 120),
      FlSpot(6, 118),
    ];
  }

  List<FlSpot> _getTempSpots() {
    return const [
      FlSpot(0, 98.1),
      FlSpot(1, 97.9),
      FlSpot(2, 98.4),
      FlSpot(3, 98.6),
      FlSpot(4, 98.5),
      FlSpot(5, 98.3),
      FlSpot(6, 98.4),
    ];
  }
}

class _MetricConfig {
  final String label;
  final String unit;
  final IconData icon;
  final Color color;
  final String currentValue;
  final String avgValue;
  final String rangeValue;
  final String trendText;
  final String insightText;
  final List<String> xLabels;
  final List<FlSpot> spots;
  final double minY;
  final double maxY;

  const _MetricConfig({
    required this.label,
    required this.unit,
    required this.icon,
    required this.color,
    required this.currentValue,
    required this.avgValue,
    required this.rangeValue,
    required this.trendText,
    required this.insightText,
    required this.xLabels,
    required this.spots,
    required this.minY,
    required this.maxY,
  });
}
