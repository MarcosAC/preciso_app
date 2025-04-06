import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:preciso/presentation/viewmodels/service_viewmodel.dart';
import 'package:preciso/presentation/views/client/request_service_view.dart';
import 'package:preciso/presentation/views/client/professionals_list_view.dart';

class HomeClientView extends StatelessWidget {
  const HomeClientView({super.key});

  @override
  Widget build(BuildContext context) {
    //final serviceViewModel = Provider.of<ServiceViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços Disponíveis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navegar para perfil
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