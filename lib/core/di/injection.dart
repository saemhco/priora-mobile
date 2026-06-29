import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:priora/core/network/network.dart';
import 'package:priora/features/shared/auth/data/auth_repository.dart';
import 'package:priora/features/shared/auth/data/auth_bloc.dart';
import 'package:priora/features/patient/triage/data/triage_repository.dart';
import 'package:priora/features/patient/appointments/data/appointments_service.dart';
import 'package:priora/features/patient/appointments/data/appointments_repository.dart';

import 'package:priora/features/patient/profile/data/profile_service.dart';
import 'package:priora/features/patient/profile/data/profile_repository.dart';
import 'package:priora/features/patient/profile/presentation/blocs/profile_cubit/profile_cubit.dart';

final getIt = GetIt.instance;

Future<void> initInjection() async {
  // Core
  getIt.registerLazySingleton<Dio>(() => dio);

  // Services
  getIt.registerLazySingleton<AppointmentsService>(
    () => AppointmentsService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<ProfileService>(
    () => ProfileService(getIt<Dio>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<Dio>()),
  );
  getIt.registerLazySingleton<TriageRepository>(
    () => TriageRepository(getIt<Dio>()),
  );
  getIt.registerLazySingleton<AppointmentsRepository>(
    () => AppointmentsRepository(getIt<AppointmentsService>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(getIt<ProfileService>()),
  );

  // Blocs / State Management
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getIt<ProfileRepository>()),
  );
}
