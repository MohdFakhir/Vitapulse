import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/utils/notification_service.dart';
import 'core/constants/supabase_constants.dart';
import 'features/auth/data/repositories/mock_auth_repository.dart';
import 'features/auth/data/repositories/supabase_auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/profile/data/repositories/mock_profile_repository.dart';
import 'features/profile/data/repositories/supabase_profile_repository.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/splash/presentation/bloc/splash_bloc.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/health_log/data/repositories/real_health_log_repository.dart';
import 'features/health_log/data/repositories/supabase_health_log_repository.dart';
import 'features/health_log/presentation/bloc/health_log_bloc.dart';
import 'features/reminders/data/repositories/mock_reminders_repository.dart';
import 'features/reminders/presentation/bloc/reminders_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (SupabaseConstants.supabaseUrl.startsWith('http')) {
    try {
      await Supabase.initialize(
        url: SupabaseConstants.supabaseUrl,
        anonKey: SupabaseConstants.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase initialization bypassed: $e');
    }
  }

  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(FlexBeatApp(notificationService: notificationService));
}

class FlexBeatApp extends StatelessWidget {
  final NotificationService notificationService;

  const FlexBeatApp({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    final bool useSupabase = SupabaseConstants.supabaseUrl.startsWith('http');

    final authRepository = useSupabase
        ? SupabaseAuthRepository()
        : MockAuthRepository();

    final profileRepository = useSupabase
        ? SupabaseProfileRepository()
        : MockProfileRepository(
            authRepository as MockAuthRepository,
          ); // Will refactor tomorrow

    final healthLogRepository = useSupabase
        ? SupabaseHealthLogRepository()
        : RealHealthLogRepository();
    final remindersRepository = MockRemindersRepository();

    return MultiBlocProvider(
      providers: [
        // ── ThemeCubit — loaded first so theme is ready before any screen ──
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(authRepository: authRepository)..add(CheckAuthStatus()),
        ),
        BlocProvider<SplashBloc>(
          create: (context) => SplashBloc(authRepository: authRepository),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc()..add(LoadHomeData()),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) =>
              ProfileBloc(profileRepository: profileRepository),
        ),
        BlocProvider<HealthLogBloc>(
          create: (context) => HealthLogBloc(repository: healthLogRepository),
        ),
        BlocProvider<RemindersBloc>(
          create: (context) => RemindersBloc(
            repository: remindersRepository,
            notificationService: notificationService,
          ),
        ),
      ],

      // BlocBuilder listens to ThemeCubit and rebuilds MaterialApp when theme changes
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Flex Beat by Wormhole.ai',
            theme: AppTheme.lightTheme,       // used when themeMode == ThemeMode.light
            darkTheme: AppTheme.darkTheme,    // used when themeMode == ThemeMode.dark
            themeMode: themeMode,             // controlled by ThemeCubit
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }
}
