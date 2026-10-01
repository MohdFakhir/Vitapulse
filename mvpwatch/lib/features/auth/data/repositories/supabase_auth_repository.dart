import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseClient get supabaseClient => Supabase.instance.client;

  @override
  Future<UserEntity?> getCurrentUser() async {
    // TODO: implement Supabase getCurrentUser logic
    throw UnimplementedError('Will be implemented in tomorrow\'s phase');
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    // TODO: implement Supabase login logic
    throw UnimplementedError('Will be implemented in tomorrow\'s phase');
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required DateTime dateOfBirth,
    required int age,
    required double weight,
    required double height,
    required double waterGoal,
    String? gender,
  }) async {
    // TODO: implement Supabase register logic
    throw UnimplementedError('Will be implemented in tomorrow\'s phase');
  }

  @override
  Future<void> logout() async {
    // TODO: implement Supabase logout logic
    throw UnimplementedError('Will be implemented in tomorrow\'s phase');
  }
}
