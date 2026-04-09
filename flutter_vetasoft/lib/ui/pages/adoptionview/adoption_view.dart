import 'package:flutter/material.dart';

class AdoptionView extends StatelessWidget {
  const AdoptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adoptar Mascota')),
      body: const Center(
        child: Text('Pantalla de Adopción\n(En construcción)', textAlign: TextAlign.center,),
      ),
    );
  }
}
