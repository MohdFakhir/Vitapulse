import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseClient get supabaseClient => Supabase.instance.client;

  @override
  Future<UserEntity> getProfile() async {
    // TODO: implement Supabase getProfile logic
    throw UnimplementedError('Will be implemented in tomorrow\'s phase');
  }

  @override
  Future<UserEntity> updateProfile({
    required UserEntity currentProfile,
    String? name,
    double? weight,
    double? height,
    double? waterGoal,
  }) async {
    // TODO: implement Supabase updateProfile logic
    throw UnimplementedError('Will be implemented in tomorrow\'s phase');
  }
}
