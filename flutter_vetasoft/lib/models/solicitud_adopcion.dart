class SolicitudAdopcion {
  final int id;
  final int animalId;
  final int? usuarioId;
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
  final DateTime? fechaRespuesta;
  final String? observacionRespuesta;
  final int? respondidoPor;
  final int estadoId;
  final String estadoNombre;

  SolicitudAdopcion({
    required this.id,
    required this.animalId,
    this.usuarioId,
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
    this.fechaRespuesta,
    this.observacionRespuesta,
    this.respondidoPor,
    required this.estadoId,
    this.estadoNombre = 'Pendiente',
  });

  factory SolicitudAdopcion.fromJson(Map<String, dynamic> json) {
    return SolicitudAdopcion(
      id: json['solicitud_id'] ?? 0,
      animalId: json['animal_id'] ?? 0,
      usuarioId: json['usuario_id'],
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
      fechaSolicitud: json['fecha_solicitud'] != null 
          ? DateTime.parse(json['fecha_solicitud']) 
          : DateTime.now(),
      fechaRespuesta: json['fecha_respuesta'] != null 
          ? DateTime.parse(json['fecha_respuesta']) 
          : null,
      observacionRespuesta: json['observacion_respuesta'],
      respondidoPor: json['respondido_por'],
      estadoId: json['estado_id'] ?? 1,
      estadoNombre: json['estado_nombre'] ?? 'Pendiente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'solicitud_id': id,
      'animal_id': animalId,
      'usuario_id': usuarioId,
      'nombre_solicitante': nombreSolicitante,
      'correo_solicitante': correoSolicitante,
      'telefono_solicitante': telefonoSolicitante,
      'direccion_solicitante': direccionSolicitante,
      'experiencia_animales': experienciaAnimales,
      'motivo': motivo,
      'estado_id': estadoId,
      'respondido_por': respondidoPor,
      'observacion_respuesta': observacionRespuesta,
    };
  }
}
