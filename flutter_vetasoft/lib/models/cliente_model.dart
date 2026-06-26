class ClienteModel {
  final String nombre;
  final String? documentoId;
  final String correo;
  final String telefono;
  final String direccion;
  final String? fechaNacimiento;

  const ClienteModel({
    required this.nombre,
    this.documentoId,
    required this.correo,
    required this.telefono,
    required this.direccion,
    this.fechaNacimiento,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'direccion': direccion,
      if (documentoId != null && documentoId!.isNotEmpty)
        'documento_id': documentoId,
      if (fechaNacimiento != null && fechaNacimiento!.isNotEmpty)
        'fecha_nacimiento': fechaNacimiento,
    };
  }
}
