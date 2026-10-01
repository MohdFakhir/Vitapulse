import 'package:equatable/equatable.dart';

class HealthLogData extends Equatable {
  final int heartRate;
  final List<int> heartRateHistory;
  final int steps;
  final int stepGoal;
  final double calories;
  final double waterIntake;
  final double waterGoal;
  final double sleepHours;
  final double runningDistance; // km

  const HealthLogData({
    required this.heartRate,
    required this.heartRateHistory,
    required this.steps,
    required this.stepGoal,
    required this.calories,
    required this.waterIntake,
    required this.waterGoal,
    required this.sleepHours,
    required this.runningDistance,
  });

  @override
  List<Object?> get props => [
        heartRate,
        heartRateHistory,
        steps,
        stepGoal,
        calories,
        waterIntake,
        waterGoal,
        sleepHours,
        runningDistance,
      ];

  HealthLogData copyWith({
    int? heartRate,
    List<int>? heartRateHistory,
    int? steps,
    int? stepGoal,
    double? calories,
    double? waterIntake,
    double? waterGoal,
    double? sleepHours,
    double? runningDistance,
  }) {
    return HealthLogData(
      heartRate: heartRate ?? this.heartRate,
      heartRateHistory: heartRateHistory ?? this.heartRateHistory,
      steps: steps ?? this.steps,
      stepGoal: stepGoal ?? this.stepGoal,
      calories: calories ?? this.calories,
      waterIntake: waterIntake ?? this.waterIntake,
      waterGoal: waterGoal ?? this.waterGoal,
      sleepHours: sleepHours ?? this.sleepHours,
      runningDistance: runningDistance ?? this.runningDistance,
    );
  }
}

class HealthNote extends Equatable {
  final String id;
  final String note;
  final DateTime timestamp;

  const HealthNote({
    required this.id,
    required this.note,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, note, timestamp];
}
