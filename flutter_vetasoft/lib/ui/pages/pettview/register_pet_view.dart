import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/cliente_model.dart';
import '../../../models/animal_model.dart';
import '../../../services/cliente_service.dart';
import '../../../services/animal_service.dart';

class RegisterPetView extends StatefulWidget {
  final ClienteModel clienteData;

  const RegisterPetView({super.key, required this.clienteData});

  @override
  State<RegisterPetView> createState() => _RegisterPetViewState();
}

class _RegisterPetViewState extends State<RegisterPetView> {
  final _formKey = GlobalKey<FormState>();

  // Servicios
  final ClienteService _clienteService = ClienteService();
  final AnimalService _animalService = AnimalService();

  // Controladores
  final _nombreCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _fechaNacimCtrl = TextEditingController();
  final _chipCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();

  // Razas
  List<Map<String, dynamic>> _razas = [];
  int? _razaIdSeleccionada;
  String? _razaNombreSeleccionada;
  bool _cargandoRazas = true;
  String? _errorRazas;

  // Sexo
  String _sexoSeleccionado = 'Macho';
  final List<String> _sexos = ['Macho', 'Hembra'];

  bool _enviando = false;

  // ── Colores ───────────────────────────────────────────────────────────────
  static const Color _purple = Color(0xFF755198);
  static const Color _labelColor = Color(0xFF2D2255);
  static const Color _inputBg = Color(0xFFEFECF5);

  @override
  void initState() {
    super.initState();
    _cargarRazas();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _edadCtrl.dispose();
    _pesoCtrl.dispose();
    _fechaNacimCtrl.dispose();
    _chipCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarRazas() async {
    try {
      final razas = await _animalService.getRazas();
      setState(() {
        _razas = razas;
        _cargandoRazas = false;
      });
    } catch (e) {
      setState(() {
        _errorRazas = 'No se pudieron cargar las razas';
        _cargandoRazas = false;
      });
    }
  }

  Future<void> _onFinalizar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_razaIdSeleccionada == null) {
      _showSnack('Por favor selecciona una raza');
      return;
    }

    setState(() => _enviando = true);

    try {
      // 1️⃣ Crear cliente → obtener cliente_id
      final clienteId = await _clienteService.createCliente(
        widget.clienteData.toJson(),
      );

      // Verificación de seguridad para evitar enviar null al siguiente paso
      if (clienteId == 0) {
        throw Exception('La API no devolvió un ID de cliente válido.');
      }

      // 2️⃣ Crear animal con el cliente_id obtenido
      final animal = AnimalModel(
        cliente_id: clienteId,
        nombre: _nombreCtrl.text.trim(),
        raza_id: _razaIdSeleccionada!,
        // Aseguramos que edad y peso no sean nulos para cumplir con el esquema (NOT NULL)
        edad: int.tryParse(_edadCtrl.text) ?? 0,
        peso: double.tryParse(_pesoCtrl.text.replaceAll(',', '.')) ?? 0.1,
        sexo: _sexoSeleccionado,
        fecha_nacimiento: _fechaNacimCtrl.text.isNotEmpty
            ? _fechaNacimCtrl.text.trim()
            : null,
        numero_chip: _chipCtrl.text.trim().isNotEmpty
            ? _chipCtrl.text.trim()
            : null,
        // Descripción marcada como NOT NULL en DB -> enviamos valor por defecto si está vacía
        descripcion: _observacionesCtrl.text.trim().isNotEmpty 
            ? _observacionesCtrl.text.trim() 
            : 'Sin observaciones',
        estado_animal: 'Con dueño', // ✅ Corregido con C mayúscula según esquema
      );

      await _animalService.createAnimal(animal.toJson());

      if (mounted) {
        _showSuccessDialog(clienteId);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Error: ${e.toString().replaceAll('Exception: ', '')}');
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter()),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog(int clienteId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFEFECF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: _purple, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              '¡Registro exitoso!',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _labelColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'El cliente y su mascota han sido registrados correctamente.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // Cerrar diálogo y volver al inicio
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
                child: Text(
                  'Aceptar',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FA),
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          _buildHeader(),

          // ── Contenido ─────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Card Información básica
                    _buildCard(
                      title: 'Información básica',
                      children: [
                        _buildField(
                          label: 'Nombre*',
                          icon: Icons.badge_outlined,
                          controller: _nombreCtrl,
                          required: true,
                        ),
                        _buildRazaDropdown(),
                        _buildSexoDropdown(),
                        _buildField(
                          label: 'Edad*',
                          icon: Icons.cake_outlined,
                          controller: _edadCtrl,
                          keyboardType: TextInputType.number,
                          hint: 'Años (0-150)',
                          required: true,
                        ),
                        _buildField(
                          label: 'Peso*',
                          icon: Icons.monitor_weight_outlined,
                          controller: _pesoCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          hint: 'Kg (ej: 4.5)',
                          required: true,
                        ),
                        _buildPetDateField(),
                        _buildField(
                          label: 'Número de chip',
                          icon: Icons.nfc,
                          controller: _chipCtrl,
                          hint: 'Ej: CHIP123456',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Card Información adicional
                    _buildCard(
                      title: 'Información adicional',
                      subtitle: 'Observaciones (opcional)',
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F5FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFDDD8ED)),
                          ),
                          child: TextFormField(
                            controller: _observacionesCtrl,
                            maxLines: 4,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF2D2D2D),
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Información sobre alergias,\ncomportamiento, preferencias, etc.',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey[400],
                                height: 1.4,
                              ),
                              filled: false,
                              contentPadding: const EdgeInsets.all(14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Botón Finalizar
                    _buildPrimaryButton(
                      label: _enviando
                          ? 'Registrando...'
                          : 'Finalizar registro',
                      onPressed: _enviando ? null : _onFinalizar,
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
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  'Volver',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
              const SizedBox(height: 4),
              Text(
                'Datos mascota',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Registra los datos de un acompañante',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card contenedor ───────────────────────────────────────────────────────
  Widget _buildCard({
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _labelColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // ── Campo fecha nacimiento mascota ─────────────────────────────────────────
  Widget _buildPetDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 16,
                color: _labelColor,
              ),
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
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 365)),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: _purple,
                      onPrimary: Colors.white,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                setState(() {
                  _fechaNacimCtrl.text =
                      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                });
              }
            },
            child: AbsorbPointer(
              child: TextFormField(
                controller: _fechaNacimCtrl,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF2D2D2D),
                ),
                decoration: InputDecoration(
                  hintText: 'AAAA-MM-DD',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    color: _purple,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: _inputBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
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

  // ── Campo genérico ────────────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
    String? hint,
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
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF2D2D2D),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              filled: true,
              fillColor: _inputBg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
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
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
            validator: required
                ? (v) =>
                      (v == null || v.trim().isEmpty) ? 'Campo requerido' : null
                : null,
          ),
        ],
      ),
    );
  }

  // ── Dropdown Raza (carga dinámica) ────────────────────────────────────────
  /// Extrae el id de una raza de forma segura sin importar si viene como int o num
  int _getRazaId(Map<String, dynamic> r) {
    final raw = r['raza_id'] ?? r['id'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.parse(raw.toString());
  }

  String _getRazaNombre(Map<String, dynamic> r) {
    // El backend devuelve: raza_id, nombre_raza, nombre_especie, descripcion
    final raza = r['nombre_raza'] ?? r['nombre'] ?? r['name'] ?? 'Sin nombre';
    final especie = r['nombre_especie'];
    // Muestra "Labrador (Perro)" para mejor UX
    if (especie != null && especie.toString().isNotEmpty) {
      return '$raza (${especie.toString()})';
    }
    return raza.toString();
  }

  Widget _buildRazaDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pets, size: 16, color: _labelColor),
              const SizedBox(width: 6),
              Text(
                'Raza*',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (_cargandoRazas)
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: _inputBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _purple,
                  ),
                ),
              ),
            )
          else if (_errorRazas != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _inputBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorRazas!,
                      style: GoogleFonts.inter(color: Colors.red, fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _cargandoRazas = true;
                        _errorRazas = null;
                      });
                      _cargarRazas();
                    },
                    child: Text(
                      'Reintentar',
                      style: GoogleFonts.inter(color: _purple, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: _inputBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _razaIdSeleccionada,
                  isExpanded: true,
                  hint: Text(
                    'Selecciona una raza',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[400],
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down, color: _purple),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF2D2D2D),
                  ),
                  items: _razas.map((r) {
                    final id = _getRazaId(r);
                    final nombre = _getRazaNombre(r);
                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(nombre),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    final raza = _razas.firstWhere((r) => _getRazaId(r) == val);
                    setState(() {
                      _razaIdSeleccionada = val;
                      _razaNombreSeleccionada = _getRazaNombre(raza);
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Dropdown Sexo ─────────────────────────────────────────────────────────
  Widget _buildSexoDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.transgender, size: 16, color: _labelColor),
              const SizedBox(width: 6),
              Text(
                'Sexo',
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
                value: _sexoSeleccionado,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: _purple),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF2D2D2D),
                ),
                items: _sexos.map((s) {
                  return DropdownMenuItem<String>(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _sexoSeleccionado = val);
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
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: onPressed == null
                ? [Colors.grey[400]!, Colors.grey[300]!]
                : [const Color(0xFF5B4A8A), const Color(0xFF7B6FBB)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: onPressed != null
              ? [
                  BoxShadow(
                    color: _purple.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: onPressed,
          child: _enviando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
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
