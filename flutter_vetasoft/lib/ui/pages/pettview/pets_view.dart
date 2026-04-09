import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/animal_service.dart';
import '../donationsview/donations_view.dart';
import 'edit_profile_view.dart';
import '../adoptionview/adoption_view.dart';
import 'pet_profile_view.dart';

class PetsView extends StatefulWidget {
  // Opcional, para simular el cliente. Por ahora forzamos 20 para ver algo
  final int clienteId;
  const PetsView({super.key, this.clienteId = 20});

  @override
  State<PetsView> createState() => _PetsViewState();
}

class _PetsViewState extends State<PetsView> {
  final AnimalService _animalService = AnimalService();
  // Colores extraidos del diseño aproximado
  static const Color _bgLight = Color(0xFFFAFAFE);
  static const Color _purpleLight = Color(0xFFD46CFF);
  static const Color _purple = Color(0xFFC040FF);
  static const Color _headerBlue = Color(0xFF568EBB);
  static const Color _headerPurple = Color(0xFF673E8A);

  List<Map<String, dynamic>> _mascotas = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarMascotas();
  }

  Future<void> _cargarMascotas() async {
    try {
      final mascotas = await _animalService.getAnimalesByCliente(widget.clienteId);
      if (mounted) {
        setState(() {
          _mascotas = mascotas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Header 
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_headerBlue, _headerPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mis mascotas',
                style: GoogleFonts.merriweather(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Selecciona tu mascota',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationsView()));
                },
                icon: const Icon(Icons.volunteer_activism_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileView()));
                },
                icon: const Icon(Icons.settings, color: Colors.white, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tarjeta de Mascota
  Widget _buildPetCard(Map<String, dynamic> pet) {
    final nombre = pet['nombre'] ?? 'Sin nombre';
    final especie = pet['nombre_especie'] ?? 'Animal';
    final raza = pet['nombre_raza'] ?? 'Raza desconocida';
    
    // Asignar un emoji por especie temporalmente
    String emoji = '🐾';
    if (especie.toString().toLowerCase() == 'perro') {
      emoji = '🐶';
    } else if (especie.toString().toLowerCase() == 'gato') {
      emoji = '🐱';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF8166D4), // Morado suave para el avatar
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 26),
          ),
        ),
        title: Text(
          nombre,
          style: GoogleFonts.merriweather(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF20262E),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                especie,
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B7280)),
              ),
              Text(
                raza,
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.blue, size: 28),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PetProfileView(petData: pet)));
        },
      ),
    );
  }

  // Tarjeta de Adopción
  Widget _buildAdoptionCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdoptionView()));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [_purpleLight, _purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _purple.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Círculo con corazón
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.favorite, color: _purpleLight, size: 36),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Adoptar una mascota',
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Encuentra a tu alma gemela, él te esta\nesperando',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continuar',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Colors.white, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: $_errorMessage'),
                            ElevatedButton(
                              onPressed: _cargarMascotas,
                              child: const Text('Reintentar'),
                            )
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargarMascotas,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                          children: [
                            if (_mascotas.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 24.0),
                                child: Text('No tienes mascotas registradas.', textAlign: TextAlign.center,),
                              ),
                            ..._mascotas.map(_buildPetCard),
                            const SizedBox(height: 16),
                            _buildAdoptionCard(),
                            const SizedBox(height: 48),
                            // Tip Bottom
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('💡', style: TextStyle(fontSize: 24)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFF6B7280),
                                        height: 1.5,
                                      ),
                                      children: const [
                                        TextSpan(
                                          text: 'Tip: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF568EBB),
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Al adoptar una mascota su perfil se actualizará con la información de manera automática.',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
