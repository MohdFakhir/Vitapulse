import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/notification_service.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/repositories/reminders_repository.dart';

// Events
abstract class RemindersEvent extends Equatable {
  const RemindersEvent();
  @override
  List<Object?> get props => [];
}

class LoadReminders extends RemindersEvent {}

class AddReminder extends RemindersEvent {
  final ReminderEntity reminder;
  const AddReminder(this.reminder);
  @override
  List<Object?> get props => [reminder];
}

class ToggleReminder extends RemindersEvent {
  final ReminderEntity reminder;
  const ToggleReminder(this.reminder);
  @override
  List<Object?> get props => [reminder];
}

class DeleteReminder extends RemindersEvent {
  final String id;
  const DeleteReminder(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class RemindersState extends Equatable {
  const RemindersState();
  @override
  List<Object?> get props => [];
}

class RemindersInitial extends RemindersState {}
class RemindersLoading extends RemindersState {}
class RemindersLoaded extends RemindersState {
  final List<ReminderEntity> reminders;
  const RemindersLoaded(this.reminders);
  @override
  List<Object?> get props => [reminders];
}
class RemindersError extends RemindersState {
  final String message;
  const RemindersError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class RemindersBloc extends Bloc<RemindersEvent, RemindersState> {
  final RemindersRepository _repository;
  final NotificationService _notificationService;

  RemindersBloc({
    required RemindersRepository repository,
    required NotificationService notificationService,
  })  : _repository = repository,
        _notificationService = notificationService,
        super(RemindersInitial()) {
    on<LoadReminders>(_onLoadReminders);
    on<AddReminder>(_onAddReminder);
    on<ToggleReminder>(_onToggleReminder);
    on<DeleteReminder>(_onDeleteReminder);
  }

  Future<void> _onLoadReminders(LoadReminders event, Emitter<RemindersState> emit) async {
    emit(RemindersLoading());
    try {
      final reminders = await _repository.getReminders();
      emit(RemindersLoaded(reminders));
    } catch (e) {
      emit(RemindersError('Failed to load reminders: $e'));
    }
  }

  Future<void> _onAddReminder(AddReminder event, Emitter<RemindersState> emit) async {
    if (state is RemindersLoaded) {
      try {
        final newReminder = await _repository.addReminder(event.reminder);
        
        if (newReminder.isEnabled) {
          _scheduleNotification(newReminder);
        }

        final reminders = await _repository.getReminders();
        emit(RemindersLoaded(reminders));
      } catch (e) {
        emit(RemindersError('Failed to add reminder: $e'));
      }
    }
  }

  Future<void> _onToggleReminder(ToggleReminder event, Emitter<RemindersState> emit) async {
    if (state is RemindersLoaded) {
      try {
        final updated = event.reminder.copyWith(isEnabled: !event.reminder.isEnabled);
        await _repository.updateReminder(updated);
        
        if (updated.isEnabled) {
          _scheduleNotification(updated);
        } else {
          _notificationService.cancelReminder(updated.id.hashCode);
        }

        final reminders = await _repository.getReminders();
        emit(RemindersLoaded(reminders));
      } catch (e) {
        emit(RemindersError('Failed to toggle reminder: $e'));
      }
    }
  }

  Future<void> _onDeleteReminder(DeleteReminder event, Emitter<RemindersState> emit) async {
    if (state is RemindersLoaded) {
      try {
        await _repository.deleteReminder(event.id);
        _notificationService.cancelReminder(event.id.hashCode);
        
        final reminders = await _repository.getReminders();
        emit(RemindersLoaded(reminders));
      } catch (e) {
        emit(RemindersError('Failed to delete reminder: $e'));
      }
    }
  }

  void _scheduleNotification(ReminderEntity reminder) {
    _notificationService.scheduleReminder(
      id: reminder.id.hashCode,
      title: 'Flex Beat Reminder',
      body: reminder.title,
      scheduledTime: reminder.time,
      repeatDaily: reminder.repeatDaily,
    );
  }
}
