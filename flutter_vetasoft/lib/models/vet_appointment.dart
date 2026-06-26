import 'package:intl/intl.dart';

class VetAppointment {
  final int id;
  final DateTime fecha;
  final String mascotaNombre;
  final String duenoNombre;
  final String motivo;

  VetAppointment({
    required this.id,
    required this.fecha,
    required this.mascotaNombre,
    required this.duenoNombre,
    required this.motivo,
  });
   String get horaFormateada => DateFormat.jm().format(fecha);
  
  // 🧪 From JSON: Aquí es donde mapeas lo que viene de SQL/Node.js
  factory VetAppointment.fromJson(Map<String, dynamic> json) {
    return VetAppointment(
      id: json['cita_id'] ?? 0,
      // 💡 DateTime.parse() convierte el String de la DB a objeto de Fecha
      fecha: DateTime.parse(json['fecha_cita'] ?? DateTime.now().toString()),
      mascotaNombre: json['mascota_nombre'] ?? 'Sin nombre',
      duenoNombre: json['dueno_nombre'] ?? 'Anónimo',
      motivo: json['motivo'] ?? '',
    );
  }
}
