import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../screens/bluetooth_scan_screen.dart';

class ClinicalNotificationItem {
  final String id;
  final String title;
  final String description;
  final String timestamp;
  final IconData icon;
  final Color accentColor;
  final bool isRead;
  final VoidCallback? onTap;

  ClinicalNotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.accentColor,
    this.isRead = false,
    this.onTap,
  });
}

class ClinicalNotificationsModal extends StatefulWidget {
  final bool isWatchConnected;
  final VoidCallback? onPairDevice;

  const ClinicalNotificationsModal({
    super.key,
    required this.isWatchConnected,
    this.onPairDevice,
  });

  static void show(BuildContext context, {required bool isWatchConnected}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClinicalNotificationsModal(
        isWatchConnected: isWatchConnected,
        onPairDevice: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BluetoothScanScreen()),
          );
        },
      ),
    );
  }

  @override
  State<ClinicalNotificationsModal> createState() =>
      _ClinicalNotificationsModalState();
}

class _ClinicalNotificationsModalState
    extends State<ClinicalNotificationsModal> {
  late List<ClinicalNotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  void _initNotifications() {
    _notifications = [
      if (widget.isWatchConnected)
        ClinicalNotificationItem(
          id: 'watch_connected',
          title: 'Watch Connected',
          description:
              'Wearable telemetry link active. Heart rate and movement streaming.',
          timestamp: 'Just now',
          icon: Icons.watch,
          accentColor: ClinicalColors.healthy,
        )
      else
        ClinicalNotificationItem(
          id: 'watch_disconnected',
          title: 'Watch Disconnected',
          description:
              'Wearable sensor not detected. Tap to pair your device for continuous telemetry.',
          timestamp: 'Action required',
          icon: Icons.link_off,
          accentColor: ClinicalColors.warning,
          onTap: widget.onPairDevice,
        ),
      ClinicalNotificationItem(
        id: 'sync_success',
        title: 'Health Data Synced',
        description:
            'Biometric telemetry has synced successfully with local health storage.',
        timestamp: '10m ago',
        icon: Icons.sync_rounded,
        accentColor: ClinicalColors.oxygen,
      ),
      ClinicalNotificationItem(
        id: 'water_reminder',
        title: 'Hydration Target',
        description:
            'Maintain continuous hydration. Goal: 2.50L daily water intake.',
        timestamp: '1h ago',
        icon: Icons.water_drop_outlined,
        accentColor: ClinicalColors.oxygen,
      ),
      ClinicalNotificationItem(
        id: 'sleep_summary',
        title: 'Sleep Architecture Ready',
        description:
            'Nightly circadian cycle analyzed. Restorative phases recorded.',
        timestamp: '8h ago',
        icon: Icons.bedtime_outlined,
        accentColor: ClinicalColors.sleep,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: ClinicalColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: ClinicalColors.cardShadow,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle pill
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ClinicalColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 14),
              child: Row(
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
                          Icons.notifications_active_outlined,
                          color: ClinicalColors.heart,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOTIFICATIONS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: ClinicalColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Health & Device Telemetry Updates',
                            style: TextStyle(
                              fontSize: 11,
                              color: ClinicalColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: ClinicalColors.textSecondary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: ClinicalColors.borderSubtle),

            // List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                itemCount: _notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _notifications[index];
                  return InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ClinicalColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: ClinicalColors.borderSubtle),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: item.accentColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              color: item.accentColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: ClinicalColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      item.timestamp,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: ClinicalColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: ClinicalColors.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
