import 'api_service.dart';

class ClienteService {
  final ApiService _api = ApiService();

  /// POST /clientes
  /// Retorna el cliente_id creado
  Future<int> createCliente(Map<String, dynamic> body) async {
    try {
      final response = await _api.post(
        '/clientes/registro-completo',
        data: body,
      );
      final data = response.data;
      
      // Buscamos el ID en la estructura confirmada por el servidor: data['data']['cliente']['cliente_id']
      // Añadimos fallbacks por si la respuesta varía en otros entornos
      final id = (data['data'] != null && data['data']['cliente'] != null) 
                 ? data['data']['cliente']['cliente_id'] 
                 : (data['cliente_id'] ?? data['id'] ?? (data['data'] != null ? (data['data']['cliente_id'] ?? data['data']['id']) : null));

      if (id == null) {
        throw Exception('La API no devolvió un ID de cliente válido. Respuesta recibida: $data');
      }

      return int.parse(id.toString());
    } catch (e) {
      throw Exception('Error al crear cliente: $e');
    }
  }
}
