import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  UserEntity? _currentUser;

  @override
  Future<UserEntity> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    if (email == 'test@test.com' && password == 'password') {
      _currentUser = _createMockUser();
      return _currentUser!;
    }

    // Default success for any other login in mock for easier testing
    _currentUser = _createMockUser(email: email);
    return _currentUser!;
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
    await Future.delayed(const Duration(seconds: 2));

    _currentUser = UserEntity(
      id: 'mock_id_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      dateOfBirth: dateOfBirth,
      age: age,
      weight: weight,
      height: height,
      waterGoal: waterGoal,
      gender: gender,
    );

    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _currentUser;
  }

  UserEntity _createMockUser({String email = 'test@test.com'}) {
    return UserEntity(
      id: 'mock_user_123',
      name: 'Test User',
      email: email,
      dateOfBirth: DateTime(1990, 1, 1),
      age: 36,
      weight: 75.0,
      height: 180.0,
      waterGoal: 3.5,
      gender: 'Male',
    );
  }
}
