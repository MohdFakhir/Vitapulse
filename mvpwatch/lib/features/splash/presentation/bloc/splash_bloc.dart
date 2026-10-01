import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object> get props => [];
}

class SplashStarted extends SplashEvent {}

abstract class SplashState extends Equatable {
  const SplashState();
  
  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}
class SplashLoading extends SplashState {}
class SplashNavigateToLogin extends SplashState {}
class SplashNavigateToHome extends SplashState {}

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthRepository _authRepository;

  SplashBloc({required AuthRepository authRepository}) 
    : _authRepository = authRepository,
      super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  Future<void> _onSplashStarted(SplashStarted event, Emitter<SplashState> emit) async {
    emit(SplashLoading());
    
    // Simulate initialization time and let the animation play
    await Future.delayed(const Duration(seconds: 3));
    
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(SplashNavigateToHome());
      } else {
        emit(SplashNavigateToLogin());
      }
    } catch (_) {
      emit(SplashNavigateToLogin());
    }
  }
}
