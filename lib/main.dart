import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:priora/core/di/injection.dart';
import 'package:priora/core/network/network.dart';
import 'package:priora/core/routing/app_router.dart';
import 'package:priora/core/theme/app_theme.dart';
import 'package:priora/features/doctor/places/domain/interfaces/places_repository.dart';
import 'package:priora/features/patient/appointments/domain/interfaces/appointments_repository.dart';
import 'package:priora/features/patient/profile/domain/interfaces/profile_repository.dart';
import 'package:priora/features/patient/profile/presentation/controller/profile_cubit.dart';
import 'package:priora/features/patient/triage/domain/interfaces/triage_repository.dart';
import 'package:priora/features/shared/auth/domain/interfaces/auth_repository.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_bloc.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_event.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

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
        RepositoryProvider<PlacesRepository>.value(
          value: getIt<PlacesRepository>(),
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('es', 'ES'),
      ],
    );
  }
}
