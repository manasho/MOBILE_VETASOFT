import 'package:flutter/material.dart';
import '../../../services/donaciones_service.dart';

class DonacionesPage extends StatefulWidget {
  final String token;

  const DonacionesPage({super.key, required this.token});

  @override
  State<DonacionesPage> createState() => _DonacionesPageState();
}

class _DonacionesPageState extends State<DonacionesPage> {
  List donaciones = [];
  bool isLoading = true;

  double total = 0;
  double promedio = 0;
  int totalDonaciones = 0;
  int anonimas = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await DonacionesService.getDonaciones(
      token: widget.token,
    );

    total = data.fold(0, (sum, d) => sum + (d["monto"] ?? 0));
    totalDonaciones = data.length;
    anonimas = data.where((d) => d["anonimo"] == true).length;
    promedio = totalDonaciones > 0 ? total / totalDonaciones : 0;

    setState(() {
      donaciones = data;
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
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00C9A7), Color(0xFF007BFF)],
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
                        SizedBox(width: 10),
                        Text("Volver", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text("Gestión de Donaciones",
                      style: TextStyle(color: Colors.white, fontSize: 26)),
                  const Text("Administra las donaciones recibidas",
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            /// CARDS
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _card("\$${total.toStringAsFixed(0)}", "Total Recibido", Colors.green),
                      const SizedBox(width: 10),
                      _card("\$${promedio.toStringAsFixed(0)}", "Promedio de donaciones", Colors.white),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _card("$totalDonaciones", "Donaciones totales", Colors.white),
                      const SizedBox(width: 10),
                      _card("$anonimas", "Anonimas", Colors.white),
                    ],
                  ),
                ],
              ),
            ),

            /// BUSCAR / FILTRO
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const TextField(
                    decoration: InputDecoration(
                      hintText: "Nombre del donante",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField(
                    items: const [
                      DropdownMenuItem(value: "all", child: Text("Todos los meses")),
                    ],
                    onChanged: (v) {},
                    decoration: const InputDecoration(labelText: "Filtrar por mes"),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// LISTA
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Últimas Donaciones",
                        style: TextStyle(fontSize: 18)),
                  ),
                  const Divider(),
                  ...donaciones.map((d) => _donacionItem(d)).toList()
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// RESUMEN
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _resumen("Este mes", total),
                  _resumen("Mes anterior", total * 0.7),
                  _resumen("Crecimiento", 29, isPercent: true),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _card(String value, String title, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color == Colors.white ? Colors.black : Colors.white,
                    fontSize: 18)),
            Text(title,
                style: TextStyle(
                    color: color == Colors.white ? Colors.black54 : Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _donacionItem(dynamic d) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: Text(d["anonimo"] ? "Anonimo" : d["nombre_donante"] ?? ""),
      subtitle: Text(d["metodo_pago"] ?? ""),
      trailing: Text("\$${d["monto"]}"),
    );
  }

  Widget _resumen(String title, double value, {bool isPercent = false}) {
    return Column(
      children: [
        Text(title),
        Text(
          isPercent ? "+${value.toStringAsFixed(0)}%" : "\$${value.toStringAsFixed(0)}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}