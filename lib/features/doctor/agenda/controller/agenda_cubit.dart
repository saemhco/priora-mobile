import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:priora/features/doctor/agenda/controller/agenda_state.dart';
import 'package:priora/features/doctor/agenda/data/availability_service.dart';

class AgendaCubit extends Cubit<AgendaState> {
  final AvailabilityService _service;
  final String _accessToken;

  AgendaCubit(this._service, this._accessToken) : super(const AgendaState());

  Future<DeleteBlockResult> deleteBlock(String blockId) async {
    try {
      await _service.deleteWeekly(
        accessToken: _accessToken,
        scheduleId: blockId,
      );
      return const DeleteBlockResult(success: true);
    } on DioException catch (e) {
      return DeleteBlockResult(
        success: false,
        message: _extractError(e),
      );
    } catch (e) {
      debugPrint('Error deleting block: $e');
      return const DeleteBlockResult(
        success: false,
        message: 'Error al eliminar el bloque. Inténtalo de nuevo.',
      );
    }
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
        return 'No se puede eliminar este bloque.';
      case 404:
        return 'El bloque no fue encontrado.';
      default:
        return 'Error al eliminar el bloque. Inténtalo de nuevo.';
    }
  }
}
