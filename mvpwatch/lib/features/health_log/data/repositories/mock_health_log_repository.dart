import '../../domain/entities/health_log_entity.dart';
import '../../domain/repositories/health_log_repository.dart';

class MockHealthLogRepository implements HealthLogRepository {
  HealthLogData _currentData = const HealthLogData(
    heartRate: 72,
    heartRateHistory: [68, 70, 75, 80, 72, 74, 72, 69, 71, 72],
    steps: 6450,
    stepGoal: 10000,
    calories: 1850.5,
    waterIntake: 1.5,
    waterGoal: 2.5,
    sleepHours: 7.2,
    runningDistance: 4.5,
  );

  final List<HealthNote> _notes = [
    HealthNote(
      id: '1',
      note: 'Felt a bit tired after the morning run.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    HealthNote(
      id: '2',
      note: 'Drank 2 glasses of water. Feeling hydrated.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  @override
  Future<HealthLogData> getDailyHealthData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _currentData;
  }

  @override
  Future<void> addWaterIntake(double liters) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentData = _currentData.copyWith(
      waterIntake: _currentData.waterIntake + liters,
    );
  }

  @override
  Future<List<HealthNote>> getHealthNotes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_notes);
  }

  @override
  Future<HealthNote> addHealthNote(String note) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newNote = HealthNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      note: note,
      timestamp: DateTime.now(),
    );
    _notes.insert(0, newNote); // add to top
    return newNote;
  }

  @override
  Future<void> deleteHealthNote(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _notes.removeWhere((note) => note.id == id);
  }
}
