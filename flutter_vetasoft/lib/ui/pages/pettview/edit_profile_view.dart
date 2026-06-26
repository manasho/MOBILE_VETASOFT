import 'package:flutter/material.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: const Center(
        child: Text('Pantalla de Editar Perfil\n(En construcción)', textAlign: TextAlign.center,),
      ),
    );
  }
}
