import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/splash_bloc.dart';
import '../widgets/wormhole_painter.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _heartbeatController;
  late AnimationController _haloController;
  late AnimationController _loadingProgressController;

  late Animation<double> _heartScaleAnimation;
  late Animation<double> _haloPulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Organic cardiac rhythm animation (lub-dub resting cadence ~1100ms)
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    _heartScaleAnimation = TweenSequence<double>([
      // Systole: First contraction (lub)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.045)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 15,
      ),
      // Slight rebound
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.045, end: 0.985)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 15,
      ),
      // Second ventricular pulse (dub)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.985, end: 1.025)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 15,
      ),
      // Diastole: Rest and return to baseline
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.025, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 20,
      ),
      // Resting diastole pause
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 35,
      ),
    ]).animate(_heartbeatController);

    // 2. Subtle halo breathing animation
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _haloPulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _haloController, curve: Curves.easeInOut),
    );

    // 3. Smooth minimal loading line progress
    _loadingProgressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Start splash logic
    context.read<SplashBloc>().add(SplashStarted());
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _haloController.dispose();
    _loadingProgressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state is SplashNavigateToLogin) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else if (state is SplashNavigateToHome) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF030508),
        body: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Deep premium dark background with soft radial cyan aura (NO dashed rings)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _haloPulseAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: HaloHeartAmbientPainter(
                      pulseValue: _haloPulseAnimation.value,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),

            // 2. Centered Content: Halo + Anatomical Heart + HaloHeart + Powered by Warmholes.ai
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ─── Glowing Halo & Realistic Anatomical Human Heart ────────
                        SizedBox(
                          width: 240,
                          height: 250,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Soft cyan volumetric glow directly behind the heart
                              AnimatedBuilder(
                                animation: _heartScaleAnimation,
                                builder: (context, child) {
                                  final glowScale = _heartScaleAnimation.value;
                                  return Container(
                                    width: 180 * glowScale,
                                    height: 180 * glowScale,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00E5FF).withValues(alpha: 0.18),
                                          blurRadius: 54,
                                          spreadRadius: 8,
                                        ),
                                        BoxShadow(
                                          color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                                          blurRadius: 36,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              // Realistic 3D Anatomical Human Heart (with organic cardiac pulse)
                              Positioned(
                                top: 38,
                                child: AnimatedBuilder(
                                  animation: _heartScaleAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _heartScaleAnimation.value,
                                      alignment: Alignment.center,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    width: 195,
                                    height: 195,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/haloheart_anatomical_heart.jpg',
                                        width: 195,
                                        height: 195,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/images/medical_heart_hero.jpg',
                                            width: 195,
                                            height: 195,
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, st) {
                                              return const Icon(
                                                Icons.favorite,
                                                size: 90,
                                                color: Color(0xFF00E5FF),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // ONE Single Elegant Glowing Halo Ring positioned directly above the heart
                              Positioned(
                                top: 18,
                                child: AnimatedBuilder(
                                  animation: _haloPulseAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: 0.98 + (_haloPulseAnimation.value * 0.04),
                                      alignment: Alignment.center,
                                      child: CustomPaint(
                                        size: const Size(120, 28),
                                        painter: GlowingHaloPainter(
                                          pulseValue: _haloPulseAnimation.value,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ─── HaloHeart Branding Title ──────────────────────────────
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              height: 1.0,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Halo',
                                style: TextStyle(
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Color(0x5500E5FF),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                              ),
                              TextSpan(
                                text: 'Heart',
                                style: const TextStyle(
                                  color: Color(0xFF00E5FF), // Electric cyan
                                  shadows: [
                                    Shadow(
                                      color: Color(0xFF00E5FF),
                                      blurRadius: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Subtle miniature ECG waveform line near title
                        AnimatedBuilder(
                          animation: _loadingProgressController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(110, 18),
                              painter: SubtleEcgPainter(
                                progress: _loadingProgressController.value,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        // ─── Powered by Warmholes.ai Attribution ───────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF080D18).withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.18),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Powered by',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.6,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(width: 7),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.asset(
                                  'assets/images/warmholes_logo.png',
                                  width: 17,
                                  height: 17,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.hub_outlined,
                                      size: 15,
                                      color: Color(0xFF00E5FF),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Warmholes.ai',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 36),

                        // ─── Minimal Loading Indicator: Thin Cyan Progress Line ─────
                        SizedBox(
                          width: 130,
                          height: 2.5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: AnimatedBuilder(
                              animation: _loadingProgressController,
                              builder: (context, child) {
                                return LinearProgressIndicator(
                                  backgroundColor: const Color(0xFF0F172A),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF00E5FF),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'INITIALIZING CARDIAC TELEMETRY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
