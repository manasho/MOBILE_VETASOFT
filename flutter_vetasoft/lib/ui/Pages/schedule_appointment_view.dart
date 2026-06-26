import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/cita_model.dart';
import '../../../services/api_service.dart';
import '../../../services/citas_service.dart';
import '../../../services/animal_service.dart';
import '../../../services/cliente_service.dart';
import '../../../services/vet_service.dart';

class ScheduleAppointmentView extends StatefulWidget {
  const ScheduleAppointmentView({super.key});

  @override
  State<ScheduleAppointmentView> createState() =>
      _ScheduleAppointmentViewState();
}

class _ScheduleAppointmentViewState extends State<ScheduleAppointmentView>
    with SingleTickerProviderStateMixin {
  // ── Paleta ────────────────────────────────────────────────────────────────
  static const Color _purple = Color(0xFF755198);
  static const Color _purpleLight = Color(0xFFEFECF5);
  static const Color _labelColor = Color(0xFF2D2255);
  static const Color _inputBg = Color(0xFFEFECF5);
  static const Color _bgScaffold = Color(0xFFF3F0FA);

  // ── Controladores ─────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _motivoCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();

  // ── Datos cargados ────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _animales = [];
  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _veterinarios = [];
  List<Map<String, dynamic>> _tiposConsulta = [];

  // ── Seleccionados ─────────────────────────────────────────────────────────
  int? _animalId;
  int? _clienteId;
  int? _veterinarioId;
  int? _tipoConsultaId;
  DateTime? _fechaSeleccionada;
  int _estadoId = 2; // 2 = Pendiente por defecto

  // ── Estado UI ─────────────────────────────────────────────────────────────
  bool _cargando = true;
  String? _errorCarga;
  bool _enviando = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  // Estados disponibles (según BD estándar Vetasoft)
  final List<Map<String, dynamic>> _estados = [
    {'id': 1, 'nombre': 'Confirmada'},
    {'id': 2, 'nombre': 'Pendiente'},
    {'id': 3, 'nombre': 'Cancelada'},
    {'id': 4, 'nombre': 'Completada'},
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _cargarDatos();
  }

  @override
  void dispose() {
    _motivoCtrl.dispose();
    _observacionesCtrl.dispose();
    _fechaCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Carga de datos ────────────────────────────────────────────────────────
  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });
    try {
      final api = ApiService();

      // Helper local
      List<Map<String, dynamic>> toList(dynamic data) {
        final raw = (data is Map) ? (data['data'] ?? data) : data;
        if (raw is List) return raw.whereType<Map<String, dynamic>>().toList();
        return [];
      }

      // Animales
      final resAnimales = await api.get('animales');
      final animales = toList(resAnimales.data);

      // Clientes
      final resClientes = await api.get('clientes');
      final clientes = toList(resClientes.data);

      // Veterinarios
      final resVets = await api.get('veterinarios');
      final veterinarios = toList(resVets.data);

      // Tipos de consulta — endpoint correcto del backend
      List<Map<String, dynamic>> tiposConsulta = [];
      try {
        final res = await api.get('catalogos/tipo-consulta');
        tiposConsulta = toList(res.data);
      } catch (_) { /* fallback a lista local si el endpoint falla */ }
      if (tiposConsulta.isEmpty) {
        tiposConsulta = [
          {'tipo_consulta_id': 1, 'nombre': 'Consulta general'},
          {'tipo_consulta_id': 2, 'nombre': 'Vacunación'},
          {'tipo_consulta_id': 3, 'nombre': 'Cirugía'},
          {'tipo_consulta_id': 4, 'nombre': 'Desparasitación'},
          {'tipo_consulta_id': 5, 'nombre': 'Control de peso'},
          {'tipo_consulta_id': 6, 'nombre': 'Urgencia'},
        ];
      }

      setState(() {
        _animales = animales;
        _clientes = clientes;
        _veterinarios = veterinarios;
        _tiposConsulta = tiposConsulta;
        _cargando = false;
      });
      _animCtrl.forward();
    } catch (e) {
      setState(() {
        _errorCarga = e.toString().replaceAll('Exception: ', '');
        _cargando = false;
      });
    }
  }

  // ── Helpers para extraer id/nombre de forma robusta ───────────────────────
  int _getId(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      if (m[k] != null) {
        final v = m[k];
        if (v is int) return v;
        if (v is num) return v.toInt();
        return int.parse(v.toString());
      }
    }
    return 0;
  }

  String _getNombre(
    Map<String, dynamic> m,
    List<String> keys, {
    String fallback = 'Sin nombre',
  }) {
    for (final k in keys) {
      if (m[k] != null && m[k].toString().trim().isNotEmpty) {
        return m[k].toString();
      }
    }
    return fallback;
  }

  // ── Envío del formulario ──────────────────────────────────────────────────
  Future<void> _agendarCita() async {
    if (!_formKey.currentState!.validate()) return;
    if (_animalId == null) {
      _showSnack('Selecciona una mascota');
      return;
    }
    if (_clienteId == null) {
      _showSnack('Selecciona un cliente');
      return;
    }
    if (_veterinarioId == null) {
      _showSnack('Selecciona un veterinario');
      return;
    }
    if (_tipoConsultaId == null) {
      _showSnack('Selecciona el tipo de consulta');
      return;
    }
    if (_fechaSeleccionada == null) {
      _showSnack('Selecciona la fecha de la cita');
      return;
    }

    setState(() => _enviando = true);

    try {
      final fechaStr =
          '${_fechaSeleccionada!.year}-${_fechaSeleccionada!.month.toString().padLeft(2, '0')}-${_fechaSeleccionada!.day.toString().padLeft(2, '0')}';

      final cita = CitaModel(
        animalId: _animalId!,
        clienteId: _clienteId!,
        veterinarioId: _veterinarioId!,
        tipoConsultaId: _tipoConsultaId!,
        fechaCita: fechaStr,
        motivo: _motivoCtrl.text.trim(),
        estadoId: _estadoId,
        observaciones: _observacionesCtrl.text.trim().isNotEmpty
            ? _observacionesCtrl.text.trim()
            : null,
        creadoPor: _clienteId.toString(),
      );

      await ApiService.createCita(cita.toJson());

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      _showSnack('Error: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  // ── Snack & Diálogo ───────────────────────────────────────────────────────
  void _showSnack(String msg, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: error ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: _purpleLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: _purple,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '¡Cita agendada!',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _labelColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'La cita ha sido registrada correctamente en el sistema.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B4A8A), Color(0xFF7B6FBB)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: _purple.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Aceptar',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator(color: _purple))
                : _errorCarga != null
                ? _buildErrorState()
                : FadeTransition(opacity: _fadeAnim, child: _buildForm()),
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
                'Mis citas',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Agendamiento de consulta veterinaria',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Estado de error ───────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: _purple, size: 56),
            const SizedBox(height: 16),
            Text(
              'Error de conexión',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _labelColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorCarga ?? 'No se pudo obtener la información',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _cargarDatos,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Formulario ────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // ── Card: Datos de la cita ─────────────────────────────────────
          _buildCard(
            title: 'Datos de la cita',
            icon: Icons.calendar_month_rounded,
            children: [
              // Fecha
              _buildDatePicker(),
              const SizedBox(height: 14),

              // Tipo de consulta
              _buildDropdown<int>(
                label: 'Tipo de consulta*',
                icon: Icons.medical_services_outlined,
                value: _tipoConsultaId,
                hint: 'Selecciona el tipo',
                items: _tiposConsulta.map((tc) {
                  final id = _getId(tc, [
                    'tipo_consulta_id',
                    'id',
                    'consulta_id',
                  ]);
                  final nombre = _getNombre(tc, [
                    'nombre',
                    'tipo',
                    'nombre_consulta',
                    'descripcion',
                  ]);
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(
                      nombre,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _tipoConsultaId = val),
              ),
              const SizedBox(height: 14),

              // Estado
              _buildDropdown<int>(
                label: 'Estado*',
                icon: Icons.flag_outlined,
                value: _estadoId,
                hint: 'Selecciona estado',
                items: _estados.map((e) {
                  return DropdownMenuItem<int>(
                    value: e['id'] as int,
                    child: Row(children: [_estadoBadge(e['nombre'] as String)]),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _estadoId = val ?? 2),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Card: Participantes ─────────────────────────────────────────
          _buildCard(
            title: 'Participantes',
            icon: Icons.people_alt_outlined,
            children: [
              // Cliente
              _buildDropdown<int>(
                label: 'Cliente (propietario)*',
                icon: Icons.person_outline_rounded,
                value: _clienteId,
                hint: 'Selecciona el cliente',
                items: _clientes.map((c) {
                  final id = _getId(c, ['cliente_id', 'id', 'user_id']);
                  final nombre = _getNombre(c, [
                    'nombre',
                    'nombre_completo',
                    'full_name',
                    'apellido',
                  ]);
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(
                      nombre,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _clienteId = val;
                    // Resetear animal al cambiar cliente
                    _animalId = null;
                  });
                },
              ),
              const SizedBox(height: 14),

              // Mascota
              _buildDropdown<int>(
                label: 'Mascota*',
                icon: Icons.pets_rounded,
                value: _animalId,
                hint: 'Selecciona la mascota',
                items: _animales.map((a) {
                  final id = _getId(a, ['animal_id', 'id', 'mascota_id']);
                  final nombre = _getNombre(a, ['nombre', 'name']);
                  final raza =
                      a['nombre_raza'] ?? a['raza'] ?? a['especie'] ?? '';
                  final display = raza.toString().isNotEmpty
                      ? '$nombre ($raza)'
                      : nombre;
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(
                      display,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _animalId = val),
              ),
              const SizedBox(height: 14),

              // Veterinario
              _buildDropdown<int>(
                label: 'Veterinario*',
                icon: Icons.health_and_safety_outlined,
                value: _veterinarioId,
                hint: 'Selecciona el veterinario',
                items: _veterinarios.map((v) {
                  final id = _getId(v, ['veterinario_id', 'id', 'user_id']);
                  final nombre = _getNombre(v, [
                    'nombre',
                    'nombre_completo',
                    'full_name',
                    'apellido',
                  ]);
                  final especialidad =
                      v['especialidad'] ?? v['especialidades'] ?? '';
                  final display = especialidad.toString().isNotEmpty
                      ? '$nombre — $especialidad'
                      : nombre;
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(
                      display,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _veterinarioId = val),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Card: Motivo y observaciones ───────────────────────────────
          _buildCard(
            title: 'Detalles de la consulta',
            icon: Icons.description_outlined,
            children: [
              _buildTextField(
                label: 'Motivo de la cita*',
                icon: Icons.edit_note_rounded,
                controller: _motivoCtrl,
                hint: 'Ej: Control de vacunas, revisión general...',
                required: true,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                label: 'Observaciones',
                icon: Icons.notes_rounded,
                controller: _observacionesCtrl,
                hint: 'Información adicional relevante (opcional)',
                maxLines: 3,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Botón guardar ──────────────────────────────────────────────
          _buildPrimaryButton(),
        ],
      ),
    );
  }

  // ── Card ──────────────────────────────────────────────────────────────────
  Widget _buildCard({
    required String title,
    required IconData icon,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: _purple),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Divider(color: Colors.grey.shade200, height: 20),
          ...children,
        ],
      ),
    );
  }

  // ── Date Picker ───────────────────────────────────────────────────────────
  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: _labelColor,
            ),
            const SizedBox(width: 6),
            Text(
              'Fecha de la cita*',
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
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: _fechaSeleccionada ?? now,
              firstDate: now,
              lastDate: DateTime(now.year + 2),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: _purple,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              setState(() {
                _fechaSeleccionada = picked;
                _fechaCtrl.text =
                    '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
              });
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: _fechaCtrl,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF2D2D2D),
              ),
              decoration: InputDecoration(
                hintText: 'dd/mm/aaaa',
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
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
          ),
        ),
      ],
    );
  }

  // ── Dropdown genérico ─────────────────────────────────────────────────────
  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: _purple),
              hint: Text(
                hint,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[400]),
              ),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF2D2D2D),
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ── Campo texto ───────────────────────────────────────────────────────────
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? hint,
    bool required = false,
    int maxLines = 1,
  }) {
    return Column(
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
          maxLines: maxLines,
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
    );
  }

  // ── Badge de estado ───────────────────────────────────────────────────────
  Widget _estadoBadge(String nombre) {
    Color color;
    Color bgColor;
    switch (nombre.toLowerCase()) {
      case 'confirmada':
        color = const Color(0xFF2E7D32);
        bgColor = const Color(0xFFE8F5E9);
        break;
      case 'cancelada':
        color = const Color(0xFFC62828);
        bgColor = const Color(0xFFFFEBEE);
        break;
      case 'completada':
        color = const Color(0xFF1565C0);
        bgColor = const Color(0xFFE3F2FD);
        break;
      default: // Pendiente
        color = const Color(0xFFE65100);
        bgColor = const Color(0xFFFFF3E0);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        nombre,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ── Botón primario ────────────────────────────────────────────────────────
  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _enviando
                ? [Colors.grey[400]!, Colors.grey[300]!]
                : [const Color(0xFF5B4A8A), const Color(0xFF7B6FBB)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: !_enviando
              ? [
                  BoxShadow(
                    color: _purple.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: _enviando ? null : _agendarCita,
          icon: _enviando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.event_available_rounded,
                  color: Colors.white,
                  size: 20,
                ),
          label: Text(
            _enviando ? 'Agendando...' : 'Confirmar cita',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
