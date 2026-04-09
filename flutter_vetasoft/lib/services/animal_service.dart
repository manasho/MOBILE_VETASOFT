import 'api_service.dart';

class AnimalService {
  final ApiService _api = ApiService();

  /// POST /animales
  Future<Map<String, dynamic>> createAnimal(Map<String, dynamic> body) async {
    try {
      final response = await _api.post('/animales', data: body);
      return response.data;
    } catch (e) {
      throw Exception('Error al crear animal: $e');
    }
  }

  /// GET /animales?cliente_id={id}
  Future<List<Map<String, dynamic>>> getAnimalesByCliente(int clienteId) async {
    try {
      final response = await _api.get('/animales', queryParameters: {'cliente_id': clienteId});
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
}
