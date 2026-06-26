import 'package:jwt_decoder/jwt_decoder.dart';
import 'api_service.dart';
import '../models/solicitud_adopcion.dart';

class SolicitudAdopcionService {
  final ApiService _api = ApiService();

  // Obtener todas las solicitudes
  Future<List<SolicitudAdopcion>> getAllSolicitudes() async {
    try {
      final response = await _api.get('/solicitudes-adopcion');
      if (response.statusCode == 200 && response.data['success']) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => SolicitudAdopcion.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error en getAllSolicitudes: $e');
      return [];
    }
  }

  // Crear una nueva solicitud (POST)
  Future<bool> createSolicitud(Map<String, dynamic> data) async {
    try {
      final response = await _api.post('/solicitudes-adopcion', data: data);
      return response.statusCode == 201 && response.data['success'];
    } catch (e) {
      print('❌ Error en createSolicitud: $e');
      return false;
    }
  }

  // Obtener una solicitud por ID
  Future<SolicitudAdopcion?> getSolicitudById(int id) async {
    try {
      final response = await _api.get('/solicitudes-adopcion/$id');
      if (response.statusCode == 200 && response.data['success']) {
        final data = response.data['data'];
        if (data != null) {
          return SolicitudAdopcion.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('❌ Error en getSolicitudById: $e');
      return null;
    }
  }

  // Actualizar el estado de la solicitud
  Future<bool> updateEstado(int id, int nuevoEstadoId, {String? observacion}) async {
    try {
      // 1. Tomamos el token CENTRALIZADO del ApiService para saber quién responde
      final String token = ApiService.currentToken;
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final int currentUserId = decodedToken['userId'] ?? 0;

      // 2. Enviamos la actualización con el estado 3 y el ID dinámico
      final response = await _api.put( 
        '/solicitudes-adopcion/$id/estado',
        data: {
          'estado_id': 3, // El estado solicitado (ej: En Revisión/Rechazada según tu tabla)
          'respondido_por': currentUserId,
          'observacion_respuesta': observacion ?? 'Actualizado desde el panel móvil',
        },
      );
      
      return response.statusCode == 200 && response.data['success'];
    } catch (e) {
      print('❌ Error en updateEstado: $e');
      return false;
    }
  }
}
