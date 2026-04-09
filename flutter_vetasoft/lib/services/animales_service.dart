import 'dart:convert';
import 'package:http/http.dart' as http;

class AnimalesService {
  static const String baseUrl = "http://TU_IP:3000/api/animales";

  static Future<Map<String, dynamic>?> getAnimalById(String id, String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
