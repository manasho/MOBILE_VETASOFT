import 'package:flutter/material.dart';
import '../../services/service_historial_medico.dart';
import '../../services/service_auth.dart';
import '../../services/service_citas.dart';
import '../../services/api_service.dart';
import '../../models/historial_medico_model.dart';

class AgregarRegistroView extends StatefulWidget {
  final String nombreMascota;
  final int animalId;

  const AgregarRegistroView({
    super.key,
    required this.nombreMascota,
    required this.animalId,
  });

  @override
  State<AgregarRegistroView> createState() => _AgregarRegistroViewState();
}

class _AgregarRegistroViewState extends State<AgregarRegistroView> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _cargandoTipos = true;
  
  List<Map<String, dynamic>> _tiposConsulta = [];
  int? _tipoConsultaId;
  
  DateTime? _fechaConsulta;
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _sintomasController = TextEditingController();
  final TextEditingController _tratamientoController = TextEditingController();
  final TextEditingController _medicamentosController = TextEditingController();
  final TextEditingController _examenesController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _temperaturaController = TextEditingController();
  final TextEditingController _frecuenciaCardiacaController = TextEditingController();
  final TextEditingController _frecuenciaRespiratoriaController = TextEditingController();
  DateTime? _proximaCita;

  List<Map<String, dynamic>> _citasActivas = [];
  int? _citaId;
  bool _cargandoCitas = true;

  @override
  void initState() {
    super.initState();
    _cargarTiposConsulta();
    _cargarCitasActivas();
  }

  Future<void> _cargarCitasActivas() async {
    setState(() => _cargandoCitas = true);
    try {
      final citas = await ApiServiceCitas.obtenerCitasPorAnimalYEstado(widget.animalId, 3);
      setState(() {
        _citasActivas = citas.map((c) {
          return {
            ...c,
            'cita_id': int.tryParse(c['cita_id'].toString()) ?? 0,
          };
        }).toList();
        _cargandoCitas = false;
        if (_citasActivas.length == 1) {
          _citaId = _citasActivas[0]['cita_id'];
        }
      });
    } catch (e) {
      setState(() => _cargandoCitas = false);
      print('❌ Error cargando citas: $e');
    }
  }

  Future<void> _cargarTiposConsulta() async {
    setState(() => _cargandoTipos = true);
    try {
      final tipos = await ApiServiceHistorial.obtenerTiposConsulta();
      setState(() {
        _tiposConsulta = tipos.map((t) {
          return {
            ...t,
            'id': int.tryParse((t['tipo_consulta_id'] ?? t['id']).toString()) ?? 0,
            'nombre': t['nombre'] ?? t['nombre_consulta'] ?? 'Sin nombre',
          };
        }).toList();
        _cargandoTipos = false;
      });
    } catch (e) {
      setState(() => _cargandoTipos = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando tipos de consulta: $e')),
        );
      }
    }
  }

  Future<void> _guardarRegistro() async {
    if (!_formKey.currentState!.validate()) return;
    if (_citaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar una cita activa')),
      );
      return;
    }
    if (_tipoConsultaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un tipo de consulta')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Intentamos obtener el usuario logueado (veterinario)
      final int? veterinarioIdValue = await AuthService.obtenerUsuarioId();

      final data = {
        "cita_id": _citaId,
        "veterinario_id": veterinarioIdValue ?? 2,
        "tipo_consulta_id": _tipoConsultaId,
        "fecha_consulta": _fechaConsulta?.toIso8601String().split('T').first ?? 
                         DateTime.now().toIso8601String().split('T').first,
        "sintomas": _sintomasController.text,
        "diagnostico": _diagnosticoController.text,
        "tratamiento": _tratamientoController.text,
        "examenes_realizados": _examenesController.text,
        "medicamentos": _medicamentosController.text,
        "proxima_cita": _proximaCita?.toIso8601String().split('T').first,
        "observaciones": _observacionesController.text,
        "peso": double.tryParse(_pesoController.text) ?? 0,
        "temperatura": double.tryParse(_temperaturaController.text) ?? 0,
        "frecuencia_cardiaca": int.tryParse(_frecuenciaCardiacaController.text) ?? 0,
        "frecuencia_respiratoria": int.tryParse(_frecuenciaRespiratoriaController.text) ?? 0,
      };

      print('📤 Enviando datos mediante servicio: $data');

      final success = await ApiServiceHistorial.guardarRegistro(data);

      if (success) {
        // SI SE VINCULÓ UNA CITA, ACTUALIZAR SU ESTADO A 4 (FINALIZADA)
        if (_citaId != null) {
          print('📡 Finalizando cita $_citaId...');
          await ApiServiceCitas.actualizarEstadoCita(_citaId!, 4);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro guardado y cita finalizada exitosamente')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _seleccionarFecha(BuildContext context, bool esProxima) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (esProxima) {
          _proximaCita = picked;
        } else {
          _fechaConsulta = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _informacionBasica(),
                          const SizedBox(height: 16),
                          _datosVitales(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
          ),
          _botonesAccion(),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5D9CC5), Color(0xFF664492)],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agregar registro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'De ${widget.nombreMascota}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _informacionBasica() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              'Información básica',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _dropdownCitasActivas(),
                const SizedBox(height: 12),
                _dropdownTipoConsulta(),
                const SizedBox(height: 12),
                _fechaCampo('Fecha de consulta', _fechaConsulta, () => _seleccionarFecha(context, false)),
                const SizedBox(height: 12),
                _textCampo('Diagnóstico', _diagnosticoController, 'Ej: diagnóstico', required: true),
                const SizedBox(height: 12),
                _textCampo('Síntomas', _sintomasController, 'Ej: síntomas'),
                const SizedBox(height: 12),
                _textCampo('Tratamiento', _tratamientoController, 'Ej: tratamiento'),
                const SizedBox(height: 12),
                _textCampo('Medicamentos', _medicamentosController, 'Ej: medicamento'),
                const SizedBox(height: 12),
                _textCampo('Exámenes realizados', _examenesController, 'Ej: examenes realizados'),
                const SizedBox(height: 12),
                _textCampo('Observaciones', _observacionesController, 'Ej: observaciones'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownCitasActivas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vincular con cita en curso',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: _cargandoCitas
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                )
              : DropdownButtonFormField<int>(
                  value: _citaId,
                  hint: const Text('SELECCIONA UNA CITA (Obligatorio)'),
                  isExpanded: true,
                  items: _citasActivas.map((cita) {
                    return DropdownMenuItem<int>(
                      value: cita['cita_id'],
                      child: Text('Cita #${cita['cita_id']} - ${cita['fecha_cita']}'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _citaId = value),
                  validator: (value) => value == null ? 'Selecciona una cita' : null,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
        ),
      ],
    );
  }

  Widget _dropdownTipoConsulta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de consulta',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: _cargandoTipos
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                )
              : DropdownButtonFormField<int>(
                  value: _tipoConsultaId,
                  hint: const Text('Selecciona un tipo de consulta'),
                  items: _tiposConsulta.map((tipo) {
                    return DropdownMenuItem<int>(
                      value: tipo['id'],
                      child: Text(tipo['nombre']),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _tipoConsultaId = value),
                  decoration: const InputDecoration(border: InputBorder.none),
                  validator: (value) => value == null ? 'Selecciona un tipo de consulta' : null,
                ),
        ),
      ],
    );
  }

  Widget _datosVitales() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              'Datos vitales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _textCampoNumerico('Peso (kg)', _pesoController, 'Ej: 15')),
                    const SizedBox(width: 16),
                    Expanded(child: _textCampoNumerico('Temperatura (°C)', _temperaturaController, 'Ej: 38.5')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _textCampoNumerico('Frecuencia cardíaca', _frecuenciaCardiacaController, 'Ej: 92')),
                    const SizedBox(width: 16),
                    Expanded(child: _textCampoNumerico('Frecuencia respiratoria', _frecuenciaRespiratoriaController, 'Ej: 24')),
                  ],
                ),
                const SizedBox(height: 16),
                _fechaCampo('Próxima consulta', _proximaCita, () => _seleccionarFecha(context, true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textCampo(String label, TextEditingController controller, String hint, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: (value) {
            if (required && (value == null || value.isEmpty)) return 'Este campo es requerido';
            return null;
          },
        ),
      ],
    );
  }

  Widget _textCampoNumerico(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _fechaCampo(String label, DateTime? fecha, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: Text(
              fecha != null ? '${fecha.day}/${fecha.month}/${fecha.year}' : 'DD/MM/AAAA',
              style: TextStyle(color: fecha != null ? Colors.black87 : Colors.grey[500]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _botonesAccion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _guardarRegistro,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF664492),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Guardar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cancelar'),
            ),
          ),
        ],
      ),
    );
  }
}