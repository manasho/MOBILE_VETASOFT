class TipoConsulta {
  final int tipoConsultaId;
  final String nombre;
  final String? descripcion;

  TipoConsulta({
    required this.tipoConsultaId,
    required this.nombre,
    this.descripcion,
  });

  factory TipoConsulta.fromJson(Map<String, dynamic> json) {
    return TipoConsulta(
      tipoConsultaId: json['tipo_consulta_id'] ?? json['id'] ?? 0,
      nombre: json['nombre'] ?? json['nombre_consulta'] ?? 'Sin nombre',
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo_consulta_id': tipoConsultaId,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}
