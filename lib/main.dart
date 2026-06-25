import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:priora/core/network/network.dart';
import 'package:priora/core/routing/app_router.dart';
import 'package:priora/core/theme/app_theme.dart';
import 'package:priora/features/patient/triage/data/triage_repository.dart';
import 'package:priora/features/shared/auth/data/auth_repository.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final authRepository = AuthRepository(dio);
  final triageRepository = TriageRepository(dio);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Dio>.value(value: dio),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<TriageRepository>.value(value: triageRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository: authRepository),
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
