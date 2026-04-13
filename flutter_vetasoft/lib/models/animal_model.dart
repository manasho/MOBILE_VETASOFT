class AnimalModel {
  final int? cliente_id;
  final String nombre;
  final int raza_id;
  final int? edad;
  final String? fecha_nacimiento;
  final double? peso;
  final String sexo;
  final String? descripcion;
  final String? numero_chip;
  final String? estado_animal;
  final String? foto;

  const AnimalModel({
    required this.cliente_id,
    required this.nombre,
    required this.raza_id,
    this.edad,
    this.fecha_nacimiento,
    this.peso,
    required this.sexo,
    this.descripcion,
    this.numero_chip,
    this.estado_animal,
    this.foto,
  });

  Map<String, dynamic> toJson() {
    return {
      if (cliente_id != null) 'cliente_id': cliente_id,
      'nombre': nombre,
      'raza_id': raza_id,
      'sexo': sexo,
      if (edad != null) 'edad': edad,
      if (fecha_nacimiento != null && fecha_nacimiento!.isNotEmpty)
        'fecha_nacimiento': fecha_nacimiento,
      if (peso != null) 'peso': peso,
      if (descripcion != null && descripcion!.isNotEmpty)
        'descripcion': descripcion,
      if (numero_chip != null && numero_chip!.isNotEmpty)
        'numero_chip': numero_chip,
      if (estado_animal != null && estado_animal!.isNotEmpty) 'estado_animal': estado_animal,
      if (foto != null && foto!.isNotEmpty) 'foto': foto,
    };
  }
}
