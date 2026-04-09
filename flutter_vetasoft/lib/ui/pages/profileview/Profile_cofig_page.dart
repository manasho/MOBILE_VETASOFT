import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/app_user.dart';
import '../../../services/user_service.dart';

class ProfileConfigPage extends StatefulWidget {
  const ProfileConfigPage({super.key});

  @override
  State<ProfileConfigPage> createState() => _ProfileConfigPageState();
}

class _ProfileConfigPageState extends State<ProfileConfigPage> {
  final UserService _userService = UserService();

  // Controladores para los formularios
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoaded = false; // 👈 Bandera para cargar solo una vez
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: FutureBuilder<AppUser>(
        future: _userService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Error al cargar perfil"));
          }
          final user = snapshot.data!;
          
          // 🚀 SOLO CARGAMOS LOS DATOS LA PRIMERA VEZ
          if (!_isLoaded) {
            // Si quieres que el usuario vea el texto en gris ATRÁS (como capa),
            // NO llenamos el controller.text aquí, lo pasamos como hintText.
            _isLoaded = true;
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildDarkHeader(context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildProfileAvatar(user),
                      const SizedBox(height: 25),
                      _buildSectionTitle("Información personal"),
                      
                      // 🏠 Pasamos los datos actuales como HINT (la capa gris de atrás)
                      _buildInfoCard(user), 
                      
                      const SizedBox(height: 20),
                      _buildSectionTitle("Configuración de cuenta"),
                      _buildSettingsCard(),
                      const SizedBox(height: 30),
                      _buildSaveButton(),
                      // ... resto del código ..
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }



  
  // --- COMPONENTES DE LA UI ---

  Widget _buildDarkHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20),
      decoration: const BoxDecoration(color: Color(0xFF233E53)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.white, size: 20),
                SizedBox(width: 5),
                Text(
                  "Volver",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Configuración",
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            "Edita tus datos personales",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(AppUser user) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFE0E0FF),
                child: Icon(Icons.person, size: 60, color: Color(0xFF6B4592)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            user.nombre,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(user.correo, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF233E53),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(AppUser user) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          // 👈 Pasamos el dato real como "hint"
          _buildTextField(Icons.person_outline, "Nombre completo", _nameController, user.nombre),
          _buildTextField(Icons.email_outlined, "Correo electrónico", _emailController, user.correo),
          _buildTextField(Icons.phone_outlined, "Teléfono", _phoneController, user.telefono ?? 'No registrado'),
          _buildTextField(Icons.location_on_outlined, "Dirección", _addressController, user.direccion ?? 'No registrada'),
        ],
      ),
    );
  }

  Widget _buildTextField(IconData icon, String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            style: GoogleFonts.outfit(color: Colors.black87, fontSize: 15), // Texto que escribes es negro
            decoration: InputDecoration(
              hintText: hint, // 👈 ESTA ES LA CAPA GRIS DE ATRÁS
              hintStyle: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 15),
              filled: true,
              fillColor: const Color(0xFFF3F5F9),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildListTile("Cambiar contraseña", "Actualiza tu contraseña de ingreso"),
          const Divider(height: 1, indent: 15, endIndent: 15),
          _buildListTile("Notificaciones", "Gestiona tus preferencias de notificación"),
        ],
      ),
    );
  }
  Widget _buildListTile(String title, String sub) {
    return ListTile(
      title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(sub, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {}, // Aquí irá la lógica después
    );
  }
  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(colors: [Color(0xFF5391B4), Color(0xFF6B4592)]),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6B4592).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text("Guardar cambios", 
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
