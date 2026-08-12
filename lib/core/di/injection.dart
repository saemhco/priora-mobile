import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:priora/core/network/network.dart';
import 'package:priora/features/doctor/agenda/data/repositories/agenda_repository.dart';
import 'package:priora/features/doctor/agenda/data/services/availability_service.dart';
import 'package:priora/features/doctor/agenda/domain/interfaces/agenda_repository.dart';
import 'package:priora/features/doctor/appointments/data/repositories/doctor_appointments_repository.dart';
import 'package:priora/features/doctor/appointments/data/services/doctor_appointments_service.dart';
import 'package:priora/features/doctor/appointments/domain/interfaces/doctor_appointments_repository.dart';
import 'package:priora/features/doctor/places/data/repositories/places_repository.dart';
import 'package:priora/features/doctor/places/data/services/places_service.dart';
import 'package:priora/features/doctor/places/domain/interfaces/places_repository.dart';
import 'package:priora/features/doctor/places/presentation/controller/places_cubit.dart';
import 'package:priora/features/doctor/profile/data/repositories/doctor_profile_repository.dart';
import 'package:priora/features/doctor/profile/data/services/doctor_profile_service.dart';
import 'package:priora/features/doctor/profile/domain/interfaces/doctor_profile_repository.dart';
import 'package:priora/features/patient/appointments/data/repositories/appointments_repository.dart';
import 'package:priora/features/patient/appointments/data/services/appointments_service.dart';
import 'package:priora/features/patient/appointments/domain/interfaces/appointments_repository.dart';
import 'package:priora/features/patient/profile/data/repositories/profile_repository.dart';
import 'package:priora/features/patient/profile/data/services/profile_service.dart';
import 'package:priora/features/patient/profile/domain/interfaces/profile_repository.dart';
import 'package:priora/features/patient/profile/presentation/controller/profile_cubit.dart';
import 'package:priora/features/patient/triage/data/repositories/triage_repository.dart';
import 'package:priora/features/patient/triage/data/services/triage_service.dart';
import 'package:priora/features/patient/triage/domain/interfaces/triage_repository.dart';
import 'package:priora/features/shared/auth/data/repositories/auth_repository.dart';
import 'package:priora/features/shared/auth/data/services/auth_service.dart';
import 'package:priora/features/shared/auth/domain/interfaces/auth_repository.dart';
import 'package:priora/features/shared/auth/presentation/controller/auth_bloc.dart';


final GetIt getIt = GetIt.instance;

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
  getIt.registerLazySingleton<PlacesService>(
    () => PlacesService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<AvailabilityService>(
    () => AvailabilityService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<DoctorAppointmentsService>(
    () => DoctorAppointmentsService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<DoctorProfileService>(
    () => DoctorProfileService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<TriageService>(
    () => TriageService(getIt<Dio>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthService>()),
  );
  getIt.registerLazySingleton<TriageRepository>(
    () => TriageRepositoryImpl(getIt<TriageService>()),
  );
  getIt.registerLazySingleton<AppointmentsRepository>(
    () => AppointmentsRepositoryImpl(getIt<AppointmentsService>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<ProfileService>()),
  );
  getIt.registerLazySingleton<PlacesRepository>(
    () => PlacesRepositoryImpl(getIt<PlacesService>()),
  );
  getIt.registerLazySingleton<AgendaRepository>(
    () => AgendaRepositoryImpl(getIt<AvailabilityService>()),
  );
  getIt.registerLazySingleton<DoctorAppointmentsRepository>(
    () => DoctorAppointmentsRepositoryImpl(getIt<DoctorAppointmentsService>()),
  );
  getIt.registerLazySingleton<DoctorProfileRepository>(
    () => DoctorProfileRepositoryImpl(getIt<DoctorProfileService>()),
  );

  // Blocs / State Management
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(authRepository: getIt<AuthRepository>()),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton<PlacesCubit>(
    () => PlacesCubit(getIt<PlacesRepository>()),
  );

}
