// lib/services/api_service_historial_medico.dart

import 'package:flutter_vetasoft/models/historial_medico_model.dart';
import 'package:flutter_vetasoft/services/api_service.dart';

class ApiServiceHistorial {
  static final ApiService _api = ApiService();

  static Future<List<HistorialMedico>> obtenerHistorialPorAnimal(
    int animalId,
  ) async {
    try {
      final response = await _api.get(
        '/historial-medico',
        queryParameters: {'animal_id': animalId},
      );

      print('🔍 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = response.data;

        if (decoded['success'] == true) {
          final List<dynamic> data = decoded['data'] ?? [];
          print('✅ Datos recibidos: ${data.length} registros');

          if (data.isNotEmpty) {
            print('📋 Primer registro: ${data[0]}');
          }

          return data.map((json) => HistorialMedico.fromJson(json)).toList();
        } else {
          throw Exception('Error en API: ${decoded['message']}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Token no autorizado. Verifica el token.');
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en ApiServiceHistorial: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener tipos de consulta desde el catálogo
  static Future<List<Map<String, dynamic>>> obtenerTiposConsulta() async {
    try {
      final response = await _api.get('/catalogos/tipo-consulta');

      print('🔍 Tipos consulta - Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = response.data;

        if (decoded['success'] == true) {
          final List<dynamic> data = decoded['data'] ?? [];
          print('✅ Tipos de consulta cargados: ${data.length}');
          return data.map((json) => json as Map<String, dynamic>).toList();
        } else {
          throw Exception(
            'Error al cargar tipos de consulta: ${decoded['message']}',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Token no autorizado');
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error cargando tipos de consulta: $e');
      throw Exception('Error al cargar tipos de consulta: $e');
    }
  }
  // Guardar un nuevo registro de historial médico
  static Future<bool> guardarRegistro(Map<String, dynamic> data) async {
    try {
      final response = await _api.post('/historial-medico', data: data);

      print('📥 Guardar registro - Status Code: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Error al guardar: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      print('❌ Error guardando registro: $e');
      throw Exception('Error al guardar el registro: $e');
    }
  }
}
