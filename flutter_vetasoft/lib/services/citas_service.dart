import 'api_service.dart';

class CitasService {
  final ApiService _api = ApiService();

  /// 🔍 Obtener citas por cliente o usuario (veterinario)
  Future<List<dynamic>> getCitas({
    int? clienteId,
    int? usuarioId,
  }) async {
    try {
      final response = await _api.get('citas', queryParameters: {
        if (clienteId != null) "cliente_id": clienteId,
        if (usuarioId != null) "usuario_id": usuarioId,
      });
      return response.data['data'] ?? [];
    } catch (e) {
      print('❌ Error en CitasService.getCitas: $e');
      return [];
    }
  }

  /// 🐾 Obtener citas por animal y estado
  static Future<List<dynamic>> obtenerCitasPorAnimalYEstado(int animalId, int estadoId) async {
    try {
      final api = ApiService();
      // 💡 Cambiamos a query parameters para evitar el 404
      final response = await api.get('citas', queryParameters: {
        'animal_id': animalId,
        'estado_id': estadoId,
      });
      return response.data['data'] ?? [];
    } catch (e) {
      print('❌ Error en CitasService.obtenerCitasPorAnimalYEstado: $e');
      return [];
    }
  }

  /// ✅ Actualizar el estado de una cita (ej: pasar a finalizada)
  static Future<void> actualizarEstadoCita(int citaId, int nuevoEstadoId) async {
    try {
      final api = ApiService();
      await api.patch('citas/$citaId/estado', data: {
        "estado_id": nuevoEstadoId,
      });
    } catch (e) {
      print('❌ Error en CitasService.actualizarEstadoCita: $e');
    }
  }
}