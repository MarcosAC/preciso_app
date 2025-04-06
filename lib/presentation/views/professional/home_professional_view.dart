import 'package:flutter/material.dart';

class HomeProfessionalView extends StatelessWidget {
  const HomeProfessionalView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Serviços')),
      body: const Center(child: Text('Área do Profissional')),
    );
  }
}