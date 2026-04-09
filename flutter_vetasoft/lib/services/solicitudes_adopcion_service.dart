import 'auth_service.dart';

class SolicitudesAdopcionService {

  static Future<Map<String, dynamic>> getSolicitudes({
    int? estadoId,
    int? animalId,
    int? usuarioId,
  }) async {
    final queryParams = {
      "estado_id": estadoId?.toString(),
      "animal_id": animalId?.toString(),
      "usuario_id": usuarioId?.toString(),
    };

    final queryString = queryParams.entries
        .where((e) => e.value != null)
        .map((e) => "${e.key}=${e.value}")
        .join("&");

    final endpoint = queryString.isNotEmpty
        ? "solicitudes-adopcion?$queryString"
        : "solicitudes-adopcion";

    return await AuthService.get(endpoint);
  }

  static Future<Map<String, dynamic>> getById(String id) async {
    return await AuthService.get("solicitudes-adopcion/$id");
  }

  static Future<Map<String, dynamic>> crearSolicitud({
    required int animalId,
    required String nombre,
    required String correo,
    required String telefono,
    required String direccion,
    required String experiencia,
    required String motivo,
  }) async {
    return await AuthService.post(
      "solicitudes-adopcion",
      {
        "animal_id": animalId,
        "nombre_solicitante": nombre,
        "correo_solicitante": correo,
        "telefono_solicitante": telefono,
        "direccion_solicitante": direccion,
        "experiencia_animales": experiencia,
        "motivo": motivo,
      },
    );
  }

  static Future<Map<String, dynamic>> actualizarEstado({
    required String solicitudId,
    required int estadoId,
    required int respondidoPor,
    String? observacion,
  }) async {
    return await AuthService.post(
      "solicitudes-adopcion/$solicitudId/estado",
      {
        "estado_id": estadoId,
        "respondido_por": respondidoPor,
        "observacion_respuesta": observacion,
      },
    );
  }

 
  static Future<Map<String, dynamic>> eliminar(String id) async {
    return await AuthService.post(
      "solicitudes-adopcion/$id/delete",
      {},
    );
  }
}