import '../entities/reminder_entity.dart';

abstract class RemindersRepository {
  Future<List<ReminderEntity>> getReminders();
  Future<ReminderEntity> addReminder(ReminderEntity reminder);
  Future<void> updateReminder(ReminderEntity reminder);
  Future<void> deleteReminder(String id);
}
