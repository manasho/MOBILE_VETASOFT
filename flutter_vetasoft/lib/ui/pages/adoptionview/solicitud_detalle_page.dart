import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/solicitud_adopcion.dart';
import '../../../services/solicitud_adopcion_service.dart';

class SolicitudDetallePage extends StatefulWidget {
  final int solicitudId;

  const SolicitudDetallePage({super.key, required this.solicitudId});

  @override
  State<SolicitudDetallePage> createState() => _SolicitudDetallePageState();
}

class _SolicitudDetallePageState extends State<SolicitudDetallePage> {
  final SolicitudAdopcionService _adopcionService = SolicitudAdopcionService();
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF), // Fondo lila muy suave
      body: FutureBuilder<SolicitudAdopcion?>(
        future: _adopcionService.getSolicitudById(widget.solicitudId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFB388FF)));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorState();
          }

          final solicitud = snapshot.data!;
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPurpleHeader(solicitud),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          _buildWelcomeCard(solicitud),
                          const SizedBox(height: 20),
                          _buildInfoSection("Datos personales", Icons.person_outline, [
                            _buildDataField("Nombre completo", solicitud.nombreSolicitante),
                            _buildDataField("Correo electrónico", solicitud.correoSolicitante),
                            _buildDataField("Teléfono", solicitud.telefonoSolicitante),
                            _buildDataField("Dirección", solicitud.direccionSolicitante),
                          ]),
                          const SizedBox(height: 20),
                          _buildInfoSection("Experiencia y Motivo", Icons.favorite_border, [
                            _buildDataField("Experiencia con mascotas", solicitud.experienciaAnimales),
                            _buildDataField("¿Por qué quieres adoptarlo?", solicitud.motivo),
                          ]),
                          const SizedBox(height: 100), // Espacio para botones
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildBottomActionButtons(solicitud),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPurpleHeader(SolicitudAdopcion solicitud) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD188FF), Color(0xFFB388FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                const SizedBox(width: 5),
                Text("Volver", style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text("Detalles de solicitud", 
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("Formulario para adoptar a ${solicitud.animalNombre}", 
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withOpacity(0.9))),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(SolicitudAdopcion solicitud) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFF3E5F5), shape: BoxShape.circle),
            child: const Icon(Icons.favorite, color: Color(0xFFB388FF), size: 30),
          ),
          const SizedBox(height: 15),
          Text("¡Qué emoción!", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "Estás a un paso de darle un hogar a ${solicitud.animalNombre}. Por favor revisa el siguiente formulario.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFB388FF), size: 22),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF4A148C))),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDataField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label *", style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(value.isEmpty ? "No especificado" : value, 
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons(SolicitudAdopcion solicitud) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildButton(
                "Iniciar Revisión", 
                const Color(0xFFBBF2E0), 
                const Color(0xFF2D6A4F),
                () => _updateStatus(solicitud.id, 1), // Asumimos ID 1 es "Revisión" o similar
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildButton(
                "Rechazar", 
                const Color(0xFFFFEBEE), 
                const Color(0xFFD32F2F),
                () => _updateStatus(solicitud.id, 3), // ID 3 es Rechazada
                isOutline: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color bgColor, Color textColor, VoidCallback onTap, {bool isOutline = false}) {
    return GestureDetector(
      onTap: _isUpdating ? null : onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isOutline ? Colors.white : bgColor,
          borderRadius: BorderRadius.circular(12),
          border: isOutline ? Border.all(color: textColor.withOpacity(0.5)) : null,
        ),
        child: _isUpdating 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(text, style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Future<void> _updateStatus(int id, int statusId) async {
    setState(() => _isUpdating = true);
    final success = await _adopcionService.updateEstado(id, statusId);
    setState(() => _isUpdating = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Estado actualizado correctamente")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al actualizar el estado")),
      );
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          const SizedBox(height: 10),
          Text("No se pudo cargar la solicitud", style: GoogleFonts.outfit(fontSize: 18)),
          TextButton(onPressed: () => setState(() {}), child: const Text("Reintentar")),
        ],
      ),
    );
  }
}
