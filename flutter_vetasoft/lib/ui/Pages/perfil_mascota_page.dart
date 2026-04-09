import 'package:flutter/material.dart';
import '../../services/animales_service.dart';

class AgendaPage extends StatefulWidget {
  final String animalId;
  final String token;

  const AgendaPage({
    super.key,
    required this.animalId,
    required this.token,
  });

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  Map<String, dynamic>? animal;
  bool isLoading = true;

  int pendientes = 0;
  int completadas = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await AnimalesService.getAnimalById(
        widget.animalId, widget.token);

    if (data != null) {
      final historial = data["historial_medico"] ?? [];

      pendientes = historial.where((h) => h["estado"] != "completado").length;
      completadas = historial.where((h) => h["estado"] == "completado").length;

      setState(() {
        animal = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Agenda"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Adopción"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5A8DEE), Color(0xFF8E5AEF)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("¡Hola, Juan!",
                          style: TextStyle(color: Colors.white, fontSize: 28)),
                      Icon(Icons.notifications_none, color: Colors.white)
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Mascota: ${animal?["nombre"] ?? ""}",
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      _infoCard("Citas Pendientes", pendientes.toString()),
                      const SizedBox(width: 10),
                      _infoCard("Citas completadas", completadas.toString()),
                    ],
                  ),
                ],
              ),
            ),

            /// BOTÓN
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5A8DEE), Color(0xFF8E5AEF)],
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Agendar nueva cita",
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),

            /// ALERTA
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications, color: Colors.orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Tienes $pendientes cita(s) pendiente(s)\nNo olvides confirmar",
                      style: const TextStyle(color: Colors.orange),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// HISTORIAL
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Historial de citas",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 10),

            ..._buildHistorial(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHistorial() {
    final historial = animal?["historial_medico"] ?? [];

    return historial.map<Widget>((h) {
      final estado = h["estado"] ?? "Pendiente";

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(h["descripcion"] ?? "Consulta",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(estado,
                    style: TextStyle(
                        color: estado == "completado"
                            ? Colors.green
                            : Colors.orange))
              ],
            ),

            const SizedBox(height: 5),
            Text(h["veterinario_nombre"] ?? ""),

            const SizedBox(height: 10),
            Text(h["fecha_creacion"] ?? ""),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text("Ver detalles",
                    style: TextStyle(color: Colors.blue)),
              ),
            )
          ],
        ),
      );
    }).toList();
  }

  Widget _infoCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}