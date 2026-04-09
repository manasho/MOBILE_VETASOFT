import 'api_service.dart';

class ApiServiceCitas {
  static final ApiService _api = ApiService();

  /// 🔍 Obtener citas por cliente
  static Future<List<dynamic>> getCitas({
    int? clienteId,
  }) async {
    try {
      final response = await _api.get('/citas', queryParameters: {
        if (clienteId != null) "cliente_id": clienteId,
      });
      return response.data['data'] ?? [];
    } catch (e) {
      print('❌ Error en ApiServiceCitas.getCitas: $e');
      return [];
    }
  }

  /// 🐾 Obtener citas por animal y estado
  static Future<List<dynamic>> obtenerCitasPorAnimalYEstado(int animalId, int estadoId) async {
    try {
      final response = await _api.get('/citas/animal/$animalId/estado/$estadoId');
      return response.data['data'] ?? [];
    } catch (e) {
      print('❌ Error en ApiServiceCitas.obtenerCitasPorAnimalYEstado: $e');
      return [];
    }
  }

  /// ✅ Actualizar el estado de una cita
  static Future<void> actualizarEstadoCita(int citaId, int nuevoEstadoId) async {
    try {
      await _api.patch('/citas/$citaId/estado', data: {
        "estado_id": nuevoEstadoId,
      });
    } catch (e) {
      print('❌ Error en ApiServiceCitas.actualizarEstadoCita: $e');
    }
  }
}
