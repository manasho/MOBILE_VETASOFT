import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../services/api_service.dart';
import '../../../services/solicitud_adopcion_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class SolicitudFormPage extends StatefulWidget {
  final int animalId;
  final String animalNombre;

  const SolicitudFormPage({
    super.key, 
    required this.animalId, 
    required this.animalNombre
  });

  @override
  State<SolicitudFormPage> createState() => _SolicitudFormPageState();
}

class _SolicitudFormPageState extends State<SolicitudFormPage> {
  final _formKey = GlobalKey<FormState>();
  final SolicitudAdopcionService _adopcionService = SolicitudAdopcionService();

  // Controllers
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _experienciaController = TextEditingController();
  final TextEditingController _motivo1Controller = TextEditingController();

  // Selected values
  bool _aceptaTerminos = false;
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPurpleHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 20),
                    
                    _buildSectionCard("Datos personales", Icons.person_outline, [
                      _buildTextField("Nombre completo *", _nombreController),
                      _buildTextField("Correo electrónico *", _correoController, keyboardType: TextInputType.emailAddress),
                      _buildTextField("Teléfono *", _telefonoController, keyboardType: TextInputType.phone),
                      _buildTextField("Dirección *", _direccionController),
                    ]),
                    
                    const SizedBox(height: 20),

                    _buildSectionCard("Experiencia y Motivación", Icons.favorite_border, [
                      _buildTextField("Experiencia previa con mascotas *", _experienciaController, isMultiline: true, hint: "Cuéntanos sobre tu experiencia con mascotas..."),
                      _buildTextField("¿Por qué quieres adoptarlo? *", _motivo1Controller, isMultiline: true, hint: "Cuéntanos tu motivación para adoptar..."),
                    ]),

                    const SizedBox(height: 20),

                    _buildTermsSection(),

                    const SizedBox(height: 30),

                    _buildSubmitButton(),

                    const SizedBox(height: 20),
                    _buildFooterInfo(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
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
          Text("Solicitud de adopción", 
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("Formulario para adoptar a ${widget.animalNombre}", 
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.white.withOpacity(0.9))),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
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
          Text("¡Que emoción!", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            "Estás a un paso de darle un hogar a ${widget.animalNombre}. Por favor completa el siguiente formulario y nos pondremos en contacto contigo.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isMultiline = false, String? hint, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          TextFormField(
            controller: controller,
            maxLines: isMultiline ? 4 : 1,
            keyboardType: keyboardType,
            style: GoogleFonts.outfit(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8F9FE),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Campo requerido';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _aceptaTerminos,
              onChanged: (val) => setState(() => _aceptaTerminos = val ?? false),
              activeColor: const Color(0xFFB388FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Acepto términos y condiciones *", style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                Text(
                  "Me comprometo a cuidar responsablemente de la mascota y a proporcionar un hogar seguro y amoroso.",
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isSending ? null : _submitRequest,
      child: Container(
        width: double.infinity,
        height: 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFD188FF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: const Color(0xFFD188FF).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: _isSending 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text("Enviar solicitud", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFF1976D2), size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF0D47A1)),
                    children: const [
                      TextSpan(text: "Proceso siguiente: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: "Revisaremos tu solicitud en 24-48 horas y te contactaremos para coordinar una visita al refugio."),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Debes aceptar los términos y condiciones")));
      return;
    }

    setState(() => _isSending = true);

    // 1. Extraemos el ID del usuario actual del token
    final String token = ApiService.currentToken;
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    final dynamic rawUserId = decodedToken['userId'];
    
    // IMPORTANTE: Convertir a int? para asegurar que el JSON lleve un número y no un String
    final int? currentUserId = (rawUserId == null || rawUserId == 0) 
        ? null 
        : int.tryParse(rawUserId.toString());

    // 2. Preparamos el payload con TIPOS DE DATOS EXACTOS para Postgres
    final payload = {
      'animal_id': widget.animalId, // Ya es int
      'nombre_solicitante': _nombreController.text.trim(),
      'correo_solicitante': _correoController.text.trim(),
      'telefono_solicitante': _telefonoController.text.trim(),
      'direccion_solicitante': _direccionController.text.trim(),
      'experiencia_animales': _experienciaController.text.trim().isEmpty ? "Sin experiencia" : _experienciaController.text.trim(),
      'motivo': _motivo1Controller.text.trim().isEmpty ? "Interés en adopción" : _motivo1Controller.text.trim(),
      'estado_id': 1, 
      'usuario_id': currentUserId,
    };

    final result = await _adopcionService.createSolicitud(payload);
    
    setState(() => _isSending = false);

    if (result) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al enviar la solicitud (500). Verifica los datos.")));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("¡Listo!", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text("Tu solicitud para adoptar a ${widget.animalNombre} ha sido enviada con éxito.", style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cierra dialogo
              Navigator.pop(context); // Vuelve a la lista
            },
            child: Text("Cerrar", style: GoogleFonts.outfit(color: const Color(0xFFB388FF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
