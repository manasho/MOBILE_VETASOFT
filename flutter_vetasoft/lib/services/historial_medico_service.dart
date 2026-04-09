import '../models/historial_medico_model.dart';
import 'api_service.dart';

class HistorialMedicoService {
  static final ApiService _api = ApiService();

  /// 🔍 Obtener historial médico por ID de animal
  static Future<List<HistorialMedico>> obtenerHistorialPorAnimal(int animalId) async {
    try {
      final response = await _api.get('/historial-medico/animal/$animalId');
      final List data = response.data['data'] ?? [];
      return data.map((json) => HistorialMedico.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error en HistorialMedicoService.obtenerHistorialPorAnimal: $e');
      return [];
    }
  }

  /// 🏥 Obtener tipos de consulta disponibles
  static Future<List<Map<String, dynamic>>> obtenerTiposConsulta() async {
    try {
      final response = await _api.get('/historial-medico/tipos-consulta');
      final List data = response.data['data'] ?? [];
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('❌ Error en HistorialMedicoService.obtenerTiposConsulta: $e');
      return [];
    }
  }

  /// 💾 Guardar un nuevo registro de historial médico
  static Future<bool> guardarRegistro(Map<String, dynamic> data) async {
    try {
      final response = await _api.post('/historial-medico', data: data);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('❌ Error en HistorialMedicoService.guardarRegistro: $e');
      return false;
    }
  }
}
