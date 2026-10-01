import 'package:equatable/equatable.dart';

class ReminderEntity extends Equatable {
  final String id;
  final String title;
  final DateTime time;
  final bool repeatDaily;
  final bool isEnabled;

  const ReminderEntity({
    required this.id,
    required this.title,
    required this.time,
    this.repeatDaily = false,
    this.isEnabled = true,
  });

  @override
  List<Object?> get props => [id, title, time, repeatDaily, isEnabled];

  ReminderEntity copyWith({
    String? title,
    DateTime? time,
    bool? repeatDaily,
    bool? isEnabled,
  }) {
    return ReminderEntity(
      id: id,
      title: title ?? this.title,
      time: time ?? this.time,
      repeatDaily: repeatDaily ?? this.repeatDaily,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
