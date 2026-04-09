import 'package:flutter/material.dart';
import '../../services/solicitudes_adopcion_service.dart';

class AdopcionPage extends StatefulWidget {
  final int animalId;

  const AdopcionPage({super.key, required this.animalId});

  @override
  State<AdopcionPage> createState() => _AdopcionPageState();
}

class _AdopcionPageState extends State<AdopcionPage> {
  final _formKey = GlobalKey<FormState>();

  final nombreCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();
  final convivenciaCtrl = TextEditingController();
  final experienciaCtrl = TextEditingController();
  final motivacionCtrl = TextEditingController();
  final cuidadoCtrl = TextEditingController();

  String tipoVivienda = "";
  String tieneJardin = "";
  String tieneMascotas = "";

  bool aceptaTerminos = false;
  bool isLoading = false;

  /// 🔘 OPCIONES (SIN CAMBIAR DISEÑO)
  Widget buildOption(String label, String groupValue, Function(String) onTap) {
    final isSelected = groupValue == label;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(label),
        child: Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.purple : Colors.grey,
            ),
            color: isSelected
                ? Colors.purple.withOpacity(0.1)
                : Colors.white,
          ),
          child: Center(child: Text(label)),
        ),
      ),
    );
  }

  /// 🧱 INPUT (MISMO ESTILO)
  Widget input(String hint, TextEditingController ctrl,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        validator: (value) =>
            value!.isEmpty ? "Campo obligatorio" : null,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// 🧱 CARD (MISMO DISEÑO)
  Widget sectionCard(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  /// 🚀 SUBMIT (AQUÍ ESTÁ LO IMPORTANTE)
  void submit() async {
    if (!_formKey.currentState!.validate() || !aceptaTerminos) {
      showMessage("Completa todos los campos");
      return;
    }

    setState(() => isLoading = true);

    final response =
        await SolicitudesAdopcionService.crearSolicitud(
      animalId: widget.animalId,
      nombre: nombreCtrl.text,
      correo: correoCtrl.text,
      telefono: telefonoCtrl.text,
      direccion: direccionCtrl.text,
      experiencia: experienciaCtrl.text,
      motivo: motivacionCtrl.text,
    );

    setState(() => isLoading = false);

    if (response["success"]) {
      showMessage("Solicitud enviada 🐾");

      _formKey.currentState!.reset();
      nombreCtrl.clear();
      correoCtrl.clear();
      telefonoCtrl.clear();
      direccionCtrl.clear();
      experienciaCtrl.clear();
      motivacionCtrl.clear();
      cuidadoCtrl.clear();

    } else {
      showMessage(response["message"]);
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// HEADER (SIN CAMBIOS)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB06EF5), Color(0xFF8E5AEF)],
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("← Volver",
                        style: TextStyle(color: Colors.white)),
                    SizedBox(height: 10),
                    Text(
                      "Solicitud de adopción",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Formulario para adoptar a Kuro",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(15),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      sectionCard(
                        "¡Que emoción!",
                        const Text(
                            "Estás a un paso de darle un hogar a Kuro."),
                      ),

                      sectionCard(
                        "Datos personales",
                        Column(
                          children: [
                            input("Nombre completo", nombreCtrl),
                            input("Correo electrónico", correoCtrl),
                            input("Teléfono", telefonoCtrl),
                            input("Dirección", direccionCtrl),
                          ],
                        ),
                      ),

                      sectionCard(
                        "Información del hogar",
                        Column(
                          children: [
                            Row(
                              children: [
                                buildOption("Casa", tipoVivienda,
                                    (v) => setState(() => tipoVivienda = v)),
                                buildOption("Departamento", tipoVivienda,
                                    (v) => setState(() => tipoVivienda = v)),
                              ],
                            ),
                            Row(
                              children: [
                                buildOption("Casa con jardín", tipoVivienda,
                                    (v) => setState(() => tipoVivienda = v)),
                                buildOption("Otro", tipoVivienda,
                                    (v) => setState(() => tipoVivienda = v)),
                              ],
                            ),
                            Row(
                              children: [
                                buildOption("Sí", tieneJardin,
                                    (v) => setState(() => tieneJardin = v)),
                                buildOption("No", tieneJardin,
                                    (v) => setState(() => tieneJardin = v)),
                              ],
                            ),
                            input("¿Con quién vives?", convivenciaCtrl),
                          ],
                        ),
                      ),

                      sectionCard(
                        "Experiencia con mascotas",
                        Column(
                          children: [
                            Row(
                              children: [
                                buildOption("Sí", tieneMascotas,
                                    (v) => setState(() => tieneMascotas = v)),
                                buildOption("No", tieneMascotas,
                                    (v) => setState(() => tieneMascotas = v)),
                              ],
                            ),
                            input("Experiencia", experienciaCtrl,
                                maxLines: 3),
                          ],
                        ),
                      ),

                      sectionCard(
                        "Motivación y compromiso",
                        Column(
                          children: [
                            input("Motivación", motivacionCtrl,
                                maxLines: 3),
                            input("Cuidado", cuidadoCtrl, maxLines: 3),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          Checkbox(
                            value: aceptaTerminos,
                            onChanged: (v) =>
                                setState(() => aceptaTerminos = v!),
                          ),
                          const Expanded(
                              child: Text(
                                  "Acepto términos y condiciones")),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// BOTÓN (SOLO LE AGREGUÉ LOADING)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFB06EF5),
                              Color(0xFF8E5AEF)
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text("Enviar solicitud"),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}