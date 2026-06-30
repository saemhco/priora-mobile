import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/shared/auth/data/auth_event.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoPulseAnimation;

  @override
  void initState() {
    super.initState();

    // Intro Animation (Fade in & Scale)
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    // Continuous Heartbeat/Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoPulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.12, end: 0.98)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.98, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
    ]).animate(_pulseController);

    _introController.forward().then((_) {
      _pulseController.repeat();
    });
    
    // Trigger restoration request or navigate if state is already resolved
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authBloc = context.read<AuthBloc>();
      final currentState = authBloc.state;
      if (currentState is AuthAuthenticated || currentState is AuthUnauthenticated) {
        _handleNavigation(currentState);
      } else {
        authBloc.add(const AuthRestoreSessionRequested());
      }
    });
  }

  void _handleNavigation(AuthState state) {
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      if (state is AuthAuthenticated) {
        if (!state.profileComplete) {
          context.go('/complete-profile');
        } else if (state.role == 'doctor') {
          context.go('/doctor');
        } else {
          context.go('/patient');
        }
      } else {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is AuthUnauthenticated) {
          _handleNavigation(state);
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A), // Deep Slate background
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Premium ambient glow background effect
              Positioned(
                child: Container(
                  width: size.width * 0.75,
                  height: size.width * 0.75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF0256C2).withValues(alpha: 0.25),
                        const Color(0xFF0256C2).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Animated content
              AnimatedBuilder(
                animation: Listenable.merge([_introController, _pulseController]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Pulse/Heartbeat Logo container
                          Transform.scale(
                            scale: _logoPulseAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0256C2).withValues(alpha: 0.2),
                                    blurRadius: 30,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    blurRadius: 15,
                                    spreadRadius: -4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: Color(0xFF0256C2),
                                size: 64,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Brand Typography
                          Text(
                            'Priora',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tu salud, nuestra prioridad',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 80),
                          
                          // Modern Dots Pulsing Loading Indicator
                          const _ThreeDotLoading(
                            color: Colors.white70,
                            size: 8.0,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThreeDotLoading extends StatefulWidget {
  final Color color;
  final double size;

  const _ThreeDotLoading({
    required this.color,
    required this.size,
  });

  @override
  State<_ThreeDotLoading> createState() => _ThreeDotLoadingState();
}

class _ThreeDotLoadingState extends State<_ThreeDotLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.25;
            final double value = math.sin((_controller.value * 2 * math.pi) - (delay * 2 * math.pi));
            final double scale = 0.5 + (0.5 * (value + 1.0) / 2.0);
            
            return Opacity(
              opacity: 0.4 + (0.6 * (value + 1.0) / 2.0),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
