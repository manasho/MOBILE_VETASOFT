import 'package:flutter/material.dart';

class PetProfileView extends StatelessWidget {
  final Map<String, dynamic> petData;
  const PetProfileView({super.key, required this.petData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perfil de ${petData['nombre'] ?? 'Mascota'}')),
      body: Center(
        child: Text('Perfil de Mascota:\n${petData.toString()}\n(En construcción)', textAlign: TextAlign.center,),
      ),
    );
  }
}
