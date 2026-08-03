import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/appointments/controller/doctor_appointments_state.dart';
import 'package:priora/features/doctor/appointments/data/doctor_appointments_service.dart';

/// Controla el estado de la pantalla de citas del profesional.
/// La vista solo consume el estado expuesto aquí.
class DoctorAppointmentsCubit extends Cubit<DoctorAppointmentsState> {
  final DoctorAppointmentsService _service;
  final String _accessToken;

  DoctorAppointmentsCubit(
    this._service,
    this._accessToken,
  ) : super(const DoctorAppointmentsState());

  /// Carga las citas del profesional (hoy, próximas y pasadas).
  Future<void> loadAppointments() async {
    emit(state.copyWith(isLoading: true, clearLoadError: true));

    try {
      await _fetchAppointments();
      emit(
        state.copyWith(
          isLoading: false,
          clearLoadError: true,
        ),
      );
    } catch (e) {
      debugPrint('Error loading appointments: $e');
      emit(
        state.copyWith(
          isLoading: false,
          loadError: 'No se pudieron cargar las citas',
        ),
      );
    }
  }

  /// Registra la atención de una cita y refresca la lista.
  Future<RegisterAttendanceResult> registerAttendance({
    required String appointmentId,
    required String attendanceNote,
  }) async {
    try {
      await _service.registerAttendance(
        accessToken: _accessToken,
        appointmentId: appointmentId,
        attendanceNote: attendanceNote,
      );
      // Refrescar en silencio para que la cita pase a COMPLETED
      await _fetchAppointments();
      return const RegisterAttendanceResult(success: true);
    } on DioException catch (e) {
      return RegisterAttendanceResult(
        success: false,
        message: _extractError(e),
      );
    } catch (e) {
      debugPrint('Error registering attendance: $e');
      return const RegisterAttendanceResult(
        success: false,
        message: 'Error al registrar la atención. Inténtalo de nuevo.',
      );
    }
  }

  /// Cancela una cita y refresca la lista.
  Future<CancelAppointmentResult> cancelAppointment({
    required String appointmentId,
    String? cancelReason,
  }) async {
    try {
      await _service.cancelAppointment(
        accessToken: _accessToken,
        appointmentId: appointmentId,
        cancelReason: cancelReason,
      );
      // Refrescar en silencio para que la cita pase a CANCELED
      await _fetchAppointments();
      return const CancelAppointmentResult(success: true);
    } on DioException catch (e) {
      return CancelAppointmentResult(
        success: false,
        message: _extractCancelError(e),
      );
    } catch (e) {
      debugPrint('Error cancelling appointment: $e');
      return const CancelAppointmentResult(
        success: false,
        message: 'Error al cancelar la cita. Inténtalo de nuevo.',
      );
    }
  }

  Future<void> _fetchAppointments() async {
    // Una sola llamada al endpoint; el filtrado se hace en memoria.
    final all = await _service.getMyAppointments(accessToken: _accessToken);
    final now = DateTime.now();

    final today = all
        .where((a) =>
            a.dateTimeObj.year == now.year &&
            a.dateTimeObj.month == now.month &&
            a.dateTimeObj.day == now.day &&
            a.status != 'CANCELED')
        .toList()
      ..sort((a, b) => a.dateTimeObj.compareTo(b.dateTimeObj));

    final upcoming = all
        .where((a) =>
            a.dateTimeObj.isAfter(now) &&
            a.status != 'CANCELED' &&
            !(a.dateTimeObj.year == now.year &&
                a.dateTimeObj.month == now.month &&
                a.dateTimeObj.day == now.day))
        .toList()
      ..sort((a, b) => a.dateTimeObj.compareTo(b.dateTimeObj));

    final past = all
        .where((a) =>
            a.dateTimeObj.isBefore(now) &&
            !(a.dateTimeObj.year == now.year &&
                a.dateTimeObj.month == now.month &&
                a.dateTimeObj.day == now.day))
        .toList()
      ..sort((a, b) => b.dateTimeObj.compareTo(a.dateTimeObj)); // más recientes primero

    emit(
      state.copyWith(
        todayAppointments: today,
        upcomingAppointments: upcoming,
        pastAppointments: past,
      ),
    );
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is List && msg.isNotEmpty) return msg.join('\n');
    }
    switch (e.response?.statusCode) {
      case 400:
        return 'El estado o el horario de la cita no permiten registrar la atención.';
      case 403:
        return 'No puedes registrar la atención de esta cita.';
      default:
        return 'Error al registrar la atención. Inténtalo de nuevo.';
    }
  }

  String _extractCancelError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is List && msg.isNotEmpty) return msg.join('\n');
    }
    switch (e.response?.statusCode) {
      case 400:
        return 'No se puede cancelar: fuera de plazo o el estado de la cita no lo permite.';
      case 403:
        return 'No puedes cancelar esta cita.';
      case 404:
        return 'La cita no fue encontrada.';
      default:
        return 'Error al cancelar la cita. Inténtalo de nuevo.';
    }
  }
}
