import 'package:flutter/material.dart';
import '../../services/citas_service.dart';

class AgendaPage extends StatefulWidget {
  final String token;
  final int clienteId;

  const AgendaPage({
    super.key,
    required this.token,
    required this.clienteId,
  });

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  List citas = [];
  bool isLoading = true;

  int pendientes = 0;
  int completadas = 0;

  @override
  void initState() {
    super.initState();
    loadCitas();
  }

  Future<void> loadCitas() async {
    final data = await CitasService.getCitas(
      token: widget.token,
      clienteId: widget.clienteId,
    );

    pendientes = data.where((c) => c["estado_nombre"] == "Pendiente").length;
    completadas = data.where((c) => c["estado_nombre"] == "Completada").length;

    setState(() {
      citas = data;
      isLoading = false;
    });
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

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("¡Hola, Juan!",
                          style: TextStyle(color: Colors.white, fontSize: 28)),
                      Icon(Icons.notifications_none, color: Colors.white)
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Mascota: ${citas.isNotEmpty ? citas[0]["animal_nombre"] : ""}",
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
                      "Tienes $pendientes cita(s) pendiente(s)\nNo olvides confirmar tus próximas citas",
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

            ...citas.map((c) => _citaCard(c)).toList(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
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

  Widget _citaCard(dynamic c) {
    final estado = c["estado_nombre"] ?? "";

    Color colorEstado =
        estado == "Completada" ? Colors.green : Colors.orange;

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
              Text(c["motivo"] ?? "Consulta",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colorEstado.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(estado, style: TextStyle(color: colorEstado)),
              )
            ],
          ),

          const SizedBox(height: 5),
          Text(c["veterinario_nombre"] ?? ""),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 5),
              Text(c["fecha_cita"].toString()),
            ],
          ),

          Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 5),
              const Text("Clínica Veterinaria"),
            ],
          ),

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
  }
}