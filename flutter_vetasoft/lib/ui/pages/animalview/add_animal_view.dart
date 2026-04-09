import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/animal_service.dart';
import '../../../models/animal_model.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class AddAnimalView extends StatefulWidget {
  const AddAnimalView({super.key});

  @override
  State<AddAnimalView> createState() => _AddAnimalViewState();
}

class _AddAnimalViewState extends State<AddAnimalView> {
  final _formKey = GlobalKey<FormState>();

  // Servicio
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
  bool _cargandoRazas = true;
  String? _errorRazas;

  // Sexo
  String _sexoSeleccionado = 'Macho';
  final List<String> _sexos = ['Macho', 'Hembra'];

  // Estado del animal
  String _estadoSeleccionado = 'En adopción';
  final List<String> _estadosAnimal = [
    'con dueño',
    'Adoptado',
    'En adopción'
  ];

  bool _enviando = false;

  // Imagen
  XFile? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

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
      if (mounted) {
        setState(() {
          _errorRazas = 'No se pudieron cargar las razas';
          _cargandoRazas = false;
        });
      }
    }
  }

  void _mostrarOpcionesImagen() {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, color: _purple),
            title: Text('Elegir de galería', style: GoogleFonts.inter()),
            onTap: () {
              Navigator.pop(context);
              _seleccionarImagen(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined, color: _purple),
            title: Text('Tomar foto', style: GoogleFonts.inter()),
            onTap: () {
              Navigator.pop(context);
              _seleccionarImagen(ImageSource.camera);
            },
          ),
          if (_imagenSeleccionada != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                'Eliminar foto',
                style: GoogleFonts.inter(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _imagenSeleccionada = null);
              },
            ),
        ],
      ),
    ),
  );
}

Future<void> _seleccionarImagen(ImageSource source) async {
  try {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked != null) {
      setState(() => _imagenSeleccionada = picked); 
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo acceder a la imagen', style: GoogleFonts.inter()),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }
}

  Future<void> _onGuardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_razaIdSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona una raza', style: GoogleFonts.inter()),
          backgroundColor: Colors.red[700],
        ),
      );
      return;
    }
    
    setState(() => _enviando = true);
    
    try {
      // DESPUÉS
      String? fotoBase64;
      if (_imagenSeleccionada != null) {
        final bytes = await _imagenSeleccionada!.readAsBytes();
        fotoBase64 = base64Encode(bytes);
      }

      final animal = AnimalModel(
        clienteId: 28,
        nombre: _nombreCtrl.text.trim(),
        razaId: _razaIdSeleccionada!,
        edad: _edadCtrl.text.isNotEmpty ? int.tryParse(_edadCtrl.text) : null,
        peso: _pesoCtrl.text.isNotEmpty
            ? double.tryParse(_pesoCtrl.text.replaceAll(',', '.'))
            : null,
        sexo: _sexoSeleccionado,
        fechaNacimiento: _fechaNacimCtrl.text.isNotEmpty ? _fechaNacimCtrl.text.trim() : null,
        descripcion: _observacionesCtrl.text.trim().isNotEmpty ? _observacionesCtrl.text.trim() : 'Sin observaciones',
        numeroChip: _chipCtrl.text.trim().isNotEmpty ? _chipCtrl.text.trim() : null,
        estado: _estadoSeleccionado,
        foto: fotoBase64,  // <-- ahora envía el base64 o null
      );

      await _animalService.createAnimal(animal.toJson());

      if (mounted) {
        setState(() => _enviando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Guardado exitosamente', style: GoogleFonts.inter()),
            backgroundColor: Colors.green,
          ),
        );
        // Limpiar
        _nombreCtrl.clear();
        _edadCtrl.clear();
        _pesoCtrl.clear();
        _fechaNacimCtrl.clear();
        _chipCtrl.clear();
        _observacionesCtrl.clear();
        setState(() {
          _razaIdSeleccionada = null;
          _estadoSeleccionado = 'En adopción';
          _imagenSeleccionada = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _enviando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}', style: GoogleFonts.inter()),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
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
                      isTopCard: true,
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
                          label: 'Edad (Años)',
                          icon: Icons.cake_outlined,
                          controller: _edadCtrl,
                          keyboardType: TextInputType.number,
                          hint: 'Ej: 3',
                        ),
                        _buildPetDateField(),
                        _buildField(
                          label: 'Peso (Kg)',
                          icon: Icons.monitor_weight_outlined,
                          controller: _pesoCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          hint: 'Ej: 4.5',
                        ),
                        _buildField(
                          label: 'Número de chip',
                          icon: Icons.nfc,
                          controller: _chipCtrl,
                          hint: 'Ej: CHIP123456',
                        ),
                        _buildEstadoDropdown(),
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
                            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF2D2D2D)),
                            decoration: InputDecoration(
                              hintText:
                                  'Información sobre comportamiento,\nalergias, descripción preferida, etc.',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey[500],
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

                    // Botón Guardar
                    _buildPrimaryButton(
                      label: _enviando ? 'Guardando...' : 'Guardar mascota',
                      onPressed: _enviando ? null : _onGuardar,
                    ),
                    const SizedBox(height: 14),
                    
                    // Botón Cancelar
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFB73B3B),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    )
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
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                label: Text(
                  'Volver',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
              const SizedBox(height: 4),
              Text(
                'Agregar animal',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Nueva animal en adopción',
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
    bool isTopCard = false,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDCD5EF), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isTopCard) _buildPhotoAvatar(),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _labelColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500),
            ),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // ── Avatar con icono de cámara (Opcional, servirá para abrir galería) ─────
  Widget _buildPhotoAvatar() {
  return Column(
    children: [
      Center(
        child: GestureDetector(
          onTap: _mostrarOpcionesImagen,
          child: Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: _imagenSeleccionada != null
                      ? (kIsWeb
                          ? Image.network(
                              _imagenSeleccionada!.path,
                              fit: BoxFit.cover,
                              width: 90,
                              height: 90,
                            )
                          : Image.file(
                              File(_imagenSeleccionada!.path),
                              fit: BoxFit.cover,
                              width: 90,
                              height: 90,
                            ))
                      : Container(
                          color: const Color(0xFF8675DF),
                          child: const Icon(
                            Icons.pets,
                            size: 45,
                            color: Color(0xFF56678C),
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Container(
        height: 1,
        width: double.infinity,
        color: const Color(0xFFE5E0F2),
        margin: const EdgeInsets.symmetric(horizontal: 20),
      ),
      const SizedBox(height: 16),
    ],
  );
}

  // ── Dropdown Raza (carga dinámica) ────────────────────────────────────────
  int _getRazaId(Map<String, dynamic> r) {
    final raw = r['raza_id'] ?? r['id'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.parse(raw.toString());
  }

  String _getRazaNombre(Map<String, dynamic> r) {
    final raza = r['nombre_raza'] ?? r['nombre'] ?? r['name'] ?? 'Sin nombre';
    final especie = r['nombre_especie'];
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
              const SizedBox(width: 8),
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
          const SizedBox(height: 8),
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
                  child: CircularProgressIndicator(strokeWidth: 2, color: _purple),
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
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[400]),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down, color: _purple),
                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2D2D)),
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
                    setState(() {
                      _razaIdSeleccionada = val;
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
              const SizedBox(width: 8),
              Text(
                'Sexo*',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2D2D)),
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

  // ── Campo fecha nacimiento ────────────────────────────────────────────────
  Widget _buildPetDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, size: 16, color: _labelColor),
              const SizedBox(width: 8),
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
          const SizedBox(height: 8),
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
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2D2D)),
                decoration: InputDecoration(
                  hintText: 'AAAA-MM-DD',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  suffixIcon: const Icon(Icons.calendar_today_outlined, color: _purple, size: 18),
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
              const SizedBox(width: 8),
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
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: _inputBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2D2D)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              validator: required
                  ? (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // ── Dropdown Estado ───────────────────────────────────────────────────────
  Widget _buildEstadoDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: _labelColor),
              const SizedBox(width: 8),
              Text(
                'Estado*',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: _inputBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _estadoSeleccionado,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: _purple),
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF2D2D2D)),
                items: _estadosAnimal.map((estado) {
                  return DropdownMenuItem<String>(
                    value: estado,
                    child: Text(estado),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _estadoSeleccionado = val;
                    });
                  }
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
      width: 250,
      height: 45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF8675C4),
          borderRadius: BorderRadius.circular(25),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          onPressed: onPressed,
          child: _enviando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  label,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
