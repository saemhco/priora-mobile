import 'package:dio/dio.dart';
import 'package:priora/features/patient/appointments/domain/models/booking_result.dart';

/// HTTP client of patient appointments. Only makes API calls; no business
/// logic.
class AppointmentsService {
  AppointmentsService(this._dio);

  final Dio _dio;

  Future<List<dynamic>> fetchSpecialties({
    required String accessToken,
  }) async {
    final response = await _dio.get<dynamic>(
      '/specialties',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 200) {
      return response.data as List<dynamic>;
    }
    throw Exception('Error al obtener especialidades');
  }

  Future<List<dynamic>> fetchAvailableBookings() async {
    final response = await _dio.get<dynamic>('/booking/available');
    if (response.statusCode == 200) {
      final dynamic data = response.data;
      if (data is List) {
        return data;
      } else if (data is Map) {
        final possibleList =
            data['data'] ??
            data['items'] ??
            data['doctors'] ??
            data['professionals'] ??
            data['availabilities'];
        if (possibleList is List) {
          return possibleList;
        } else {
          return data.values.whereType<List<dynamic>>().firstOrNull ??
              <dynamic>[];
        }
      }
    }
    throw Exception('Error al obtener disponibilidad');
  }

  Future<BookingResult> bookAppointment({
    required String accessToken,
    required String doctorId,
    required String datetime,
    String? meetingType,
    String? placeId,
    String? triageSessionId,
    String? specialty,
    bool acknowledgeDuplicateSpecialty = false,
  }) async {
    final data = <String, dynamic>{
      'doctorId': doctorId,
      'datetime': datetime,
      'meetingType': meetingType ?? 'VIRTUAL',
      'specialty': specialty,
      'acknowledgeDuplicateSpecialty': acknowledgeDuplicateSpecialty,
      if (placeId != null && placeId.isNotEmpty) 'placeId': placeId,
      if (triageSessionId != null && triageSessionId.isNotEmpty)
        'triageSessionId': triageSessionId,
    };

    try {
      final response = await _dio.post<dynamic>(
        '/appointments',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return BookingResult(
        success: response.statusCode == 200 || response.statusCode == 201,
      );
    } on DioException catch (e) {
      // Los errores 4xx (excepto 401, que gestiona el interceptor de auth)
      // deben devolverse como resultado y no romper el flujo de reserva.
      final status = e.response?.statusCode;
      if (status != null && status != 401) {
        final message = _extractErrorMessage(e);
        return BookingResult(
          success: false,
          message: message,
          isDuplicateSpecialty: _isDuplicateSpecialtyMessage(message),
        );
      }
      rethrow;
    }
  }

  String? _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (msg is List && msg.isNotEmpty) return msg.join('\n');
    }
    return 'Error al reservar la cita. Por favor, reintenta.';
  }

  bool _isDuplicateSpecialtyMessage(String? message) {
    if (message == null) return false;
    final lower = message.toLowerCase();
    return lower.contains('ya tienes una cita próxima') ||
        lower.contains('reservar de todos modos');
  }

  Future<List<dynamic>> fetchMyAppointments({
    required String accessToken,
  }) async {
    final response = await _dio.get<dynamic>(
      '/appointments/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    if (response.statusCode == 200) {
      return response.data as List<dynamic>;
    }
    throw Exception('Error al obtener mis citas');
  }
}
