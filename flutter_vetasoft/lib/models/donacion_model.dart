class DonacionModel {
  final int campanaId;
  final String nombreDonante;
  final String? correoDonante;
  final String? telefonoDonante;
  final double monto;
  final String metodoPago;
  final String? numeroTransaccion;
  final String? observaciones;
  final bool anonimo;

  const DonacionModel({
    required this.campanaId,
    required this.nombreDonante,
    this.correoDonante,
    this.telefonoDonante,
    required this.monto,
    required this.metodoPago,
    this.numeroTransaccion,
    this.observaciones,
    this.anonimo = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'campana_id': campanaId,
      'nombre_donante': nombreDonante,
      if (correoDonante != null && correoDonante!.isNotEmpty) 'correo_donante': correoDonante,
      if (telefonoDonante != null && telefonoDonante!.isNotEmpty) 'telefono_donante': telefonoDonante,
      'monto': monto,
      'metodo_pago': metodoPago,
      if (numeroTransaccion != null && numeroTransaccion!.isNotEmpty) 'numero_transaccion': numeroTransaccion,
      if (observaciones != null && observaciones!.isNotEmpty) 'observaciones': observaciones,
      'anonimo': anonimo,
    };
  }
}
