import '../entities/health_log_entity.dart';

abstract class HealthLogRepository {
  Future<HealthLogData> getDailyHealthData();
  Future<void> addWaterIntake(double liters);
  
  // Notes
  Future<List<HealthNote>> getHealthNotes();
  Future<HealthNote> addHealthNote(String note);
  Future<void> deleteHealthNote(String id);
}

// TODO: Future Integration Interfaces (Mocked internally for now)
abstract class HeartRateRepository {
  // Connect to Health Connect / BLE
}
abstract class StepsRepository {}
abstract class SleepRepository {}
abstract class RunningRepository {}
abstract class WaterIntakeRepository {}
