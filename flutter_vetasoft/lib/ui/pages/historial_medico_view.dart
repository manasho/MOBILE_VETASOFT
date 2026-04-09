import 'package:flutter/material.dart';
import '../../services/service_historial_medico.dart';
import '../../models/historial_medico_model.dart';
import 'ver_registro_view.dart';  
import 'agregar_registro_view.dart';

class HistorialMedicoView extends StatefulWidget {
  final String nombreMascota;
  final int animalId;

  const HistorialMedicoView({
    super.key,
    required this.nombreMascota,
    required this.animalId,
  });

  @override
  State<HistorialMedicoView> createState() => _HistorialMedicoViewState();
}

class _HistorialMedicoViewState extends State<HistorialMedicoView> {
  List<HistorialMedico> historial = [];
  bool loading = true;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      loadHistorial();
    }
  }

  Future<void> loadHistorial() async {
    try {
      final data = await ApiServiceHistorial.obtenerHistorialPorAnimal(widget.animalId);

      setState(() {
        historial = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _formatearFecha(DateTime fecha) {
    final meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
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
          _header(),
          _btnAgregar(),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : historial.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: historial.length,
                        itemBuilder: (_, i) => _card(historial[i]),
                      ),
          )
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        12,
        MediaQuery.of(context).padding.top + 8,
        12,
        12,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back, color: Colors.white, size: 13),
                SizedBox(width: 8),
                Text('Volver', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Historial medico',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.nombreMascota,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
Widget _btnAgregar() {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Align(
      alignment: Alignment.centerRight,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5D9CC5), Color(0xFF664492)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ElevatedButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AgregarRegistroView(
                  nombreMascota: widget.nombreMascota,
                  animalId: widget.animalId,
                ),
              ),
            );
            if (result == true) {
              loadHistorial(); // Recargar la lista después de guardar
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Agregar registro +'),
        ),
      ),
    ),
  );
}

  Widget _card(HistorialMedico item) {
    return IntrinsicHeight(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Línea degradada
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF5D9CC5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header de la card con el ojito navegable
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cita',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // NAVEGACIÓN AL VER REGISTRO
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VerRegistroView(
                                  historial: item,
                                  nombreMascota: widget.nombreMascota,
                                ),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.remove_red_eye_outlined,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Fecha
                    Text(
                      _formatearFecha(item.fechaCreacion),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _campo('Observaciones',
                        item.observaciones.isNotEmpty ? item.observaciones : 'N/A'),

                    _campo('Diagnostico',
                        item.diagnostico.isNotEmpty ? item.diagnostico : 'No especificado'),

                    _campo('Próximo control',
                        _formatearFechaNullable(item.proximaCita)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(color: Colors.grey[600]),
            ),
            WidgetSpan(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  valor,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text(
        'Esta mascota no ha tenido citas al momento.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    );
  }
}