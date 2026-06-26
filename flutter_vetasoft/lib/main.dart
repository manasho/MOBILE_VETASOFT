import 'package:flutter/material.dart';
import 'package:flutter_vetasoft/ui/pages/adoptionview/solicitudes_list_page.dart';
// 💡 Importamos la página que construimos
import 'package:flutter_vetasoft/ui/pages/profileview/Profile_cofig_page.dart';
import 'package:flutter_vetasoft/ui/pages/veterianrioview/veterinarian_panel_page.dart';
import 'package:flutter_vetasoft/ui/pages/adoptionview/solicitud_form_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VetaSoft Branquiovet',
      debugShowCheckedModeBanner: false, // Quitamos la banda roja de "Debug"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4592)),
        useMaterial3: true,
      ),
      // 🚀 ¡Aquí está el truco! Ponemos tu panel como la página inicial
      home: const SolicitudFormPage(animalId: 4, animalNombre: 'copito lindo'), 
    );
  }
}
