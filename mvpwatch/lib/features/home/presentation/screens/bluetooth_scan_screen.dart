import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';

class BluetoothScanScreen extends StatefulWidget {
  const BluetoothScanScreen({super.key});

  @override
  State<BluetoothScanScreen> createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  StreamSubscription? _scanResultsSub;
  StreamSubscription? _isScanningSub;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _startScan();
      _scanResultsSub = FlutterBluePlus.onScanResults.listen((results) {
        if (mounted) {
          setState(() {
            _scanResults = results;
          });
        }
      });

      _isScanningSub = FlutterBluePlus.isScanning.listen((state) {
        if (mounted) {
          setState(() {
            _isScanning = state;
          });
        }
      });
    }
  }

  void _startScan() async {
    if (kIsWeb) return;
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      debugPrint("Error starting scan: $e");
    }
  }

  void _stopScan() async {
    if (kIsWeb) return;
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      debugPrint("Error stopping scan: $e");
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    _stopScan();
    try {
      await device.connect(
        timeout: const Duration(seconds: 15),
        license: License.nonprofit,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_watch_connected', true);
      await prefs.setString('connected_watch_id', device.remoteId.str);
      final devName = device.advName.isNotEmpty ? device.advName : "Smartwatch";
      await prefs.setString('connected_watch_name', devName);
      await prefs.setInt('last_sync_timestamp', DateTime.now().millisecondsSinceEpoch);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: ClinicalColors.healthy,
            content: Text('Connected to $devName'),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: ClinicalColors.heart,
            content: Text('Failed to connect: $e'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scanResultsSub?.cancel();
    _isScanningSub?.cancel();
    _stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClinicalColors.background,
      appBar: AppBar(
        title: const Text(
          'Connect Smartwatch',
          style: TextStyle(
            color: ClinicalColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: ClinicalColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: ClinicalColors.textPrimary),
        actions: [
          if (!kIsWeb)
            if (_isScanning)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: ClinicalColors.heart,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.refresh, color: ClinicalColors.heart),
                onPressed: _startScan,
              ),
        ],
      ),
      body: SafeArea(
        child: kIsWeb
            ? Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: ClinicalColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: ClinicalColors.border),
                    boxShadow: ClinicalColors.cardShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ClinicalColors.heartLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.watch,
                          size: 40,
                          color: ClinicalColors.heart,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Wearable Sensor Pairing',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ClinicalColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Continuous Bluetooth Low Energy (BLE) sensor pairing is active on the mobile Android app. The Web console provides live health telemetry preview.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: ClinicalColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ClinicalColors.heart,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back to Health Dashboard'),
                      ),
                    ],
                  ),
                ),
              )
            : _scanResults.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bluetooth_searching,
                            size: 56,
                            color: ClinicalColors.textTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isScanning
                                ? 'Scanning for nearby wearables...'
                                : 'No devices found.\nTap refresh to search again.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: ClinicalColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(18),
                    itemCount: _scanResults.length,
                    itemBuilder: (context, index) {
                      final result = _scanResults[index];
                      final deviceName = result.device.advName.isNotEmpty
                          ? result.device.advName
                          : (result.advertisementData.advName.isNotEmpty
                              ? result.advertisementData.advName
                              : "Biometric Sensor");

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: ClinicalColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: ClinicalColors.border),
                          boxShadow: ClinicalColors.cardShadow,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: ClinicalColors.heartLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.watch,
                              color: ClinicalColors.heart,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            deviceName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: ClinicalColors.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            result.device.remoteId.str,
                            style: const TextStyle(
                              color: ClinicalColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _connectToDevice(result.device),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ClinicalColors.heart,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: const Text('Connect'),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
