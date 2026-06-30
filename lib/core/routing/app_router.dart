import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:priora/features/shared/auth/presentation/splash_screen.dart';
import 'package:priora/features/shared/onboarding/presentation/onboarding_screen.dart';
import 'package:priora/features/shared/auth/presentation/login_screen.dart';
import 'package:priora/features/shared/auth/presentation/register_screen.dart';
import 'package:priora/features/shared/auth/presentation/forgot_password_screen.dart';
import 'package:priora/features/shared/auth/presentation/complete_profile_screen.dart';
import 'package:priora/features/patient/navigation/presentation/patient_navigation_screen.dart';
import 'package:priora/features/doctor/home/presentation/doctor_home_screen.dart';
import 'package:priora/features/patient/profile/presentation/edit_profile_screen.dart';
import 'package:priora/features/patient/profile/presentation/map_picker_screen.dart';
import 'package:priora/features/patient/home/presentation/notifications_screen.dart';

CustomTransitionPage<T> _buildTransitionPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.04), // Sutil slide up
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        ),
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => _buildTransitionPage(
        key: state.pageKey,
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _buildTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => _buildTransitionPage(
        key: state.pageKey,
        child: const RegisterScreen(),
      ),
    ),
    GoRoute(
      path: '/forgot-password',
      pageBuilder: (context, state) => _buildTransitionPage(
        key: state.pageKey,
        child: const ForgotPasswordScreen(),
      ),
    ),
    GoRoute(
      path: '/complete-profile',
      pageBuilder: (context, state) => _buildTransitionPage(
        key: state.pageKey,
        child: const CompleteProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/patient',
      pageBuilder: (context, state) => _buildTransitionPage(
        key: state.pageKey,
        child: const PatientNavigationScreen(),
      ),
    ),
    GoRoute(
      path: '/doctor',
      pageBuilder: (context, state) => _buildTransitionPage(
        key: state.pageKey,
        child: const DoctorHomeScreen(),
      ),
    ),
    GoRoute(
      path: '/edit-profile',
      pageBuilder: (context, state) => _buildTransitionPage(
        key: state.pageKey,
        child: const EditProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/map-picker',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, double>?;
        final lat = extra?['latitude'] ?? -12.046374;
        final lng = extra?['longitude'] ?? -77.042793;
        return _buildTransitionPage(
          key: state.pageKey,
          child: MapPickerScreen(initialLatitude: lat, initialLongitude: lng),
        );
      },
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) => _buildTransitionPage(
        key: state.pageKey,
        child: const NotificationsScreen(),
      ),
    ),
  ],
);


