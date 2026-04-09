class Paciente {
  final int animalId;
  final int clienteId;
  final String nombre;
  final int razaId;
  final int edad;
  final DateTime? fechaNacimiento;
  final String peso;
  final String sexo;
  final String descripcion;
  final String? numeroChip;
  final String estado;
  final DateTime fechaIngreso;
  final bool activo;
  final String? foto;
  final String clienteNombre;
  final String clienteDocumento;
  final String nombreRaza;
  final String nombreEspecie;

  Paciente({
    required this.animalId,
    required this.clienteId,
    required this.nombre,
    required this.razaId,
    required this.edad,
    this.fechaNacimiento,
    required this.peso,
    required this.sexo,
    required this.descripcion,
    this.numeroChip,
    required this.estado,
    required this.fechaIngreso,
    required this.activo,
    this.foto,
    required this.clienteNombre,
    required this.clienteDocumento,
    required this.nombreRaza,
    required this.nombreEspecie,
  });

  /// Crea una instancia de Paciente a partir de un JSON
  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      animalId: json['animal_id'] ?? 0,
      clienteId: json['cliente_id'] ?? 0,
      nombre: json['nombre'] ?? '',
      razaId: json['raza_id'] ?? 0,
      edad: json['edad'] ?? 0,
      fechaNacimiento: json['fecha_nacimiento'] != null
          ? DateTime.parse(json['fecha_nacimiento'])
          : null,
      peso: json['peso']?.toString() ?? '0',
      sexo: json['sexo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      numeroChip: json['numero_chip'],
      estado: json['estado'] ?? '',
      fechaIngreso: json['fecha_ingreso'] != null
          ? DateTime.parse(json['fecha_ingreso'])
          : DateTime.now(),
      activo: json['activo'] ?? true,
      foto: json['foto'],
      clienteNombre: json['cliente_nombre'] ?? '',
      clienteDocumento: json['cliente_documento'] ?? '',
      nombreRaza: json['nombre_raza'] ?? '',
      nombreEspecie: json['nombre_especie'] ?? '',
    );
  }

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'animal_id': animalId,
      'cliente_id': clienteId,
      'nombre': nombre,
      'raza_id': razaId,
      'edad': edad,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
      'peso': peso,
      'sexo': sexo,
      'descripcion': descripcion,
      'numero_chip': numeroChip,
      'estado': estado,
      'fecha_ingreso': fechaIngreso.toIso8601String(),
      'activo': activo,
      'foto': foto,
      'cliente_nombre': clienteNombre,
      'cliente_documento': clienteDocumento,
      'nombre_raza': nombreRaza,
      'nombre_especie': nombreEspecie,
    };
  }

  /// Retorna las iniciales del nombre para el avatar
  String get iniciales {
    final nombres = nombre.split(' ');
    if (nombres.length >= 2) {
      return (nombres[0][0] + nombres[1][0]).toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  /// Retorna la información resumida del animal
  String get infoResumida => '$nombreRaza · $edad años · $sexo';
}
