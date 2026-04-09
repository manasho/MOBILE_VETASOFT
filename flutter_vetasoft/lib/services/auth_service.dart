import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:3000/api";

  /**
   * LOGIN
   */
  static Future<Map<String, dynamic>> login({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "correo": correo,
          "contrasena": contrasena,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"]) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["data"]["token"]);

        return {
          "success": true,
          "user": data["data"]["user"],
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Error en login",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Error de conexión",
      };
    }
  }

  /**
   * OBTENER TOKEN
   */
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  /**
   * HEADERS CON TOKEN 🔥
   */
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  /**
   * GET PROTEGIDO
   */
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await getAuthHeaders();

      final response = await http.get(
        Uri.parse("$baseUrl/$endpoint"),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      return {"success": false, "message": "Error de conexión"};
    }
  }

  /**
   * POST PROTEGIDO
   */
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await getAuthHeaders();

      final response = await http.post(
        Uri.parse("$baseUrl/$endpoint"),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      return {"success": false, "message": "Error de conexión"};
    }
  }

  /**
   * MANEJO CENTRALIZADO DE RESPUESTAS 🔥
   */
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    if (response.statusCode == 401) {
      return {
        "success": false,
        "message": "Sesión expirada, inicia sesión nuevamente",
        "code": 401,
      };
    }

    if (response.statusCode == 403) {
      return {
        "success": false,
        "message": "No tienes permisos para esta acción",
        "code": 403,
      };
    }

    return {
      "success": false,
      "message": data["error"] ?? "Error desconocido",
    };
  }

  /**
   * LOGOUT
   */
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}