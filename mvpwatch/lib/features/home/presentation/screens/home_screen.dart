import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../health_log/presentation/bloc/health_log_bloc.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../reminders/presentation/screens/reminders_screen.dart';
import 'settings_screen.dart';
import 'bluetooth_scan_screen.dart';
import 'health_metric_detail_screen.dart';
import 'health_history_screen.dart';

// Clinical Biometric Components
import '../widgets/hero_health_card.dart';
import '../widgets/body_status_interactive_section.dart';
import '../widgets/health_trends_section.dart';
import '../widgets/smartwatch_status_banner.dart';
import '../widgets/heart_rate_section.dart';
import '../widgets/oxygen_spo2_section.dart';
import '../widgets/blood_pressure_section.dart';
import '../widgets/breathing_respiration_section.dart';
import '../widgets/sleep_recovery_section.dart';
import '../widgets/daily_health_overview.dart';
import '../widgets/clinical_quick_actions.dart';
import '../widgets/clinical_notifications_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static bool _hasShownBluetoothPopupThisSession = false;
  bool _isWatchConnected = false;
  String _watchName = 'Biometric Sensor';
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<HealthLogBloc>().add(LoadHealthData());
    _loadDeviceConnectionState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBluetoothConnection();
    });
  }

  Future<void> _loadDeviceConnectionState() async {
    final prefs = await SharedPreferences.getInstance();
    final isConnected = prefs.getBool('is_watch_connected') ?? false;
    final name = prefs.getString('connected_watch_name') ??
        prefs.getString('connected_watch_id') ??
        'Biometric Sensor';

    if (mounted) {
      setState(() {
        _isWatchConnected = isConnected;
        _watchName = name;
      });
    }
  }

  Future<void> _checkBluetoothConnection() async {
    if (_hasShownBluetoothPopupThisSession) return;

    final prefs = await SharedPreferences.getInstance();
    final isConnected = prefs.getBool('is_watch_connected') ?? false;

    if (!isConnected && mounted) {
      _hasShownBluetoothPopupThisSession = true;
      _showBluetoothPopup();
    }
  }

  void _showBluetoothPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ClinicalColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ClinicalColors.heartLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.watch, color: ClinicalColors.heart, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Connect Smartwatch',
                style: TextStyle(
                  color: ClinicalColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: const Text(
            'Pair your wearable sensor to activate continuous real-time heart rate, sleep architecture, and circulation telemetry.',
            style: TextStyle(color: ClinicalColors.textSecondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Maybe Later',
                style: TextStyle(color: ClinicalColors.textTertiary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ClinicalColors.heart,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BluetoothScanScreen()),
                );
                _loadDeviceConnectionState();
              },
              child: const Text('Pair Device'),
            ),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    return '$dayName, $monthName ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      },
      child: Scaffold(
        backgroundColor: ClinicalColors.background,
        appBar: _buildClinicalAppBar(context),
        body: SafeArea(
          child: BlocBuilder<HealthLogBloc, HealthLogState>(
            builder: (context, state) {
              if (state is HealthLogLoading || state is HealthLogInitial) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: ClinicalColors.heart),
                      SizedBox(height: 16),
                      Text(
                        'Calibrating biosignal telemetry...',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ClinicalColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is HealthLogError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 48,
                          color: ClinicalColors.warning,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          style: const TextStyle(
                            color: ClinicalColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ClinicalColors.heart,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => context
                              .read<HealthLogBloc>()
                              .add(LoadHealthData()),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry Telemetry Sync'),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is HealthLogLoaded) {
                final data = state.data;

                return RefreshIndicator(
                  color: ClinicalColors.heart,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    context.read<HealthLogBloc>().add(LoadHealthData());
                    await _loadDeviceConnectionState();
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 920;

                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 32 : 18,
                          vertical: 16,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1320),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Top Hero Greeting & Date/Status Row
                                _buildTopHeaderBanner(),

                                const SizedBox(height: 18),

                                // Main Responsive Dashboard Content
                                isWide
                                    ? _buildWideDashboard(data)
                                    : _buildStackedDashboard(data),

                                // Bottom padding for floating navigation pill
                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        bottomNavigationBar: _buildFloatingPillNavigation(context),
      ),
    );
  }

  /// ─── Top Header Greeting & Date Selector ──────────────────────────────────
  Widget _buildTopHeaderBanner() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String userName = 'Test';
        if (state is AuthAuthenticated) {
          final first = state.user.name.split(' ').first;
          if (first.isNotEmpty) userName = first;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getGreeting()}, $userName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: ClinicalColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        "Here's your health overview",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: ClinicalColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status Dot
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isWatchConnected
                              ? ClinicalColors.healthy
                              : ClinicalColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isWatchConnected ? 'Live' : 'Standby',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _isWatchConnected
                              ? ClinicalColors.healthy
                              : ClinicalColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Date/Time selector pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: ClinicalColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ClinicalColors.border),
                  boxShadow: ClinicalColors.cardShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: ClinicalColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getFormattedDate(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ClinicalColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ─── Narrow / Mobile Stacked Dashboard Layout ─────────────────────────────
  Widget _buildStackedDashboard(dynamic data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Hero Health Card (with 3D Heart, 72 BPM, optimal status, ECG, stats)
        HeroHealthCard(
          heartRate: data.heartRate,
          history: data.heartRateHistory,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HealthMetricDetailScreen(
                  initialMetric: MetricType.heartRate,
                  currentHeartRate: data.heartRate,
                  heartRateHistory: data.heartRateHistory,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 18),

        // 2. Wearable Smartwatch Connection Banner
        const SmartwatchStatusBanner(),

        const SizedBox(height: 18),

        // 3. Clinical Quick Actions (Notes, Reminders, Sync Watch, Profile)
        const ClinicalQuickActions(),

        const SizedBox(height: 20),

        // 4. Prominent Live Heart Rate Section
        HeartRateSection(
          heartRate: data.heartRate,
          history: data.heartRateHistory,
        ),

        const SizedBox(height: 20),

        // 5. Dedicated Blood Oxygen Section (SpO₂)
        const OxygenSpo2Section(
          spo2Percentage: null,
        ),

        const SizedBox(height: 20),

        // 6. Dedicated Blood Pressure Section (SYS / DIA)
        const BloodPressureSection(
          systolic: null,
          diastolic: null,
        ),

        const SizedBox(height: 20),

        // 7. Interactive Body Status / Anatomy Section
        BodyStatusInteractiveSection(
          heartRate: data.heartRate,
          steps: data.steps,
          sleepHours: data.sleepHours,
        ),

        const SizedBox(height: 20),

        // 8. Health Trends Section (Today / 7 Days / 30 Days)
        HealthTrendsSection(
          currentHeartRate: data.heartRate,
          heartRateHistory: data.heartRateHistory,
        ),

        const SizedBox(height: 20),

        // 9. Breathing & Respiration Section
        const BreathingRespirationSection(
          respirationRate: null,
        ),

        const SizedBox(height: 20),

        // 10. Sleep & Recovery Architecture Section
        SleepRecoverySection(
          sleepHours: data.sleepHours,
        ),

        const SizedBox(height: 20),

        // 11. Daily Supporting Biometric & Activity Log
        DailyHealthOverview(
          steps: data.steps,
          stepGoal: data.stepGoal,
          calories: data.calories,
          waterIntake: data.waterIntake,
          waterGoal: data.waterGoal,
          runningDistance: data.runningDistance,
          onAddWater: () {
            context.read<HealthLogBloc>().add(const AddWaterEvent(0.25));
          },
        ),
      ],
    );
  }

  /// ─── Wide / Desktop / Web Multi-Column Dashboard Layout ───────────────────
  Widget _buildWideDashboard(dynamic data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Hero Card, Heart Rate, Interactive Body Anatomy, Health Trends)
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HeroHealthCard(
                heartRate: data.heartRate,
                history: data.heartRateHistory,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HealthMetricDetailScreen(
                        initialMetric: MetricType.heartRate,
                        currentHeartRate: data.heartRate,
                        heartRateHistory: data.heartRateHistory,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              HeartRateSection(
                heartRate: data.heartRate,
                history: data.heartRateHistory,
              ),
              const SizedBox(height: 20),
              BodyStatusInteractiveSection(
                heartRate: data.heartRate,
                steps: data.steps,
                sleepHours: data.sleepHours,
              ),
              const SizedBox(height: 20),
              HealthTrendsSection(
                currentHeartRate: data.heartRate,
                heartRateHistory: data.heartRateHistory,
              ),
            ],
          ),
        ),

        const SizedBox(width: 24),

        // Right Column (Smartwatch, Quick Actions, SpO2, BP, Sleep, Activity)
        Expanded(
          flex: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SmartwatchStatusBanner(),
              const SizedBox(height: 18),
              const ClinicalQuickActions(),
              const SizedBox(height: 20),
              const OxygenSpo2Section(spo2Percentage: null),
              const SizedBox(height: 20),
              const BloodPressureSection(systolic: null, diastolic: null),
              const SizedBox(height: 20),
              const BreathingRespirationSection(respirationRate: null),
              const SizedBox(height: 20),
              SleepRecoverySection(sleepHours: data.sleepHours),
              const SizedBox(height: 20),
              DailyHealthOverview(
                steps: data.steps,
                stepGoal: data.stepGoal,
                calories: data.calories,
                waterIntake: data.waterIntake,
                waterGoal: data.waterGoal,
                runningDistance: data.runningDistance,
                onAddWater: () {
                  context.read<HealthLogBloc>().add(const AddWaterEvent(0.25));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ─── Top Clinical Header (Greeting, Avatar, Watch Status, Actions) ────────
  PreferredSizeWidget _buildClinicalAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ClinicalColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String userName = 'Biometric User';
          if (state is AuthAuthenticated) {
            userName = state.user.name.split(' ').first;
          }

          return Row(
            children: [
              // User Avatar
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ClinicalColors.surface,
                    border: Border.all(color: ClinicalColors.border),
                    boxShadow: ClinicalColors.cardShadow,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.favorite,
                      size: 19,
                      color: ClinicalColors.heart,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: ClinicalColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Watch Connection status pill in header
                  InkWell(
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BluetoothScanScreen(),
                        ),
                      );
                      _loadDeviceConnectionState();
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isWatchConnected
                              ? '● Connected ($_watchName)'
                              : '○ Watch Disconnected',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: _isWatchConnected
                                ? ClinicalColors.healthy
                                : ClinicalColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        // Notification bell with badge
        IconButton(
          tooltip: 'Notifications',
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: ClinicalColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: ClinicalColors.border),
                  boxShadow: ClinicalColors.cardShadow,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  size: 18,
                  color: ClinicalColors.textPrimary,
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: ClinicalColors.heart,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            ClinicalNotificationsModal.show(
              context,
              isWatchConnected: _isWatchConnected,
            );
          },
        ),

        // Sync Data Icon
        IconButton(
          tooltip: 'Sync Data',
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: ClinicalColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: ClinicalColors.border),
              boxShadow: ClinicalColors.cardShadow,
            ),
            child: const Icon(
              Icons.sync,
              size: 18,
              color: ClinicalColors.textSecondary,
            ),
          ),
          onPressed: () {
            context.read<HealthLogBloc>().add(LoadHealthData());
            _loadDeviceConnectionState();
          },
        ),

        // Settings Icon
        IconButton(
          tooltip: 'Settings',
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: ClinicalColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: ClinicalColors.border),
              boxShadow: ClinicalColors.cardShadow,
            ),
            child: const Icon(
              Icons.settings_outlined,
              size: 18,
              color: ClinicalColors.textSecondary,
            ),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// ─── Floating Pill-Style Bottom Navigation Bar ────────────────────────────
  Widget _buildFloatingPillNavigation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: ClinicalColors.surface,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: ClinicalColors.border.withValues(alpha: 0.8),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPillItem(
                    index: 0,
                    icon: Icons.home_rounded,
                    label: 'Home',
                    onTap: () => setState(() => _currentNavIndex = 0),
                  ),
                  _buildPillItem(
                    index: 1,
                    icon: Icons.favorite_rounded,
                    label: 'Health',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HealthMetricDetailScreen(),
                        ),
                      );
                    },
                  ),
                  _buildPillItem(
                    index: 2,
                    icon: Icons.history_rounded,
                    label: 'History',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HealthHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  _buildPillItem(
                    index: 3,
                    icon: Icons.notifications_active_rounded,
                    label: 'Reminders',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RemindersScreen(),
                        ),
                      );
                    },
                  ),
                  _buildPillItem(
                    index: 4,
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillItem({
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = _currentNavIndex == index;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? ClinicalColors.heartLight
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? ClinicalColors.heart
                  : ClinicalColors.textTertiary,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: ClinicalColors.heart,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
