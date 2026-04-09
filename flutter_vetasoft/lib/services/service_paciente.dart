import 'package:flutter_vetasoft/models/pacientes_model.dart';
import 'package:flutter_vetasoft/services/api_service.dart';

class ApiServicePaciente {
  static final ApiService _api = ApiService();

  /// Obtener todos los pacientes
  static Future<List<Paciente>> obtenerPacientes() async {
    try {
      final response = await _api.get('/animales');

      // Dio ya parsea el JSON si el header Content-Type es application/json
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = response.data;
        if (decoded['success'] == true) {
          final List<dynamic> data = decoded['data'];
          return data.map((e) => Paciente.fromJson(e)).toList();
        } else {
          throw Exception('Error en la respuesta del servidor');
        }
      } else {
        throw Exception('Error al conectarse al servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener pacientes: $e');
    }
  }

  /// Obtener las especies únicas
  static Future<List<Map<String, dynamic>>> obtenerEspecies() async {
    try {
      final response = await _api.get('/especies');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = response.data;
        if (decoded['success'] == true) {
          final List<dynamic> data = decoded['data'];
          return List<Map<String, dynamic>>.from(data);
        } else {
          throw Exception('Error en la respuesta del servidor');
        }
      } else {
        throw Exception('Error al conectarse al servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener especies: $e');
    }
  }
}
