class AnimalModel {
  final int clienteId;
  final String nombre;
  final int razaId;
  final int? edad;
  final String? fechaNacimiento;
  final double? peso;
  final String sexo;
  final String? descripcion;
  final String? numeroChip;
  final String? estado;
  final String? foto;

  const AnimalModel({
    required this.clienteId,
    required this.nombre,
    required this.razaId,
    this.edad,
    this.fechaNacimiento,
    this.peso,
    required this.sexo,
    this.descripcion,
    this.numeroChip,
    this.estado,
    this.foto,
  });

  Map<String, dynamic> toJson() {
    return {
      'cliente_id': clienteId,
      'nombre': nombre,
      'raza_id': razaId,
      'sexo': sexo,
      if (edad != null) 'edad': edad,
      if (fechaNacimiento != null && fechaNacimiento!.isNotEmpty)
        'fecha_nacimiento': fechaNacimiento,
      if (peso != null) 'peso': peso,
      if (descripcion != null && descripcion!.isNotEmpty)
        'descripcion': descripcion,
      if (numeroChip != null && numeroChip!.isNotEmpty)
        'numero_chip': numeroChip,
      if (estado != null && estado!.isNotEmpty) 'estado': estado,
      if (foto != null && foto!.isNotEmpty) 'foto': foto,
    };
  }
}
