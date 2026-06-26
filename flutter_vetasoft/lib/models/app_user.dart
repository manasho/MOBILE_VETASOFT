
class AppUser {
  final int id;
  final String nombre;
  final String correo;
  final String? direccion;
  final String? telefono;
  final String? profileImageUrl;

  AppUser({
    required this.id,
    required this.nombre,
    required this.correo,
    this.direccion,
    this.telefono,
    this.profileImageUrl,
  });

  // Método para crear un usuario desde JSON (Maneja datos de Token y de API)
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      // 💡 Traducimos: usuario_id (API) o userId (Token)
      id: json['usuario_id'] ?? json['userId'] ?? 0,
      
      // 💡 Traducimos: nombre (API) o name (Token)
      nombre: json['nombre'] ?? json['name'] ?? 'Usuario',
      
      // 💡 Traducimos: correo (API) o email (Token)
      correo: json['correo'] ?? json['email'] ?? '',
      
      direccion: json['direccion'],
      telefono: json['telefono'],
      profileImageUrl: json['fotoPerfil'] ?? json['profileImageUrl'] ?? '',
    );
  }

  // Método para convertir a JSON (útil para guardar en SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'usuario_id': id,
      'nombre': nombre,
      'correo': correo,
      'direccion': direccion,
      'telefono': telefono,
      'fotoPerfil': profileImageUrl,
    };
  }
}