import 'package:flutter/material.dart';

// Imports de la rama Pruebas
import 'package:flutter_vetasoft/ui/pages/adoptionview/solicitudes_list_page.dart';
import 'package:flutter_vetasoft/ui/pages/profileview/Profile_cofig_page.dart';
import 'package:flutter_vetasoft/ui/pages/veterianrioview/veterinarian_panel_page.dart';
import 'package:flutter_vetasoft/ui/pages/adoptionview/solicitud_form_page.dart';
import 'package:flutter_vetasoft/ui/pages/pettview/register_client_view.dart';

// Imports de la rama Tifanny (Normalizados a minúscula 'pages')
import 'package:flutter_vetasoft/ui/pages/pacientes_view.dart';
import 'package:flutter_vetasoft/ui/pages/historial_medico_view.dart';
import 'package:flutter_vetasoft/ui/pages/ver_registro_view.dart';
import 'package:flutter_vetasoft/ui/pages/agregar_registro_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VetaSoft Branquiovet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4592)),
        useMaterial3: true,
      ),
      // Mantenemos RegisterClientView como inicio para continuar el flujo de registro que validamos
      home: const RegisterClientView(), 
    );
  }
}
