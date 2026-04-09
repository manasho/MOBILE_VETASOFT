import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/donacion_model.dart';
import '../../../services/donacion_service.dart';

class DonationsView extends StatefulWidget {
  const DonationsView({super.key});

  @override
  State<DonationsView> createState() => _DonationsViewState();
}

class _DonationsViewState extends State<DonationsView> {
  final DonacionService _donacionService = DonacionService();
  static const Color _purpleHeader = Color(0xFFC166FC); // Morado para el header
  static const Color _bgLight = Color(0xFFF8F8FD); // Fondo muy claro
  static const Color _textColor = Color(0xFF1E293B);

  String _tipoDonacion = 'unica'; // unica, mensual, alimentos
  double _monto = 0.0;
  String _metodoPago = 'Tarjeta de crédito/débito';
  bool _anonimo = false;
  bool _isLoading = false;

  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _transaccionController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  @override
  void dispose() {
    _montoController.dispose();
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _transaccionController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _enviarDonacion() async {
    // Validar monto
    double montoFinal = _monto;
    if (_montoController.text.isNotEmpty) {
      final parsed = double.tryParse(_montoController.text.replaceAll('\$', '').replaceAll(',', '').trim());
      if (parsed != null && parsed > 0) {
        montoFinal = parsed;
      }
    }

    if (montoFinal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona o ingresa un monto válido.')),
      );
      return;
    }

    if (_nombreController.text.trim().isEmpty && !_anonimo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa tu nombre o elige donar de forma anónima.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String obsText = _observacionesController.text.trim();
      final String observaciones = obsText.isNotEmpty 
          ? obsText 
          : (_tipoDonacion == 'unica'
              ? 'Donación única'
              : _tipoDonacion == 'mensual'
                  ? 'Donación mensual'
                  : 'Donar alimentos');

      final donacion = DonacionModel(
        campanaId: 1, // Se envía ID 1 por defecto al no existir una selección de campaña en el diseño
        nombreDonante: _nombreController.text.trim().isNotEmpty ? _nombreController.text.trim() : "Anónimo",
        correoDonante: _correoController.text.trim(),
        telefonoDonante: _telefonoController.text.trim(),
        monto: montoFinal,
        metodoPago: _metodoPago,
        numeroTransaccion: _transaccionController.text.trim(),
        observaciones: observaciones,
        anonimo: _anonimo,
      );

      await _donacionService.createDonacion(donacion.toJson());

      if (true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Donación enviada con éxito! Gracias por tu apoyo.'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } 
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar la donación. Intenta de nuevo.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: _purpleHeader,
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                'Volver',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Donaciones',
              style: GoogleFonts.merriweather(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Ayuda a los refugios a cuidar más mascotas',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildStat(String val, String label, Color c) {
    return Column(
      children: [
        Text(val, style: GoogleFonts.inter(fontSize: 20, color: c, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600, height: 1.2)),
      ],
    );
  }

  Widget _buildRadioOption(String value, String title, String subtitle) {
    bool isSelected = _tipoDonacion == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tipoDonacion = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.grey.shade400 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, color: _textColor, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.grey.shade500 : Colors.grey.shade400,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMontoButton(double amount, String label) {
    bool isSelected = _monto == amount;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _monto = amount;
            _montoController.clear();
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? Colors.grey.shade400 : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent,
          ),
          alignment: Alignment.center,
          child: Text(label, style: GoogleFonts.inter(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600, color: _textColor)),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Gris muy suave
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.inter(color: _textColor),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Ayuda a los refugios
                _buildCard(
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.purple.shade50,
                        radius: 20,
                        child: const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                      ),
                      const SizedBox(height: 12),
                      Text('Ayuda a los refugios', style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16, color: _textColor)),
                      const SizedBox(height: 8),
                      Text(
                        'Tu donación ayuda a proporcionar alimento, atención\nveterinaria y refugio a mascotas necesitadas',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildStat('1.234', 'Mascotas\nayudadas', const Color(0xFFDF57FF))),
                          Container(width: 1, height: 40, color: Colors.grey.shade200),
                          Expanded(child: _buildStat('567', 'Donantes', const Color(0xFF673E8A))),
                          Container(width: 1, height: 40, color: Colors.grey.shade200),
                          Expanded(child: _buildStat('100%', 'Transparencia', const Color(0xFF568EBB))),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Tipo de donación
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tipo de donación', style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16, color: _textColor)),
                      const SizedBox(height: 16),
                      _buildRadioOption('unica', 'Donación única', 'Elige el monto de tu donación'),
                      const SizedBox(height: 12),
                      _buildRadioOption('mensual', 'Donación mensual', 'Apoya continuamente los refugios'),
                      const SizedBox(height: 12),
                      _buildRadioOption('alimentos', 'Donar alimentos', 'Contribuye con comida para mascotas'),
                    ],
                  ),
                ),

                // Monto a donar
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Monto a donar', style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16, color: _textColor)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMontoButton(10000, '\$10mil'),
                          _buildMontoButton(50000, '\$50mil'),
                          _buildMontoButton(200000, '\$200mil'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('o ingresa otro monto', style: GoogleFonts.inter(fontSize: 13, color: _textColor)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9), // Gris muy suave
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _montoController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.inter(color: _textColor),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '\$ 0.00',
                            hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
                          ),
                          onChanged: (val) {
                             setState(() { _monto = 0.0; }); 
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Datos del donante
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Datos del donante', style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16, color: _textColor)),
                      const SizedBox(height: 16),
                      _buildTextField(controller: _nombreController, hintText: 'Nombre completo (*requerido)'),
                      const SizedBox(height: 12),
                      _buildTextField(controller: _correoController, hintText: 'Correo electrónico (opcional)', keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _buildTextField(controller: _telefonoController, hintText: 'Teléfono (opcional)', keyboardType: TextInputType.phone),
                    ],
                  ),
                ),

                // Método de pago
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Método de pago', style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16, color: _textColor)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _metodoPago,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            items: <String>['Tarjeta de crédito/débito', 'Transferencia bancaria']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Row(
                                  children: [
                                    const Icon(Icons.credit_card, color: Colors.grey, size: 20),
                                    const SizedBox(width: 12),
                                    Text(value, style: GoogleFonts.inter(fontSize: 14)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _metodoPago = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Información adicional
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Información adicional', style: GoogleFonts.merriweather(fontWeight: FontWeight.bold, fontSize: 16, color: _textColor)),
                      const SizedBox(height: 16),
                      _buildTextField(controller: _transaccionController, hintText: 'Número de transacción (si aplica)'),
                      const SizedBox(height: 12),
                      _buildTextField(controller: _observacionesController, hintText: 'Observaciones (opcional)', maxLines: 3),
                    ],
                  ),
                ),

                // Checkbox Anónimo
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFEBCCFF)),
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFFCF7FF), // Morado muy muy claro
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _anonimo,
                          onChanged: (val) {
                            setState(() { _anonimo = val ?? false; });
                          },
                          activeColor: const Color(0xFFC166FC),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Donar de forma anónima', style: GoogleFonts.inter(fontSize: 14, color: _textColor, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('Tu nombre no aparecerá en la lista pública de donantes', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // Botón Donar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _enviarDonacion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD46AFF), // Morado brillante
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Donar', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
