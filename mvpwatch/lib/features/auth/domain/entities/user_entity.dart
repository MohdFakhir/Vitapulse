import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final DateTime dateOfBirth;
  final int age;
  final double weight;
  final double height;
  final double waterGoal;
  final String? gender;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.dateOfBirth,
    required this.age,
    required this.weight,
    required this.height,
    required this.waterGoal,
    this.gender,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        dateOfBirth,
        age,
        weight,
        height,
        waterGoal,
        gender,
      ];
}
