import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../health_log/presentation/bloc/health_log_bloc.dart';
import '../screens/bluetooth_scan_screen.dart';

class SmartwatchStatusBanner extends StatefulWidget {
  const SmartwatchStatusBanner({super.key});

  @override
  State<SmartwatchStatusBanner> createState() => _SmartwatchStatusBannerState();
}

class _SmartwatchStatusBannerState extends State<SmartwatchStatusBanner> {
  bool _isConnected = false;
  String _deviceName = 'Biometric Sensor';
  DateTime? _lastSyncedTime;
  bool _isSyncing = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _loadConnectionState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadConnectionState() async {
    final prefs = await SharedPreferences.getInstance();
    final connected = prefs.getBool('is_watch_connected') ?? false;
    final name = prefs.getString('connected_watch_name') ??
        prefs.getString('connected_watch_id') ??
        'Biometric Sensor';
    final lastSyncMillis = prefs.getInt('last_sync_timestamp');

    if (mounted) {
      setState(() {
        _isConnected = connected;
        _deviceName = name;
        _lastSyncedTime = lastSyncMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(lastSyncMillis)
            : null;
      });
    }
  }

  String _formatLastSynced() {
    if (_lastSyncedTime == null) return 'Pending first sync';
    final diff = DateTime.now().difference(_lastSyncedTime!);
    if (diff.inSeconds < 45) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _handleSyncNow() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    context.read<HealthLogBloc>().add(LoadHealthData());

    final prefs = await SharedPreferences.getInstance();
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('last_sync_timestamp', nowMillis);

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _lastSyncedTime = DateTime.fromMillisecondsSinceEpoch(nowMillis);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: ClinicalColors.healthy,
          behavior: SnackBarBehavior.floating,
          content: Text('Health telemetry synced successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleDisconnect() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_watch_connected', false);
    if (mounted) {
      setState(() {
        _isConnected = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: ClinicalColors.textSecondary,
          behavior: SnackBarBehavior.floating,
          content: Text('Watch disconnected'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ClinicalColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isConnected
              ? ClinicalColors.healthy.withValues(alpha: 0.25)
              : ClinicalColors.border,
        ),
        boxShadow: ClinicalColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Device Header Row ──────────────────────────────────────
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isConnected
                      ? ClinicalColors.healthyLight
                      : ClinicalColors.surfaceMuted,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isConnected
                        ? ClinicalColors.healthy.withValues(alpha: 0.3)
                        : ClinicalColors.borderSubtle,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.watch,
                    size: 22,
                    color: _isConnected
                        ? ClinicalColors.healthy
                        : ClinicalColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isConnected
                                ? ClinicalColors.healthy
                                : ClinicalColors.textTertiary,
                            boxShadow: _isConnected
                                ? [
                                    BoxShadow(
                                      color: ClinicalColors.healthy
                                          .withValues(alpha: 0.5),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isConnected ? 'WATCH CONNECTED' : 'WATCH DISCONNECTED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: _isConnected
                                ? ClinicalColors.healthy
                                : ClinicalColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isConnected ? _deviceName : 'No Watch Paired',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ClinicalColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'LAST SYNCED',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: ClinicalColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatLastSynced(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ClinicalColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: ClinicalColors.borderSubtle),
          const SizedBox(height: 12),

          // ── Actions Row ───────────────────────────────────────────
          if (_isConnected)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ClinicalColors.surfaceMuted,
                      foregroundColor: ClinicalColors.textPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: ClinicalColors.border),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: _isSyncing ? null : _handleSyncNow,
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ClinicalColors.heart,
                            ),
                          )
                        : const Icon(Icons.sync, size: 16),
                    label: Text(
                      _isSyncing ? 'Syncing...' : 'Sync Now',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ClinicalColors.textSecondary,
                      side: const BorderSide(color: ClinicalColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: _handleDisconnect,
                    icon: const Icon(Icons.link_off, size: 16),
                    label: const Text(
                      'Disconnect',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ClinicalColors.heart,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BluetoothScanScreen(),
                    ),
                  );
                  _loadConnectionState();
                },
                icon: const Icon(Icons.bluetooth_searching, size: 18),
                label: const Text(
                  'Connect Device',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
