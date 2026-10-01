import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity> getProfile();
  
  Future<UserEntity> updateProfile({
    required UserEntity currentProfile,
    String? name,
    double? weight,
    double? height,
    double? waterGoal,
  });
}
