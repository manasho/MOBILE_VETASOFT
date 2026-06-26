import 'package:jwt_decoder/jwt_decoder.dart';
import 'api_service.dart';
import '../models/app_user.dart';

class UserService {
  final ApiService _api = ApiService();

  // Método para obtener el usuario actual completo (Token + API)
  Future<AppUser> getCurrentUser() async {
    try {
      // 1. Tomamos el token CENTRALIZADO del ApiService
      final String token = ApiService.currentToken;
      
      // 2. Decodificamos el token solo para obtener el ID
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final int userId = decodedToken['userId'] ?? 0;

      // 3. Pedimos los datos completos (teléfono, dirección) a la API
      final response = await _api.get('/usuarios/$userId');
      
      // 🚀 El JSON de la API pasará por nuestro "traductor inteligente" de AppUser
      final userData = response.data['data']; 
      return AppUser.fromJson(userData);

    } catch (e) {
      print("❌ Error en UserService.getCurrentUser: $e");
      // Si hay error, devolvemos un usuario mínimo para no romper la UI
      return AppUser(
        id: 0,
        nombre: 'Usuario',
        correo: '',
      );
    }
  }
}
