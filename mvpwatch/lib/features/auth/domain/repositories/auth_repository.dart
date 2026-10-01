import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  
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
  });

  Future<void> logout();
  
  Future<UserEntity?> getCurrentUser();
}
