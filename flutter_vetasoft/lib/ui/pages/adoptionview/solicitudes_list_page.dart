import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/solicitud_adopcion.dart';
import '../../../services/solicitud_adopcion_service.dart';
import 'solicitud_detalle_page.dart';
import 'solicitud_form_page.dart';

class SolicitudesListPage extends StatefulWidget {
  const SolicitudesListPage({super.key});

  @override
  State<SolicitudesListPage> createState() => _SolicitudesListPageState();
}

class _SolicitudesListPageState extends State<SolicitudesListPage> {
  final SolicitudAdopcionService _adopcionService = SolicitudAdopcionService();
  final TextEditingController _searchController = TextEditingController();
  
  List<SolicitudAdopcion> _allSolicitudes = [];
  List<SolicitudAdopcion> _filteredSolicitudes = [];
  bool _isLoading = true;
  String _selectedEspecie = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _adopcionService.getAllSolicitudes();
    setState(() {
      _allSolicitudes = data;
      _filteredSolicitudes = data;
      _isLoading = false;
    });
  }

  void _filterSolicitudes(String query) {
    setState(() {
      _filteredSolicitudes = _allSolicitudes.where((s) {
        final matchesSearch = s.nombreSolicitante.toLowerCase().contains(query.toLowerCase()) ||
                             s.animalNombre.toLowerCase().contains(query.toLowerCase());
        final matchesEspecie = _selectedEspecie == 'Todas' || s.animalEspecie == _selectedEspecie;
        return matchesSearch && matchesEspecie;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFB388FF)))
        : Column(
            children: [
              _buildPurpleHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildSearchAndFilter(),
                        const SizedBox(height: 20),
                        _buildStatsGrid(),
                        const SizedBox(height: 20),
                        _buildListSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildPurpleHeader() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  const SizedBox(width: 5),
                  Text("Volver", style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SolicitudFormPage(
                        animalId: 1, 
                        animalNombre: 'Kuro',
                      ),
                    ),
                  ).then((_) => _loadData());
                },
                child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text("Solicitud de adopción", 
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("Mascotas registradas", 
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withOpacity(0.9))),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: Colors.grey, size: 20),
              const SizedBox(width: 10),
              Text("Buscar", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            onChanged: _filterSolicitudes,
            decoration: InputDecoration(
              hintText: "Mascota o propietario",
              hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
              filled: true,
              fillColor: const Color(0xFFF1F4FA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.grey, size: 20),
              const SizedBox(width: 10),
              Text("Filtrar por especie", style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedEspecie,
                isExpanded: true,
                items: ['Todas', 'Canino', 'Felino', 'Ave']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.outfit())))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedEspecie = val!;
                    _filterSolicitudes(_searchController.text);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.8,
      children: [
        _buildStatCard("TOTAL", _allSolicitudes.length.toString(), const Color(0xFFF3E5F5), const Color(0xFF9C27B0)),
        _buildStatCard("Pendientes", _allSolicitudes.where((s) => s.estadoId == 1).length.toString(), const Color(0xFFE3F2FD), const Color(0xFF1976D2)),
        _buildStatCard("Aprobados", _allSolicitudes.where((s) => s.estadoId == 2).length.toString(), const Color(0xFFE8F5E9), const Color(0xFF388E3C)),
        _buildStatCard("Rechazados", _allSolicitudes.where((s) => s.estadoId == 3).length.toString(), const Color(0xFFFFEBEE), const Color(0xFFD32F2F)),
      ],
    );
  }

  Widget _buildStatCard(String label, String count, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: textColor.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(count, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
          Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildListSection() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredSolicitudes.length,
      itemBuilder: (context, index) {
        final solicitud = _filteredSolicitudes[index];
        return _buildRequestCard(solicitud);
      },
    );
  }

  Widget _buildRequestCard(SolicitudAdopcion solicitud) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("23/02/2025", style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)), // En el modelo es fechaSolicitud
              _buildStatusBadge(solicitud),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const CircleAvatar(backgroundColor: Color(0xFFF3E5F5), child: Icon(Icons.pets, size: 18, color: Color(0xFFB388FF))),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(solicitud.nombreSolicitante, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Solicitud para adoptar a: ${solicitud.animalNombre}", style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildInfoRow(Icons.email_outlined, solicitud.correoSolicitante),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone_outlined, solicitud.telefonoSolicitante),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.face_unlock_outlined, solicitud.experienciaAnimales.isEmpty ? "No tiene otras mascotas" : "Con experiencia"),
          const SizedBox(height: 20),
          
          if (solicitud.estadoId == 1) // Pendiente
            Row(
              children: [
                _buildCardButton("Ver detalles", Colors.grey[200]!, Colors.black87, () {
                  _navigateToDetail(solicitud.id);
                }),
                const SizedBox(width: 10),
                _buildCardButton("Aprobar", const Color(0xFFBBF2E0), const Color(0xFF2D6A4F), () {}),
                const SizedBox(width: 10),
                _buildCardButton("Rechazar", const Color(0xFFFFEBEE), const Color(0xFFD32F2F), () {}),
              ],
            )
          else if (solicitud.estadoId == 2) // Aprobada
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFBBF2E0).withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF2D6A4F), size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text("Solicitud aprobada. Se ha contactado al solicitante", style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF2D6A4F)))),
                ],
              ),
            )
          else // Rechazada
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.cancel, color: Color(0xFFD32F2F), size: 18),
                  const SizedBox(width: 8),
                  Text("Solicitud rechazada.", style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFFD32F2F))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(SolicitudAdopcion solicitud) {
    Color color;
    Color textColor;
    switch (solicitud.estadoId) {
      case 2:
        color = const Color(0xFFBBF2E0);
        textColor = const Color(0xFF2D6A4F);
        break;
      case 3:
        color = const Color(0xFFFFCCBC);
        textColor = const Color(0xFFD84315);
        break;
      default:
        color = const Color(0xFFFFF9C4);
        textColor = const Color(0xFFFBC02D);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(solicitud.estadoNombre, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600]))),
      ],
    );
  }

  Widget _buildCardButton(String text, Color color, Color textColor, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
          child: Text(text, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
        ),
      ),
    );
  }

  void _navigateToDetail(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SolicitudDetallePage(solicitudId: id)),
    ).then((_) => _loadData()); // Recargar datos al volver
  }
}
