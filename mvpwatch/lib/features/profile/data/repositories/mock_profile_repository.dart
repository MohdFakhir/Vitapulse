import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  final AuthRepository _authRepository;
  
  MockProfileRepository(this._authRepository);

  @override
  Future<UserEntity> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user;
  }

  @override
  Future<UserEntity> updateProfile({
    required UserEntity currentProfile,
    String? name,
    double? weight,
    double? height,
    double? waterGoal,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would call Supabase to update the row,
    // then return the updated row. For mock, we just return a new entity.
    return UserEntity(
      id: currentProfile.id,
      name: name ?? currentProfile.name,
      email: currentProfile.email,
      dateOfBirth: currentProfile.dateOfBirth,
      age: currentProfile.age,
      weight: weight ?? currentProfile.weight,
      height: height ?? currentProfile.height,
      waterGoal: waterGoal ?? currentProfile.waterGoal,
      gender: currentProfile.gender,
    );
  }
}
