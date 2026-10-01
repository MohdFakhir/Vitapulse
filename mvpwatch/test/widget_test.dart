import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mvpwatch/features/home/presentation/widgets/heart_rate_section.dart';
import 'package:mvpwatch/features/home/presentation/widgets/smartwatch_status_banner.dart';
import 'package:mvpwatch/features/home/presentation/widgets/hero_health_card.dart';
import 'package:mvpwatch/features/home/presentation/widgets/health_trends_section.dart';
import 'package:mvpwatch/features/home/presentation/widgets/body_status_interactive_section.dart';
import 'package:mvpwatch/features/home/presentation/screens/health_metric_detail_screen.dart';
import 'package:mvpwatch/features/home/presentation/screens/health_history_screen.dart';
import 'package:mvpwatch/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:mvpwatch/features/splash/presentation/screens/splash_screen.dart';
import 'package:mvpwatch/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:mvpwatch/features/auth/presentation/bloc/auth_bloc.dart';

void main() {
  testWidgets('HeartRateSection displays waiting state correctly when heartRate is 0',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HeartRateSection(
            heartRate: 0,
            history: [],
          ),
        ),
      ),
    );

    expect(find.text('HEART RATE'), findsOneWidget);
    expect(find.text('--'), findsNWidgets(4));
    expect(find.text('STANDBY'), findsOneWidget);
  });

  testWidgets('SmartwatchStatusBanner renders correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SmartwatchStatusBanner(),
        ),
      ),
    );

    expect(find.byType(SmartwatchStatusBanner), findsOneWidget);
  });

  testWidgets('HeroHealthCard renders with 3D illustration and telemetry',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HeroHealthCard(
            heartRate: 74,
            history: [70, 72, 74],
          ),
        ),
      ),
    );

    expect(find.text('HEALTH OVERVIEW'), findsOneWidget);
    expect(find.text('74'), findsWidgets);
    expect(find.text('BPM'), findsWidgets);
  });

  testWidgets('BodyStatusInteractiveSection allows switching organ systems',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BodyStatusInteractiveSection(
              heartRate: 72,
              steps: 8000,
              sleepHours: 7.5,
            ),
          ),
        ),
      ),
    );

    expect(find.text('BODY STATUS & ANATOMY'), findsOneWidget);
    expect(find.text('Heart'), findsOneWidget);
    expect(find.text('Brain'), findsOneWidget);
    expect(find.text('Lungs'), findsOneWidget);

    // Tap on Brain organ tab
    await tester.tap(find.text('Brain'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('CEREBRAL SYSTEM'), findsOneWidget);
    expect(find.text('High Restorative'), findsOneWidget);
  });

  testWidgets('HealthTrendsSection renders with period and metric switcher',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: HealthTrendsSection(
              currentHeartRate: 72,
              heartRateHistory: [68, 70, 72],
            ),
          ),
        ),
      ),
    );

    expect(find.text('HEALTH TRENDS'), findsOneWidget);
    expect(find.text('7 Days'), findsOneWidget);
    expect(find.text('30 Days'), findsOneWidget);
  });

  testWidgets('HealthMetricDetailScreen renders deep-dive telemetry',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: HealthMetricDetailScreen(
          initialMetric: MetricType.heartRate,
          currentHeartRate: 72,
        ),
      ),
    );

    expect(find.text('Heart Rate Monitor'), findsOneWidget);
    expect(find.text('72'), findsOneWidget);
    expect(find.text('BPM'), findsWidgets);
    expect(find.text('Optimal Rhythm'), findsOneWidget);
  });

  testWidgets('HealthHistoryScreen renders chronological timeline entries',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HealthHistoryScreen(
          currentHeartRate: 72,
        ),
      ),
    );

    expect(find.text('Health History'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('9:30 PM'), findsOneWidget);
  });

  testWidgets('SplashScreen renders HaloHeart and Powered by Warmholes.ai branding',
      (WidgetTester tester) async {
    final authRepo = MockAuthRepository();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(authRepository: authRepo),
          ),
          BlocProvider<SplashBloc>(
            create: (_) => SplashBloc(authRepository: authRepo),
          ),
        ],
        child: const MaterialApp(
          home: SplashScreen(),
        ),
      ),
    );

    // Initial frame rendered
    await tester.pump();

    // Verify HaloHeart branding and attribution elements
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('HaloHeart'),
      ),
      findsOneWidget,
    );
    expect(find.text('Powered by'), findsOneWidget);
    expect(find.text('Warmholes.ai'), findsOneWidget);
    expect(find.text('INITIALIZING CARDIAC TELEMETRY'), findsOneWidget);

    // Let the 3-second splash timer elapse cleanly
    await tester.pump(const Duration(seconds: 4));
  });
}
