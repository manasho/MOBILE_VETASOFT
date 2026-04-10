import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  /**
   * LOGIN
   */
  static Future<Map<String, dynamic>> login({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await ApiService().post(
        "/auth/login",
        data: {
          "correo": correo,
          "contrasena": contrasena,
        },
      );

      final data = response.data;

      if (response.statusCode == 200 && data["success"]) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["data"]["token"]);

        return {"success": true, "user": data["data"]["user"]};
      }

      return {"success": false, "message": data["message"] ?? "Error en login"};
    } catch (e) {
      return {"success": false, "message": "Error de conexión"};
    }
  }

  /**
   * OBTENER ID USUARIO 🔥
   */
  static Future<int?> obtenerUsuarioId() async {
    final token = await getToken();
    if (token == null || JwtDecoder.isExpired(token)) return null;

    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['userId']; // Ajustamos segun el payload del JWT
  }

  /**
   * OBTENER TOKEN
   */
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }
  /**
   * LOGOUT
   */
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}
