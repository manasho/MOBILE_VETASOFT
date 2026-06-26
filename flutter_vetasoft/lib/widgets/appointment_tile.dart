import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/vet_appointment.dart';

class AppointmentTile extends StatelessWidget {
  final VetAppointment appointment;

  const AppointmentTile({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🕒 Hora de la cita
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              appointment.horaFormateada,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6B4592),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 15),
          
          // 🐾 Nombre de Mascota y Dueño
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.mascotaNombre,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "Dueño: ${appointment.duenoNombre}",
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // 📝 Motivo (opcional o icono)
          const Icon(Icons.description_outlined, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
