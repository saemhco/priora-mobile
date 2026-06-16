import 'package:go_router/go_router.dart';
import 'package:priora/features/shared/onboarding/presentation/onboarding_screen.dart';
import 'package:priora/features/shared/auth/presentation/login_screen.dart';
import 'package:priora/features/shared/auth/presentation/register_screen.dart';
import 'package:priora/features/shared/auth/presentation/complete_profile_screen.dart';
import 'package:priora/features/patient/home/presentation/patient_home_screen.dart';
import 'package:priora/features/doctor/home/presentation/doctor_home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/complete-profile',
      builder: (context, state) => const CompleteProfileScreen(),
    ),
    GoRoute(
      path: '/patient',
      builder: (context, state) => const PatientHomeScreen(),
    ),
    GoRoute(
      path: '/doctor',
      builder: (context, state) => const DoctorHomeScreen(),
    ),
  ],
);
