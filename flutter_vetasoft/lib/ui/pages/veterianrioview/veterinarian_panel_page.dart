import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/vet_dashboard_stats.dart';
import '../../../services/vet_service.dart';
import '../../../widgets/stat_card.dart';
import '../../../widgets/action_card.dart';
import '../../../widgets/appointment_tile.dart'; // ✅ Importamos el nuevo componente

class VeterinarianPanelPage extends StatelessWidget {
  VeterinarianPanelPage({super.key});
  
  final VetService _vetService = VetService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            
            FutureBuilder<VetDashboardStats>(
              future: _vetService.getDashboardStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(100.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Error al conectar con la clínica"),
                  );
                }

                final stats = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  child: Column(
                    children: [
                      _buildWelcomeCard(stats.citasHoy),
                      const SizedBox(height: 25),
                      _buildStatsGrid(stats),
                      const SizedBox(height: 35),
                      _buildActionCardsSection(),
                      const SizedBox(height: 35),
                      
                      // 🕒 5. SECCIÓN DE PRÓXIMAS CITAS REALES
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Próximas citas", 
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, 
                            fontSize: 20, 
                            color: Colors.black87
                          )
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Si no hay citas, mostramos un mensaje bonito
                      if (stats.proximasCitas.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text("No tienes citas para hoy. ¡Día tranquilo! ☕"),
                        )
                      else
                        // ✅ Si hay citas, las dibujamos una por una
                        ...stats.proximasCitas.map((cita) => AppointmentTile(appointment: cita)),
                        
                      const SizedBox(height: 50), // Espacio al final
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. HEADER ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.only(top: 60, left: 30, right: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5391B4), Color(0xFF6B4592)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Panel veterinario",
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              Text("Clínica veterinaria Branquiovet",
                style: GoogleFonts.outfit(fontSize: 16, color: Colors.white70)),
            ],
          ),
          const Column(
            children: [
              Text("Salir", style: TextStyle(color: Colors.white70)),
              Icon(Icons.exit_to_app, color: Colors.white, size: 30),
            ],
          ),
        ],
      ),
    );
  }

  // --- 2. BIENVENIDA ---
  Widget _buildWelcomeCard(int totalCitas) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE5B6FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("¡Bienvenido!", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("Tienes $totalCitas citas programadas para hoy", style: GoogleFonts.outfit(fontSize: 15, color: Colors.white)),
        ],
      ),
    );
  }

  // --- 3. GRID DE ESTADÍSTICAS ---
   Widget _buildStatsGrid(VetDashboardStats stats) {
    return Column(
      children: [
        Row(
          children: [
            StatCard(value: "${stats.citasHoy}", label: "Citas hoy", color: const Color(0xFFF7C6E6)),
            const SizedBox(width: 15),
            StatCard(value: "${stats.pacientesRegistrados}", label: "Pacientes registrados", color: const Color(0xFF90B9D3)),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            StatCard(value: "${stats.solicitudesAdopcion}", label: "Solicitudes de adopción", color: const Color(0xFFB5A9E1)),
            const SizedBox(width: 15),
            StatCard(value: "\$${stats.donacionesMes}", label: "Donaciones/mes", color: const Color(0xFFD3E6CC)),
          ],
        ),
      ],
    );
  }

  // --- 4. SECCIÓN DE ACCIONES ---
  Widget _buildActionCardsSection() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.1,
      children: const [
        ActionCard(icon: Icons.calendar_today, title: "Gestión de citas"),
        ActionCard(icon: Icons.pets, title: "Pacientes"),
        ActionCard(icon: Icons.favorite, title: "Donaciones"),
        ActionCard(icon: Icons.home, title: "Adopciones"),
      ],
    );
  }
}
