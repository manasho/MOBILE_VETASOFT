class HistorialMedico {
  final int? historialId;
  final int citaId;
  final int? tipoConsultaId;
  final int? veterinarioId;
  final String sintomas;
  final String diagnostico;
  final String tratamiento;
  final String examenesRealizados;
  final String medicamentos;
  final DateTime? proximaCita;
  final String observaciones;
  final double peso;
  final double temperatura;
  final int frecuenciaCardiaca;
  final int frecuenciaRespiratoria;
  final DateTime fechaCreacion;
  
  // Metadatos opcionales para la UI (devueltos por JOINS en la API)
  final String? animalNombre;
  final String? clienteNombre;
  final String? veterinarioNombre;

  HistorialMedico({
    this.historialId,
    required this.citaId,
    this.tipoConsultaId,
    this.veterinarioId,
    required this.sintomas,
    required this.diagnostico,
    required this.tratamiento,
    required this.examenesRealizados,
    required this.medicamentos,
    this.proximaCita,
    required this.observaciones,
    required this.peso,
    required this.temperatura,
    required this.frecuenciaCardiaca,
    required this.frecuenciaRespiratoria,
    required this.fechaCreacion,
    this.animalNombre,
    this.clienteNombre,
    this.veterinarioNombre,
  });

  factory HistorialMedico.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return HistorialMedico(
      historialId: json['historial_id'],
      citaId: json['cita_id'] ?? 0,
      tipoConsultaId: json['tipo_consulta_id'],
      veterinarioId: json['veterinario_id'],
      sintomas: json['sintomas'] ?? '',
      diagnostico: json['diagnostico'] ?? '',
      tratamiento: json['tratamiento'] ?? '',
      examenesRealizados: json['examenes_realizados'] ?? '',
      medicamentos: json['medicamentos'] ?? '',
      proximaCita: json['proxima_cita'] != null ? DateTime.tryParse(json['proxima_cita']) : null,
      observaciones: json['observaciones'] ?? '',
      peso: parseDouble(json['peso']),
      temperatura: parseDouble(json['temperatura']),
      frecuenciaCardiaca: parseInt(json['frecuencia_cardiaca']),
      frecuenciaRespiratoria: parseInt(json['frecuencia_respiratoria']),
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion']) ?? DateTime.now()
          : DateTime.now(),
      animalNombre: json['animal_nombre'],
      clienteNombre: json['cliente_nombre'],
      veterinarioNombre: json['veterinario_nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (historialId != null) 'historial_id': historialId,
      'cita_id': citaId,
      'tipo_consulta_id': tipoConsultaId,
      'veterinario_id': veterinarioId,
      'sintomas': sintomas,
      'diagnostico': diagnostico,
      'tratamiento': tratamiento,
      'examenes_realizados': examenesRealizados,
      'medicamentos': medicamentos,
      'proxima_cita': proximaCita?.toIso8601String(),
      'observaciones': observaciones,
      'peso': peso,
      'temperatura': temperatura,
      'frecuencia_cardiaca': frecuenciaCardiaca,
      'frecuencia_respiratoria': frecuenciaRespiratoria,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }
}
