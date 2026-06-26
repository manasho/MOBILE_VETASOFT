class Paciente {
  final int animalId;
  final String nombre;
  final String nombreRaza;
  final String nombreEspecie;
  final String clienteNombre;
  final String clienteDocumento;
  final int edad;
  final String sexo;
  final String? foto;

  Paciente({
    required this.animalId,
    required this.nombre,
    required this.nombreRaza,
    required this.nombreEspecie,
    required this.clienteNombre,
    required this.clienteDocumento,
    required this.edad,
    required this.sexo,
    this.foto,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      animalId: json['animal_id'] ?? 0,
      nombre: json['nombre'] ?? 'Sin nombre',
      nombreRaza: json['raza_nombre'] ?? json['nombre_raza'] ?? 'Desconocida',
      nombreEspecie: json['especie_nombre'] ?? json['nombre_especie'] ?? 'Desconocida',
      clienteNombre: json['cliente_nombre'] ?? 'Sin dueño',
      clienteDocumento: json['cliente_documento'] ?? 'N/A',
      edad: int.tryParse(json['edad']?.toString() ?? '0') ?? 0,
      sexo: json['sexo'] ?? 'N/A',
      foto: json['foto'],
    );
  }
}
