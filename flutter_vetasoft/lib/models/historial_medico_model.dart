

class HistorialMedico {
  final int? id;
  final int? citaId;
  final int? veterinarioId;
  final int? tipoConsultaId;
  final String? sintomas;
  final String? diagnostico;
  final String? tratamiento;
  final String? examenesRealizados;
  final String? medicamentos;
  final String? observaciones;
  final double? peso;
  final double? temperatura;
  final int? frecuenciaCardiaca;
  final int? frecuenciaRespiratoria;
  final DateTime fechaConsulta;
  final DateTime? proximaCita;
  final DateTime? fechaCreacion;

  HistorialMedico({
    this.id,
    this.citaId,
    this.veterinarioId,
    this.tipoConsultaId,
    this.sintomas,
    this.diagnostico,
    this.tratamiento,
    this.examenesRealizados,
    this.medicamentos,
    this.observaciones,
    this.peso,
    this.temperatura,
    this.frecuenciaCardiaca,
    this.frecuenciaRespiratoria,
    required this.fechaConsulta,
    this.proximaCita,
    this.fechaCreacion,
  });

  factory HistorialMedico.fromJson(Map<String, dynamic> json) {
    return HistorialMedico(
      id: json['id'] ?? json['historial_id'],
      citaId: json['cita_id'],
      veterinarioId: json['veterinario_id'],
      tipoConsultaId: json['tipo_consulta_id'],
      sintomas: json['sintomas'],
      diagnostico: json['diagnostico'],
      tratamiento: json['tratamiento'],
      examenesRealizados: json['examenes_realizados'],
      medicamentos: json['medicamentos'],
      observaciones: json['observaciones'],
      peso: double.tryParse(json['peso']?.toString() ?? '0'),
      temperatura: double.tryParse(json['temperatura']?.toString() ?? '0'),
      frecuenciaCardiaca: json['frecuencia_cardiaca'],
      frecuenciaRespiratoria: json['frecuencia_respiratoria'],
      fechaConsulta: DateTime.parse(json['fecha_consulta'] ?? DateTime.now().toIso8601String()),
      proximaCita: json['proxima_cita'] != null ? DateTime.parse(json['proxima_cita']) : null,
      fechaCreacion: json['fecha_creacion'] != null ? DateTime.parse(json['fecha_creacion']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cita_id': citaId,
      'veterinario_id': veterinarioId,
      'tipo_consulta_id': tipoConsultaId,
      'sintomas': sintomas,
      'diagnostico': diagnostico,
      'tratamiento': tratamiento,
      'examenes_realizados': examenesRealizados,
      'medicamentos': medicamentos,
      'observaciones': observaciones,
      'peso': peso,
      'temperatura': temperatura,
      'frecuencia_cardiaca': frecuenciaCardiaca,
      'frecuencia_respiratoria': frecuenciaRespiratoria,
      'fecha_consulta': fechaConsulta.toIso8601String(),
      'proxima_cita': proximaCita?.toIso8601String(),
    };
  }
}
