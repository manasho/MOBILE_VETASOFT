import 'dart:convert';
import 'package:http/http.dart' as http;

class DonacionesService {
  static const String baseUrl = "http://TU_IP:3000/api/donaciones";

  /// Obtener todas las donaciones
  static Future<List<dynamic>> getDonaciones({
    required String token,
    int? campanaId,
    int? usuarioId,
  }) async {
    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        "campana_id": campanaId?.toString(),
        "usuario_id": usuarioId?.toString(),
      });

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}