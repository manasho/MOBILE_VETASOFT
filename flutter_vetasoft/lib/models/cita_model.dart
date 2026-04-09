// lib/models/cita_model.dart

class Cita {
  final int citaId;
  final int animalId;
  final int veterinarioId;
  final DateTime fechaCita;
  final String motivo;
  final int estadoId;
  final String? observaciones;
  final DateTime fechaCreacion;
  final int? creadoPor;
  final String animalNombre;
  final String clienteNombre;
  final String clienteTelefono;
  final String veterinarioNombre;
  final String estadoNombre;

  Cita({
    required this.citaId,
    required this.animalId,
    required this.veterinarioId,
    required this.fechaCita,
    required this.motivo,
    required this.estadoId,
    this.observaciones,
    required this.fechaCreacion,
    this.creadoPor,
    required this.animalNombre,
    required this.clienteNombre,
    required this.clienteTelefono,
    required this.veterinarioNombre,
    required this.estadoNombre,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      citaId: json['cita_id'],
      animalId: json['animal_id'],
      veterinarioId: json['veterinario_id'],
      fechaCita: DateTime.parse(json['fecha_cita']),
      motivo: json['motivo'] ?? '',
      estadoId: json['estado_id'],
      observaciones: json['observaciones'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      creadoPor: json['creado_por'],
      animalNombre: json['animal_nombre'] ?? '',
      clienteNombre: json['cliente_nombre'] ?? '',
      clienteTelefono: json['cliente_telefono'] ?? '',
      veterinarioNombre: json['veterinario_nombre'] ?? '',
      estadoNombre: json['estado_nombre'] ?? '',
    );
  }
}