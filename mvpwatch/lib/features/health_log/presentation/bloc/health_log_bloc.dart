import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/health_log_entity.dart';
import '../../domain/repositories/health_log_repository.dart';

// Events
abstract class HealthLogEvent extends Equatable {
  const HealthLogEvent();
  @override
  List<Object?> get props => [];
}

class LoadHealthData extends HealthLogEvent {}
class AddWaterEvent extends HealthLogEvent {
  final double liters;
  const AddWaterEvent(this.liters);
  @override
  List<Object?> get props => [liters];
}
class LoadHealthNotes extends HealthLogEvent {}
class AddHealthNoteEvent extends HealthLogEvent {
  final String note;
  const AddHealthNoteEvent(this.note);
  @override
  List<Object?> get props => [note];
}
class DeleteHealthNoteEvent extends HealthLogEvent {
  final String id;
  const DeleteHealthNoteEvent(this.id);
  @override
  List<Object?> get props => [id];
}

// States
abstract class HealthLogState extends Equatable {
  const HealthLogState();
  @override
  List<Object?> get props => [];
}

class HealthLogInitial extends HealthLogState {}
class HealthLogLoading extends HealthLogState {}
class HealthLogLoaded extends HealthLogState {
  final HealthLogData data;
  final List<HealthNote> notes;
  const HealthLogLoaded(this.data, this.notes);

  @override
  List<Object?> get props => [data, notes];

  HealthLogLoaded copyWith({
    HealthLogData? data,
    List<HealthNote>? notes,
  }) {
    return HealthLogLoaded(
      data ?? this.data,
      notes ?? this.notes,
    );
  }
}
class HealthLogError extends HealthLogState {
  final String message;
  const HealthLogError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class HealthLogBloc extends Bloc<HealthLogEvent, HealthLogState> {
  final HealthLogRepository _repository;

  HealthLogBloc({required HealthLogRepository repository}) 
    : _repository = repository,
      super(HealthLogInitial()) {
    on<LoadHealthData>(_onLoadHealthData);
    on<AddWaterEvent>(_onAddWater);
    on<LoadHealthNotes>(_onLoadHealthNotes);
    on<AddHealthNoteEvent>(_onAddHealthNote);
    on<DeleteHealthNoteEvent>(_onDeleteHealthNote);
  }

  Future<void> _onLoadHealthData(LoadHealthData event, Emitter<HealthLogState> emit) async {
    emit(HealthLogLoading());
    try {
      final data = await _repository.getDailyHealthData();
      final notes = await _repository.getHealthNotes();
      emit(HealthLogLoaded(data, notes));
    } catch (e) {
      emit(HealthLogError('Failed to load health data: $e'));
    }
  }

  Future<void> _onAddWater(AddWaterEvent event, Emitter<HealthLogState> emit) async {
    if (state is HealthLogLoaded) {
      try {
        await _repository.addWaterIntake(event.liters);
        // Refresh data
        final data = await _repository.getDailyHealthData();
        emit((state as HealthLogLoaded).copyWith(data: data));
      } catch (e) {
        emit(HealthLogError('Failed to add water: $e'));
      }
    }
  }

  Future<void> _onLoadHealthNotes(LoadHealthNotes event, Emitter<HealthLogState> emit) async {
    if (state is HealthLogLoaded) {
      try {
        final notes = await _repository.getHealthNotes();
        emit((state as HealthLogLoaded).copyWith(notes: notes));
      } catch (e) {
        emit(HealthLogError('Failed to load notes: $e'));
      }
    }
  }

  Future<void> _onAddHealthNote(AddHealthNoteEvent event, Emitter<HealthLogState> emit) async {
    if (state is HealthLogLoaded) {
      try {
        await _repository.addHealthNote(event.note);
        final notes = await _repository.getHealthNotes();
        emit((state as HealthLogLoaded).copyWith(notes: notes));
      } catch (e) {
        emit(HealthLogError('Failed to add note: $e'));
      }
    }
  }

  Future<void> _onDeleteHealthNote(DeleteHealthNoteEvent event, Emitter<HealthLogState> emit) async {
    if (state is HealthLogLoaded) {
      try {
        await _repository.deleteHealthNote(event.id);
        final notes = await _repository.getHealthNotes();
        emit((state as HealthLogLoaded).copyWith(notes: notes));
      } catch (e) {
        emit(HealthLogError('Failed to delete note: $e'));
      }
    }
  }
}
