import 'package:dio/dio.dart';

class ApiService {
  // 💡 MODO EXPERTO:
  // Si le pasas una variable 'API_URL' por terminal la usa, 
  // si no (por defecto), usa tu túnel de Dev Tunnels.
  static const String _baseUrl = String.fromEnvironment(
    'API_URL', 
    defaultValue: 'http://10.0.2.2:4000/api', // Fíjate en el /api al final
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

  // 💡 CENTRALIZAMOS EL TOKEN AQUÍ PARA TODA LA APP
  // Token de Rosa (Admin)
  static const String currentToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjgsImVtYWlsIjoicm9zYTNAZ21haWwuY29tIiwicm9sZUlkIjoxLCJyb2xlTmFtZSI6IkFkbWluIGZ1bmRhY2lvbiIsImlhdCI6MTc3NTc3MDIzMiwiZXhwIjoxNzc2Mzc1MDMyfQ.9o4rHkZHXcoX6RlTxBWxGifXFO6by9kVtcltbqosZlI';
  
  // Token de Veterinario (Tifanny)
  static const String vetToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjMwLCJlbWFpbCI6InZldGVyaWFuYXJpb0BnbWFpbC5jb20iLCJyb2xlSWQiOjQsInJvbGVOYW1lIjoiRGlyZWN0b3IgbWVkaWNvIiwiaWF0IjoxNzc1Njg0MTc5LCJleHAiOjE3NzYyODg5Nzl9.iNVU9uSdKsZ6jbcv3GWHbAoK26iJv-7NR4iJKmp1F4s';

  // 2. Patrón Singleton: Una única instancia para toda la app
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 🚀 Usamos el token centralizado (puedes cambiarlo a vetToken si pruebas sus módulos)
          options.headers['Authorization'] = 'Bearer $currentToken';
          
          print('🚀 Petición: ${options.method} ${options.path}');
          if (options.data != null) {
            print('📦 Body enviado: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Respuesta: ${response.statusCode} - ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('❌ Error API: ${e.response?.statusCode} - ${e.message}');
          if (e.response?.data != null) {
            print('📦 Detalle Error: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  // 3. Métodos genéricos para peticiones
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  // Método PATCH añadido por Tifanny
  Future<Response> patch(String path, {dynamic data}) async {
    return await _dio.patch(path, data: data);
  }
}
