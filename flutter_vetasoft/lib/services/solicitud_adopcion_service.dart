import 'package:jwt_decoder/jwt_decoder.dart';
import 'api_service.dart';
import '../models/solicitud_adopcion.dart';
import 'auth_service.dart';

class SolicitudAdopcionService {
  final ApiService _api = ApiService();

  // Obtener todas las solicitudes
  static Future<Map<String, dynamic>> getSolicitudes({
    int? estadoId,
    int? animalId,
    int? usuarioId,
  }) async {
    final queryParams = {
      "estado_id": estadoId,
      "animal_id": animalId,
      "usuario_id": usuarioId,
    };
    try {
      final response = await ApiService().get(
        "solicitudes-adopcion",
        queryParameters: queryParams..removeWhere((key, value) => value == null),
      );
      return response.data;
    } catch (e) {
      return {"success": false, "message": "Error al obtener solicitudes"};
    }
  }

  // Crear una nueva solicitud (POST)
  static Future<Map<String, dynamic>> crearSolicitud({
    required int animal_id,
    required int usuario_id,
    required String nombre_solicitante,
    required String correo_solicitante,
    required String telefono_solicitante,
    required String direccion_solicitante,
    required String experiencia_animales,
    required String motivo,
  }) async {
    try {
      final response = await ApiService().post(
        "solicitudes-adopcion",
        data: {
          "animal_id": animal_id,
          "usuario_id": usuario_id,
          "nombre_solicitante": nombre_solicitante,
          "correo_solicitante": correo_solicitante,
          "telefono_solicitante": telefono_solicitante,
          "direccion_solicitante": direccion_solicitante,
          "experiencia_animales": experiencia_animales,
          "motivo": motivo,
          "estado_id": 1,
        },
      );
      return response.data;
    } catch (e) {
      return {"success": false, "message": "Error al crear solicitud"};
    }
  }

  // Obtener una solicitud por ID
  Future<SolicitudAdopcion?> getSolicitudById(int id) async {
    try {
      final response = await ApiService().get('solicitudes-adopcion/$id');
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
      final String? token = await AuthService.getToken();
      if (token == null) return false;

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final int currentUserId = decodedToken['userId'] ?? 0;

      final response = await ApiService().put(
        'solicitudes-adopcion/$id/estado',
        data: {
          'estado_id': nuevoEstadoId,
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
