import 'vet_appointment.dart';

class VetDashboardStats {
  final int citasHoy;
  final int pacientesRegistrados;
  final int solicitudesAdopcion;
  final double donacionesMes;
  final List<VetAppointment> proximasCitas; // 👈 Nuestra nueva lista

  VetDashboardStats({
    this.citasHoy = 0,
    this.pacientesRegistrados = 0,
    this.solicitudesAdopcion = 0,
    this.donacionesMes = 0.0,
    this.proximasCitas = const [], // Empezamos con una lista vacía
  });

  VetDashboardStats copyWith({
    int? citasHoy,
    int? pacientesRegistrados,
    int? solicitudesAdopcion,
    double? donacionesMes,
    List<VetAppointment>? proximasCitas,
  }) {
    return VetDashboardStats(
      citasHoy: citasHoy ?? this.citasHoy,
      pacientesRegistrados: pacientesRegistrados ?? this.pacientesRegistrados,
      solicitudesAdopcion: solicitudesAdopcion ?? this.solicitudesAdopcion,
      donacionesMes: donacionesMes ?? this.donacionesMes,
      proximasCitas: proximasCitas ?? this.proximasCitas,
    );
  }
}
