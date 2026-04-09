import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/cliente_model.dart';
import 'register_pet_view.dart';

class RegisterClientView extends StatefulWidget {
  const RegisterClientView({super.key});

  @override
  State<RegisterClientView> createState() => _RegisterClientViewState();
}

class _RegisterClientViewState extends State<RegisterClientView> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nombreCtrl = TextEditingController();
  final _documentoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();

  String _rolSeleccionado = 'Cliente';
  final List<String> _roles = ['Cliente', 'Empleado'];

  // ── Colores del tema ──────────────────────────────────────────────────────
  static const Color _purple = Color(0xFF755198);
  static const Color _inputBg = Color(0xFFEFECF5);
  static const Color _labelColor = Color(0xFF4A3560);

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _documentoCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    _fechaCtrl.dispose();
    super.dispose();
  }

  void _onSiguiente() {
    if (!_formKey.currentState!.validate()) return;

    final cliente = ClienteModel(
      nombre: _nombreCtrl.text.trim(),
      documentoId: _documentoCtrl.text.trim(),
      correo: _correoCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      fechaNacimiento: _fechaCtrl.text.trim(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterPetView(clienteData: cliente),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _purple,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _fechaCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FA),
      body: Column(
        children: [
          // ── Header degradado ──────────────────────────────────────────────
          _buildHeader(),

          // ── Formulario ───────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Registro de cliente',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _labelColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confirma los datos para el registro',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildField(
                      label: 'Nombre completo*',
                      icon: Icons.person_outline,
                      controller: _nombreCtrl,
                      required: true,
                    ),
                    _buildField(
                      label: 'Número de documento',
                      icon: Icons.badge_outlined,
                      controller: _documentoCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    _buildField(
                      label: 'Correo electrónico*',
                      icon: Icons.email_outlined,
                      controller: _correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      required: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo requerido';
                        if (!v.contains('@')) return 'Correo inválido';
                        return null;
                      },
                    ),
                    _buildField(
                      label: 'Teléfono*',
                      icon: Icons.phone_outlined,
                      controller: _telefonoCtrl,
                      keyboardType: TextInputType.phone,
                      required: true,
                    ),
                    _buildField(
                      label: 'Dirección*',
                      icon: Icons.location_on_outlined,
                      controller: _direccionCtrl,
                      required: true,
                    ),

                    // Fecha de nacimiento (picker)
                    _buildDateField(),

                    // Rol dropdown
                    _buildRolDropdown(),

                    const SizedBox(height: 32),

                    // Botón Siguiente
                    _buildPrimaryButton(
                      label: 'Siguiente',
                      onPressed: _onSiguiente,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A3A7A), Color(0xFF5B8CD6)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Botón Volver
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                label: Text(
                  'Volver',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Avatar
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                gradient: const LinearGradient(
                  colors: [Color(0xFF9B6FC4), Color(0xFF5B8CD6)],
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=200&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.pets,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Campo de texto genérico ───────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _labelColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2D2D)),
            decoration: InputDecoration(
              filled: true,
              fillColor: _inputBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _purple, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
            validator: validator ??
                (required
                    ? (v) =>
                        (v == null || v.trim().isEmpty) ? 'Campo requerido' : null
                    : null),
          ),
        ],
      ),
    );
  }

  // ── Campo fecha ───────────────────────────────────────────────────────────
  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: _labelColor),
              const SizedBox(width: 6),
              Text(
                'Fecha de nacimiento',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDate,
            child: AbsorbPointer(
              child: TextFormField(
                controller: _fechaCtrl,
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2D2D)),
                decoration: InputDecoration(
                  hintText: 'AAAA-MM-DD',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  suffixIcon: const Icon(Icons.calendar_month_outlined, color: _purple, size: 20),
                  filled: true,
                  fillColor: _inputBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _purple, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dropdown Rol ──────────────────────────────────────────────────────────
  Widget _buildRolDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: _labelColor),
              const SizedBox(width: 6),
              Text(
                'Rol',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: _inputBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _rolSeleccionado,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: _purple),
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2D2D)),
                items: _roles.map((rol) {
                  return DropdownMenuItem<String>(
                    value: rol,
                    child: Text(rol),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _rolSeleccionado = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Botón primario ────────────────────────────────────────────────────────
  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5B4A8A), Color(0xFF7B6FBB)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _purple.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
