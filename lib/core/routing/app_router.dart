import 'package:go_router/go_router.dart';
import 'package:priora/features/shared/auth/presentation/splash_screen.dart';
import 'package:priora/features/shared/onboarding/presentation/onboarding_screen.dart';
import 'package:priora/features/shared/auth/presentation/login_screen.dart';
import 'package:priora/features/shared/auth/presentation/register_screen.dart';
import 'package:priora/features/shared/auth/presentation/complete_profile_screen.dart';
import 'package:priora/features/patient/navigation/presentation/patient_navigation_screen.dart';
import 'package:priora/features/doctor/home/presentation/doctor_home_screen.dart';
import 'package:priora/features/patient/profile/presentation/edit_profile_screen.dart';
import 'package:priora/features/patient/profile/presentation/map_picker_screen.dart';
import 'package:priora/features/patient/home/presentation/notifications_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
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
      builder: (context, state) => const PatientNavigationScreen(),
    ),
    GoRoute(
      path: '/doctor',
      builder: (context, state) => const DoctorHomeScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/map-picker',
      builder: (context, state) {
        final extra = state.extra as Map<String, double>?;
        final lat = extra?['latitude'] ?? -12.046374;
        final lng = extra?['longitude'] ?? -77.042793;
        return MapPickerScreen(initialLatitude: lat, initialLongitude: lng);
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
  ],
);


