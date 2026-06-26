class SolicitudAdopcion {
  final int id;
  final int animalId;
  final String animalNombre;
  final String? animalEdad;
  final String animalRaza;
  final String animalEspecie;
  final String nombreSolicitante;
  final String correoSolicitante;
  final String telefonoSolicitante;
  final String direccionSolicitante;
  final String experienciaAnimales;
  final String motivo;
  final DateTime fechaSolicitud;
  final int estadoId;
  final String estadoNombre;
  final String? observacionRespuesta;

  SolicitudAdopcion({
    required this.id,
    required this.animalId,
    required this.animalNombre,
    this.animalEdad,
    required this.animalRaza,
    required this.animalEspecie,
    required this.nombreSolicitante,
    required this.correoSolicitante,
    required this.telefonoSolicitante,
    required this.direccionSolicitante,
    required this.experienciaAnimales,
    required this.motivo,
    required this.fechaSolicitud,
    required this.estadoId,
    required this.estadoNombre,
    this.observacionRespuesta,
  });

  factory SolicitudAdopcion.fromJson(Map<String, dynamic> json) {
    return SolicitudAdopcion(
      id: json['solicitud_id'],
      animalId: json['animal_id'],
      animalNombre: json['animal_nombre'] ?? 'Animal',
      animalEdad: json['animal_edad']?.toString(),
      animalRaza: json['nombre_raza'] ?? 'Desconocida',
      animalEspecie: json['nombre_especie'] ?? '',
      nombreSolicitante: json['nombre_solicitante'] ?? '',
      correoSolicitante: json['correo_solicitante'] ?? '',
      telefonoSolicitante: json['telefono_solicitante'] ?? '',
      direccionSolicitante: json['direccion_solicitante'] ?? '',
      experienciaAnimales: json['experiencia_animales'] ?? '',
      motivo: json['motivo'] ?? '',
      fechaSolicitud: DateTime.parse(json['fecha_solicitud']),
      estadoId: json['estado_id'],
      estadoNombre: json['estado_nombre'] ?? 'Pendiente',
      observacionRespuesta: json['observacion_respuesta'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'solicitud_id': id,
      'animal_id': animalId,
      'nombre_solicitante': nombreSolicitante,
      'correo_solicitante': correoSolicitante,
      'telefono_solicitante': telefonoSolicitante,
      'direccion_solicitante': direccionSolicitante,
      'experiencia_animales': experienciaAnimales,
      'motivo': motivo,
      'estado_id': estadoId,
    };
  }
}
