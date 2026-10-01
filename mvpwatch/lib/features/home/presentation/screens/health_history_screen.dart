import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HealthHistoryScreen extends StatefulWidget {
  final int currentHeartRate;
  final List<int> heartRateHistory;

  const HealthHistoryScreen({
    super.key,
    this.currentHeartRate = 72,
    this.heartRateHistory = const [],
  });

  @override
  State<HealthHistoryScreen> createState() => _HealthHistoryScreenState();
}

class _HealthHistoryScreenState extends State<HealthHistoryScreen> {
  String _selectedFilter = 'All Records';

  final List<String> _filters = [
    'All Records',
    'Heart Rate',
    'Blood Oxygen',
    'Blood Pressure',
  ];

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Health History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: ClinicalColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, size: 20),
            color: ClinicalColors.textSecondary,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, size: 20),
            color: ClinicalColors.textSecondary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Downloading CSV medical history...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Chips
                  _buildFilterChips(),

                  const SizedBox(height: 20),

                  // Today Section
                  _buildDateHeader('Today', 'Sep 26, 2026'),
                  const SizedBox(height: 12),
                  _buildHistoryCard(
                    time: '9:30 PM',
                    device: 'Apple Watch Ultra',
                    status: 'Normal',
                    statusColor: ClinicalColors.healthy,
                    heartRate: widget.currentHeartRate > 0
                        ? '${widget.currentHeartRate} BPM'
                        : '72 BPM',
                    spo2: '98%',
                    bloodPressure: '118/76 mmHg',
                    respiration: '15 br/min',
                  ),
                  const SizedBox(height: 12),
                  _buildHistoryCard(
                    time: '3:15 PM',
                    device: 'Apple Watch Ultra',
                    status: 'Optimal',
                    statusColor: ClinicalColors.healthy,
                    heartRate: '68 BPM',
                    spo2: '99%',
                    bloodPressure: '116/74 mmHg',
                    respiration: '14 br/min',
                  ),
                  const SizedBox(height: 12),
                  _buildHistoryCard(
                    time: '8:45 AM',
                    device: 'Smartwatch Telemetry',
                    status: 'Resting',
                    statusColor: ClinicalColors.sleep,
                    heartRate: '61 BPM',
                    spo2: '98%',
                    bloodPressure: '112/72 mmHg',
                    respiration: '13 br/min',
                  ),

                  const SizedBox(height: 24),

                  // Yesterday Section
                  _buildDateHeader('Yesterday', 'Sep 25, 2026'),
                  const SizedBox(height: 12),
                  _buildHistoryCard(
                    time: '10:15 PM',
                    device: 'Apple Watch Ultra',
                    status: 'Normal',
                    statusColor: ClinicalColors.healthy,
                    heartRate: '70 BPM',
                    spo2: '98%',
                    bloodPressure: '120/78 mmHg',
                    respiration: '16 br/min',
                  ),
                  const SizedBox(height: 12),
                  _buildHistoryCard(
                    time: '4:20 PM',
                    device: 'Smartwatch Telemetry',
                    status: 'Active',
                    statusColor: ClinicalColors.heart,
                    heartRate: '88 BPM',
                    spo2: '97%',
                    bloodPressure: '124/80 mmHg',
                    respiration: '18 br/min',
                  ),
                  const SizedBox(height: 12),
                  _buildHistoryCard(
                    time: '7:30 AM',
                    device: 'Apple Watch Ultra',
                    status: 'Resting',
                    statusColor: ClinicalColors.sleep,
                    heartRate: '59 BPM',
                    spo2: '99%',
                    bloodPressure: '110/70 mmHg',
                    respiration: '14 br/min',
                  ),

                  const SizedBox(height: 24),

                  // Earlier This Week
                  _buildDateHeader('Sep 24, 2026', 'Tuesday'),
                  const SizedBox(height: 12),
                  _buildHistoryCard(
                    time: '9:00 PM',
                    device: 'Apple Watch Ultra',
                    status: 'Normal',
                    statusColor: ClinicalColors.healthy,
                    heartRate: '73 BPM',
                    spo2: '98%',
                    bloodPressure: '119/76 mmHg',
                    respiration: '15 br/min',
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? ClinicalColors.heart
                      : ClinicalColors.textSecondary,
                ),
              ),
              selected: isSelected,
              selectedColor: ClinicalColors.heartLight,
              backgroundColor: ClinicalColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected
                      ? ClinicalColors.heart
                      : ClinicalColors.border,
                ),
              ),
              showCheckmark: false,
              onSelected: (selected) {
                if (selected) setState(() => _selectedFilter = filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateHeader(String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: ClinicalColors.heart,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: ClinicalColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '•  $subtitle',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ClinicalColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard({
    required String time,
    required String device,
    required String status,
    required Color statusColor,
    required String heartRate,
    required String spo2,
    required String bloodPressure,
    required String respiration,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ClinicalColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ClinicalColors.border),
        boxShadow: ClinicalColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time & Device & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ClinicalColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.schedule,
                      size: 14,
                      color: ClinicalColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ClinicalColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• $device',
                    style: const TextStyle(
                      fontSize: 11,
                      color: ClinicalColors.textTertiary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Metrics Grid (HR, SpO2, BP, Resp)
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Heart Rate',
                  value: heartRate,
                  icon: Icons.favorite,
                  color: ClinicalColors.heart,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'SpO₂',
                  value: spo2,
                  icon: Icons.air,
                  color: ClinicalColors.oxygen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Blood Pressure',
                  value: bloodPressure,
                  icon: Icons.speed,
                  color: ClinicalColors.bloodPressure,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'Respiration',
                  value: respiration,
                  icon: Icons.waves,
                  color: ClinicalColors.sleep,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ClinicalColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ClinicalColors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: ClinicalColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: ClinicalColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
