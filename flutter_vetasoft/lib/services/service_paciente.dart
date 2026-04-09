import 'api_service.dart';
import '../models/pacientes_model.dart';

class ApiServicePaciente {
  static final ApiService _api = ApiService();

  /// 📋 Obtener todos los pacientes (animales)
  static Future<List<Paciente>> obtenerPacientes() async {
    try {
      final response = await _api.get('/animales/detalles');
      final List data = response.data['data'] ?? [];
      return data.map((json) => Paciente.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error en ApiServicePaciente.obtenerPacientes: $e');
      return [];
    }
  }

  /// 🧬 Obtener especies disponibles
  static Future<List<Map<String, dynamic>>> obtenerEspecies() async {
    try {
      final response = await _api.get('/especies');
      final List data = response.data['data'] ?? [];
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('❌ Error en ApiServicePaciente.obtenerEspecies: $e');
      return [];
    }
  }
}
