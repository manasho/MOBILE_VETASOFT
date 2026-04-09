// lib/services/api_service_auth.dart (o donde manejes el login)

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final _storage = FlutterSecureStorage();
  
  // Guardar datos del usuario después del login
  static Future<void> guardarUsuario(Map<String, dynamic> usuario, String token) async {
    await _storage.write(key: 'usuario_id', value: usuario['usuario_id'].toString());
    await _storage.write(key: 'cliente_id', value: usuario['cliente_id']?.toString() ?? '');
    await _storage.write(key: 'rol_id', value: usuario['rol_id'].toString());
    await _storage.write(key: 'token', value: token);
  }
  
  // Obtener el token guardado
  static Future<String?> obtenerToken() async {
    return await _storage.read(key: 'token');
  }
  
  // Obtener cliente_id del usuario logueado
  static Future<int?> obtenerClienteId() async {
    final clienteId = await _storage.read(key: 'cliente_id');
    return clienteId != null ? int.tryParse(clienteId) : null;
  }
  
  // Obtener usuario_id
  static Future<int?> obtenerUsuarioId() async {
    final usuarioId = await _storage.read(key: 'usuario_id');
    return usuarioId != null ? int.tryParse(usuarioId) : null;
  }
  
  // Limpiar datos al cerrar sesión
  static Future<void> limpiarSesion() async {
    await _storage.delete(key: 'usuario_id');
    await _storage.delete(key: 'cliente_id');
    await _storage.delete(key: 'rol_id');
    await _storage.delete(key: 'token');
  }
}