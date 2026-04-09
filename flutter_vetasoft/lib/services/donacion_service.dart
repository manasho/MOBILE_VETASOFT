import 'api_service.dart';

class DonacionService {
  final ApiService _api = ApiService();

  /// POST /donaciones
  Future<Map<String, dynamic>> createDonacion(Map<String, dynamic> body) async {
    try {
      final response = await _api.post('/donaciones', data: body);
      return response.data;
    } catch (e) {
      throw Exception('Error al crear donación: $e');
    }
  }
}
