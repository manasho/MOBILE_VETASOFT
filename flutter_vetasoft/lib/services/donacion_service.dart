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

  /// GET /donaciones
  static Future<List<Map<String, dynamic>>> getDonaciones() async {
    try {
      final response = await ApiService().get('donaciones');
      final data = response.data;

      List<dynamic> rawList;
      if (data is List) {
        rawList = data;
      } else if (data is Map && data['data'] is List) {
        rawList = data['data'] as List;
      } else if (data is Map && data['donaciones'] is List) {
        rawList = data['donaciones'] as List;
      } else {
        rawList = [];
      }

      return rawList.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      print('❌ Error en getDonaciones: $e');
      return [];
    }
  }
}
