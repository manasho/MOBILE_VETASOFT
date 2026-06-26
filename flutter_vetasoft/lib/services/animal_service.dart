import 'api_service.dart';
import '../models/pacientes_model.dart'; // Importante para getAnimales

class AnimalService {
  final ApiService _api = ApiService();

  /// POST /animales
  Future<Map<String, dynamic>> createAnimal(Map<String, dynamic> body) async {
    try {
      final response = await _api.post('animales', data: body);
      return response.data;
    } catch (e) {
      throw Exception('Error al crear animal: $e');
    }
  }

  /// GET /animales?cliente_id={id}
  Future<List<Map<String, dynamic>>> getAnimalesByCliente(int clienteId) async {
    try {
      final response = await _api.get('/animales', queryParameters: {'cliente_id': clienteId });
      final decoded = response.data;

      List<dynamic> rawList;
      if (decoded is List) {
        rawList = decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        rawList = decoded['data'] as List<dynamic>;
      } else {
        throw Exception('Formato de mascotas inesperado');
      }

      return rawList.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      throw Exception('Error al obtener mascotas: $e');
    }
  }

  /// GET /razas
  Future<List<Map<String, dynamic>>> getRazas() async {
    try {
      final response = await _api.get('/razas');
      final decoded = response.data;

      List<dynamic> rawList;
      if (decoded is List) {
        rawList = decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        rawList = decoded['data'] as List<dynamic>;
      } else {
        throw Exception('Formato de razas inesperado');
      }

      return rawList.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      throw Exception('Error al obtener razas: $e');
    }
  }

  /// GET /animales (Lista global para veterinarios)
  static Future<List<Paciente>> getAnimales() async {
    try {
      final response = await ApiService().get('animales');
      final List data = (response.data is Map) ? (response.data['data'] ?? []) : [];
      return data.map((json) => Paciente.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error en getAnimales: $e');
      return [];
    }
  }

  /// GET /especies
  static Future<List<Map<String, dynamic>>> getEspecies() async {
    try {
      final response = await ApiService().get('especies');
      final List data = (response.data is Map) ? (response.data['data'] ?? []) : [];
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('❌ Error en getEspecies: $e');
      return [];
    }
  }

  /// GET /animales/{id}
  static Future<Map<String, dynamic>?> getAnimalById(String id) async {
    try {
      final response = await ApiService().get('animales/$id');
      if (response.statusCode == 200) {
        if (response.data is Map && response.data['success'] == true) {
          return response.data['data'];
        }
        return response.data;
      }
      return null;
    } catch (e) {
      print('❌ Error en getAnimalById: $e');
      return null;
    }
  }
}
