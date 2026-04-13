import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 💡 URL Base corregida con '/' al final para evitar errores 404 de concatenación
  static const String _baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:4000/api/', 
  );

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  ApiService._internal() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString("token");
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Respuesta API [${response.requestOptions.path}]: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('❌ Error API [${e.requestOptions.path}]: ${e.response?.statusCode}');
          if (e.response?.data != null) {
            print('📦 Detalle Error: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Helper para normalizar el path (elimina '/' inicial si existe)
  String _normalize(String path) {
    if (path.startsWith('/')) {
      return path.substring(1);
    }
    return path;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(_normalize(path), queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(_normalize(path), data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(_normalize(path), data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await _dio.patch(_normalize(path), data: data);
  }

  /// Crear una cita (POST /citas)
  static Future<Response> createCita(Map<String, dynamic> body) async {
    return await ApiService().post('citas', data: body);
  }
}
