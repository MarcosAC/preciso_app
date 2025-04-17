import 'package:flutter/material.dart';
import 'package:preciso/presentation/viewmodels/auth_viewmodel.dart';
import 'package:preciso/presentation/views/client/profile/client_profile_screen.dart';
import 'package:preciso/presentation/views/client/request_service_view.dart';
import 'package:preciso/presentation/views/client/professionals_list_view.dart';
import 'package:provider/provider.dart';

class HomeClientView extends StatelessWidget {
  const HomeClientView({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtém o userId do AuthViewModel
    final userId = Provider.of<AuthViewModel>(context, listen: false).currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços Disponíveis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClientProfileScreen(userId: userId),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RequestServiceView(),
            ),
          );
        },
      ),
      body: ListView(
        children: [
          _buildCategoryCard(context, 'Eletricista', Icons.electrical_services),
          _buildCategoryCard(context, 'Encanador', Icons.plumbing),
          _buildCategoryCard(context, 'Pedreiro', Icons.construction),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfessionalsListView(serviceType: title),
            ),
          );
        },
      ),
    );
  }
}