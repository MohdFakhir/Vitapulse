import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/health_log_entity.dart';
import '../../domain/repositories/health_log_repository.dart';

class SupabaseHealthLogRepository implements HealthLogRepository {
  SupabaseClient get supabaseClient => Supabase.instance.client;

  @override
  Future<HealthLogData> getDailyHealthData() async {
    // TODO: implement Supabase getDailyHealthData logic
    throw UnimplementedError('Will be implemented in tomorrow\'s phase');
  }

  @override
  Future<void> addWaterIntake(double liters) async {
    // TODO: implement Supabase addWaterIntake logic
    throw UnimplementedError('Will be implemented in tomorrow\'s phase');
  }

  @override
  Future<List<HealthNote>> getHealthNotes() async {
    // TODO: implement Supabase getHealthNotes logic
    throw UnimplementedError('Will be implemented in tomorrow\'s phase');
  }

  @override
  Future<HealthNote> addHealthNote(String note) async {
    // TODO: implement Supabase addHealthNote logic
    throw UnimplementedError('Will be implemented in tomorrow\'s phase');
  }

  @override
  Future<void> deleteHealthNote(String id) async {
    // TODO: implement Supabase deleteHealthNote logic
    throw UnimplementedError('Will be implemented in tomorrow\'s phase');
  }
}
