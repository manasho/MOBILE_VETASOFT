class CitaModel {
  final int animalId;
  final int clienteId;
  final int veterinarioId;
  final int tipoConsultaId;
  final String fechaCita;
  final String motivo;
  final int estadoId;
  final String? observaciones;
  final String? creadoPor;

  const CitaModel({
    required this.animalId,
    required this.clienteId,
    required this.veterinarioId,
    required this.tipoConsultaId,
    required this.fechaCita,
    required this.motivo,
    required this.estadoId,
    this.observaciones,
    this.creadoPor,
  });

  Map<String, dynamic> toJson() => {
        'animal_id': animalId,
        'cliente_id': clienteId,
        'veterinario_id': veterinarioId,
        'tipo_consulta_id': tipoConsultaId,
        'fecha_cita': fechaCita,
        'motivo': motivo,
        'estado_id': estadoId,
        if (observaciones != null && observaciones!.isNotEmpty)
          'observaciones': observaciones,
        if (creadoPor != null) 'creado_por': creadoPor,
      };
}
