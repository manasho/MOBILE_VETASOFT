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
   * SOLICITAR RECUPERACIÓN DE CONTRASEÑA (envía código OTP al correo)
   */
  static Future<Map<String, dynamic>> solicitarRecuperacion({
    required String correo,
  }) async {
    try {
      final response = await ApiService().post(
        "/auth/forgot-password",
        data: {"correo": correo},
      );
      final data = response.data;
      if (response.statusCode == 200) {
        return {"success": true, "message": data["message"] ?? "Código enviado"};
      }
      return {"success": false, "message": data["message"] ?? "Error al enviar código"};
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
    }
  }

  /**
   * RESETEAR CONTRASEÑA  (valida código OTP y guarda nueva contraseña)
   */
  static Future<Map<String, dynamic>> resetearContrasena({
    required String correo,
    required String codigo,
    required String nuevaContrasena,
  }) async {
    try {
      final response = await ApiService().post(
        "/auth/reset-password",
        data: {
          "correo": correo,
          "codigo": codigo,
          "nuevaContrasena": nuevaContrasena,
        },
      );
      final data = response.data;
      if (response.statusCode == 200) {
        return {"success": true, "message": data["message"] ?? "Contraseña actualizada"};
      }
      return {"success": false, "message": data["message"] ?? "Error al restablecer"};
    } catch (e) {
      return {"success": false, "message": "Error de conexión: $e"};
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
