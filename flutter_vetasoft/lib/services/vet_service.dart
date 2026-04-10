import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/vet_appointment.dart';
import '../models/vet_dashboard_stats.dart';
import 'api_service.dart';
import 'auth_service.dart';

class VetService {
  final ApiService _api = ApiService();

  Future<VetDashboardStats> getDashboardStats() async {
    try {
      // 1. Decodificamos el token (Este token deberíamos sacarlo de una sesión segura más adelante)
      final String? token = await AuthService.getToken();
      if (token == null) {
        throw Exception("No se encontró token de autenticación");
      }
      
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final int userId = decodedToken['userId'];
      
      final responses = await Future.wait([
        _api.get('citas/hoy/$userId'),
        _api.get('animales'),
        _api.get('solicitudes-adopcion'),
        _api.get('donaciones'),
      ]);

      // 🔍 Convertimos la lista cruda de la API en objetos VetAppointment
      final List rawCitas = responses[0].data['data'] ?? [];
      final List<VetAppointment> proximasCitas = rawCitas
          .map((json) => VetAppointment.fromJson(json))
          .toList();

      return VetDashboardStats(
        citasHoy: proximasCitas.length,
        pacientesRegistrados: (responses[1].data['data'] as List).length,
        solicitudesAdopcion: (responses[2].data['data'] as List).length,
        donacionesMes: (responses[3].data['data'] as List).length.toDouble(),
        proximasCitas: proximasCitas, // ✅ ¡Aquí pasan las citas!
      );
    } catch (e) {
      print("❌ Error detallado en VetService: $e");
      return VetDashboardStats();
    }
  }
}
