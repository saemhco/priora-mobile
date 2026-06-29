import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:priora/core/network/network.dart';
import 'package:priora/core/routing/app_router.dart';
import 'package:priora/core/theme/app_theme.dart';
import 'package:priora/features/patient/appointments/data/appointments_repository.dart';
import 'package:priora/features/patient/triage/data/triage_repository.dart';
import 'package:priora/features/shared/auth/data/auth_event.dart';
import 'package:priora/features/shared/auth/data/auth_repository.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';

import 'package:priora/core/di/injection.dart';

import 'package:priora/features/patient/profile/data/profile_repository.dart';
import 'package:priora/features/patient/profile/presentation/blocs/profile_cubit/profile_cubit.dart';
import 'package:priora/features/shared/auth/data/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_DOWNLOADS_TOKEN'] ?? '');

  // Initialize dependency injection
  await initInjection();

  final authBloc = getIt<AuthBloc>();

  AuthInterceptor.onTokenRefreshed = (accessToken, refreshToken) {
    authBloc.add(
      AuthTokenRefreshed(accessToken: accessToken, refreshToken: refreshToken),
    );
  };

  AuthInterceptor.onLogout = () {
    authBloc.add(const AuthLogoutRequested());
    appRouter.go('/login');
  };

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Dio>.value(value: getIt<Dio>()),
        RepositoryProvider<AuthRepository>.value(
          value: getIt<AuthRepository>(),
        ),
        RepositoryProvider<TriageRepository>.value(
          value: getIt<TriageRepository>(),
        ),
        RepositoryProvider<AppointmentsRepository>.value(
          value: getIt<AppointmentsRepository>(),
        ),
        RepositoryProvider<ProfileRepository>.value(
          value: getIt<ProfileRepository>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<ProfileCubit>(
            create: (context) {
              final authState = authBloc.state;
              final token = authState is AuthAuthenticated
                  ? authState.accessToken
                  : '';
              return getIt<ProfileCubit>()..loadProfile(accessToken: token);
            },
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Priora',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
