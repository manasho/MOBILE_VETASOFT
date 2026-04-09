import 'package:flutter_vetasoft/services/api_service.dart';

class ApiServiceCitas {
  static final ApiService _api = ApiService();

  // Obtener citas por animal y estado
  static Future<List<Map<String, dynamic>>> obtenerCitasPorAnimalYEstado(int animalId, int estadoId) async {
    try {
      final response = await _api.get('/citas', queryParameters: {
        'animal_id': animalId,
        'estado_id': estadoId,
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = response.data;
        if (decoded['success'] == true) {
          final List<dynamic> data = decoded['data'];
          return data.map((json) => json as Map<String, dynamic>).toList();
        }
      }
      return [];
    } catch (e) {
      print('❌ Error obteniendo citas: $e');
      return [];
    }
  }

  // Actualizar estado de una cita
  static Future<bool> actualizarEstadoCita(int citaId, int nuevoEstadoId) async {
    try {
      final response = await _api.put('/citas/$citaId', data: {
        'estado_id': nuevoEstadoId,
      });

      print('📡 Actualizar estado cita $citaId a $nuevoEstadoId - Status: ${response.statusCode}');
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ Error actualizando estado de cita: $e');
      return false;
    }
  }
}
