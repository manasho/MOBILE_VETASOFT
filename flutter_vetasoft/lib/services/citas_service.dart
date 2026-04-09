import 'dart:convert';
import 'package:http/http.dart' as http;

class CitasService {
  static const String baseUrl = "http://TU_IP:3000/api/citas";

  /// 🔍 Obtener citas por cliente
  static Future<List<dynamic>> getCitas({
    required String token,
    int? clienteId,
  }) async {
    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        "cliente_id": clienteId?.toString(),
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