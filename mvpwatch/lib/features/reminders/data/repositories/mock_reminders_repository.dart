import '../../domain/entities/reminder_entity.dart';
import '../../domain/repositories/reminders_repository.dart';

class MockRemindersRepository implements RemindersRepository {
  final List<ReminderEntity> _reminders = [
    ReminderEntity(
      id: '1',
      title: 'Drink Water',
      time: DateTime.now().add(const Duration(minutes: 30)),
      repeatDaily: true,
    ),
    ReminderEntity(
      id: '2',
      title: 'Log Heart Rate',
      time: DateTime.now().add(const Duration(hours: 2)),
      repeatDaily: true,
    ),
  ];

  @override
  Future<List<ReminderEntity>> getReminders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_reminders);
  }

  @override
  Future<ReminderEntity> addReminder(ReminderEntity reminder) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newReminder = ReminderEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: reminder.title,
      time: reminder.time,
      repeatDaily: reminder.repeatDaily,
      isEnabled: reminder.isEnabled,
    );
    _reminders.add(newReminder);
    return newReminder;
  }

  @override
  Future<void> updateReminder(ReminderEntity reminder) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
    }
  }

  @override
  Future<void> deleteReminder(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _reminders.removeWhere((r) => r.id == id);
  }
}
