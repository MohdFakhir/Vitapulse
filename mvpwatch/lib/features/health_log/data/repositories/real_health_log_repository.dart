import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import '../../domain/entities/health_log_entity.dart';
import '../../domain/repositories/health_log_repository.dart';

class RealHealthLogRepository implements HealthLogRepository {
  Health? _healthInstance;
  Health get _health => _healthInstance ??= Health();
  
  // Local state for manually logged items
  double _waterIntake = 0.0;
  final List<HealthNote> _notes = [];
  bool _isAuthorized = false;

  final types = [
    HealthDataType.HEART_RATE,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.DISTANCE_WALKING_RUNNING,
  ];

  Future<void> _authorize() async {
    if (kIsWeb) {
      _isAuthorized = false;
      return;
    }
    if (_isAuthorized) return;
    
    try {
      final permissions = types.map((e) => HealthDataAccess.READ).toList();
      bool? hasPermissions = await _health.hasPermissions(types, permissions: permissions);
      if (hasPermissions != true) {
        bool authorized = await _health.requestAuthorization(types, permissions: permissions);
        _isAuthorized = authorized;
      } else {
        _isAuthorized = true;
      }
    } catch (e) {
      debugPrint('Health authorization error: $e');
      _isAuthorized = false;
    }
  }

  @override
  Future<HealthLogData> getDailyHealthData() async {
    if (kIsWeb) {
      // Safe preview state on Web without invoking native Health Connect / HealthKit
      return HealthLogData(
        heartRate: 0,
        heartRateHistory: const [],
        steps: 0,
        stepGoal: 10000,
        calories: 0.0,
        waterIntake: _waterIntake,
        waterGoal: 2.5,
        sleepHours: 0.0,
        runningDistance: 0.0,
      );
    }

    try {
      await _authorize();

      if (!_isAuthorized) {
        // Return empty/zero data if not authorized
        return HealthLogData(
          heartRate: 0,
          heartRateHistory: const [],
          steps: 0,
          stepGoal: 10000,
          calories: 0.0,
          waterIntake: _waterIntake,
          waterGoal: 2.5,
          sleepHours: 0.0,
          runningDistance: 0.0,
        );
      }

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    
    // Fetch steps
    int? steps = await _health.getTotalStepsInInterval(midnight, now);
    
    // Fetch other data for today
    List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
      startTime: midnight,
      endTime: now,
      types: types,
    );

    // Process data
    int heartRate = 0;
    List<int> hrHistory = [];
    double calories = 0;
    double sleepHours = 0;
    double distance = 0;

    for (var point in healthData) {
      if (point.type == HealthDataType.HEART_RATE) {
        final val = (point.value as NumericHealthValue).numericValue.toInt();
        heartRate = val; // gets the last one essentially, though they are ordered
        hrHistory.add(val);
      } else if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
        calories += (point.value as NumericHealthValue).numericValue.toDouble();
      } else if (point.type == HealthDataType.SLEEP_ASLEEP) {
        // usually in minutes
        final sleepMins = (point.value as NumericHealthValue).numericValue.toDouble();
        sleepHours += sleepMins / 60.0;
      } else if (point.type == HealthDataType.DISTANCE_WALKING_RUNNING) {
        // typically in meters
        distance += (point.value as NumericHealthValue).numericValue.toDouble() / 1000.0; 
      }
    }

    return HealthLogData(
      heartRate: heartRate,
      heartRateHistory: hrHistory.length > 10 ? hrHistory.sublist(hrHistory.length - 10) : hrHistory, // keep last 10
      steps: steps ?? 0,
      stepGoal: 10000,
      calories: calories,
      waterIntake: _waterIntake,
      waterGoal: 2.5,
      sleepHours: double.parse(sleepHours.toStringAsFixed(1)),
      runningDistance: double.parse(distance.toStringAsFixed(2)),
    );
  } catch (e) {
    debugPrint('Error loading health data: $e');
    return HealthLogData(
      heartRate: 0,
      heartRateHistory: const [],
      steps: 0,
      stepGoal: 10000,
      calories: 0.0,
      waterIntake: _waterIntake,
      waterGoal: 2.5,
      sleepHours: 0.0,
      runningDistance: 0.0,
    );
  }
}

  @override
  Future<void> addWaterIntake(double liters) async {
    _waterIntake += liters;
  }

  @override
  Future<List<HealthNote>> getHealthNotes() async {
    return List.unmodifiable(_notes);
  }

  @override
  Future<HealthNote> addHealthNote(String note) async {
    final newNote = HealthNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      note: note,
      timestamp: DateTime.now(),
    );
    _notes.insert(0, newNote);
    return newNote;
  }

  @override
  Future<void> deleteHealthNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
  }
}
