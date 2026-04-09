import 'package:flutter/material.dart';
import '../../models/historial_medico_model.dart';

class VerRegistroView extends StatefulWidget {
  final HistorialMedico historial;
  final String nombreMascota;

  const VerRegistroView({
    super.key,
    required this.historial,
    required this.nombreMascota,
  });

  @override
  State<VerRegistroView> createState() => _VerRegistroViewState();
}

class _VerRegistroViewState extends State<VerRegistroView> {

  String _formatearFecha(DateTime fecha) {
    final meses = [
      'enero','febrero','marzo','abril','mayo','junio',
      'julio','agosto','septiembre','octubre','noviembre','diciembre'
    ];
    return "${fecha.day} de ${meses[fecha.month - 1]} ${fecha.year}";
  }

  String _formatearFechaNullable(DateTime? fecha) {
    if (fecha == null) return 'DD/MM/AAAA';
    return _formatearFecha(fecha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _card(
                    titulo: 'Información básica',
                    child: Column(
                      children: [
                        _campo('Fecha de consulta',
                            _formatearFecha(widget.historial.fechaCreacion)),
                        _campo('Diagnóstico', widget.historial.diagnostico),
                         _campo('Síntomas', widget.historial.sintomas),
                        _campo('Tratamiento', widget.historial.tratamiento),
                        _campo('Medicamentos', widget.historial.medicamentos),
                         _campo('Exámenes realizados',
                            widget.historial.examenesRealizados),
                        _campo('Observaciones', widget.historial.observaciones),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _card(
                    titulo: 'Datos vitales',
                    icon: Icons.monitor_heart_outlined,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _campo(
                                  'Peso', '${widget.historial.peso} kg'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _campo('Temperatura',
                                  '${widget.historial.temperatura}°'),
                            ),
                          ],
                        ),
                        _campo('Frecuencia cardiaca',
                            '${widget.historial.frecuenciaCardiaca} lpm'),
                        _campo('Frecuencia respiratoria',
                            '${widget.historial.frecuenciaRespiratoria} rpm'),
                        _campo('Próxima consulta',
                            _formatearFechaNullable(
                                widget.historial.proximaCita)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _botonConfirmar(),
        ],
      ),
    );
  }


  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 14,
        16,
        16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5D9CC5), Color(0xFF664492)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.white),
                SizedBox(width: 8),
                Text('Volver', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ver registro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.nombreMascota,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // Cards
  Widget _card({required String titulo, required Widget child, IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF5D9CC5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

 
  Widget _campo(String label, String? valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              (valor != null && valor.isNotEmpty)
                  ? valor
                  : 'No especificado',
            ),
          ),
        ],
      ),
    );
  }

  // BOTÓN CONFIRMAR
  Widget _botonConfirmar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5D9CC5), Color(0xFF664492)],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          child: const Text(
            'Confirmar',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}