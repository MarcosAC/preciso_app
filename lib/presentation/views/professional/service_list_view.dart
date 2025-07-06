import 'package:flutter/material.dart';
import 'package:preciso/domain/entities/service_entity.dart';
import 'package:preciso/presentation/viewmodels/auth_viewmodel.dart';
import 'package:preciso/presentation/viewmodels/service_viewmodel.dart';
import 'package:preciso/presentation/views/professional/detail_service_view.dart';
import 'package:preciso/presentation/views/professional/profile/pro_profile_screen.dart';
import 'package:provider/provider.dart';

class ServiceListView extends StatefulWidget {
  final List<ServiceEntity>? initialServices;

  const ServiceListView({super.key, this.initialServices});

  @override
  State<ServiceListView> createState() => _ServiceListViewState();
}

class _ServiceListViewState extends State<ServiceListView> {
  late ServiceViewModel _serviceViewModel;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _serviceViewModel = Provider.of<ServiceViewModel>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthViewModel>(context, listen: false).currentUser?.uid ?? '';
    final serviceViewModel = Provider.of<ServiceViewModel>(context);

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
                  builder: (context) => ProfessionalProfileScreen(userId: userId),
                ),
              );
            },
          ),
        ],),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewMolde, child) {
          final currentUser = authViewMolde.currentUser;
          final currentUserId = currentUser?.uid;

          if (currentUserId == null) {
            return const Center(
              child: Text('Por favor, faça login para ver seus serviços solicitados.')
            );
          }          

          return StreamBuilder<List<ServiceEntity>>(
            stream: serviceViewModel.getAvailableRequests('Eletricista'),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Erro ao carregar serviços: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();            
              }

              final services = snapshot.data!;

              return ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (contex) => 
                        DetailServiceView(service: services[index], professionalId: userId,)));
                    },
                    child: _buildServiceCard(services[index]));
                },
              );
            });
        }
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Nenhum serviço disponivel ainda',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceEntity service) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  service.serviceType,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Chip(
                  label: Text(
                    _translateStatus(service.status),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(service.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (service.price != null)
              Text(
                'Preço: R\$${service.price!.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500),
              ),
            const SizedBox(height: 8),
            Text(
              'Endereço: ${service.address}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Data: ${_formatDate(service.requestDate)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Descrição: ${service.description}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (service.rating != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Avaliação: ${service.rating!.toStringAsFixed(1)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _translateStatus(String status) {
    const statusMap = {
      'pending': 'Pendente',
      'accepted': 'Aceito',
      'completed': 'Concluído',
      'canceled': 'Cancelado',
    };
    return statusMap[status.toLowerCase()] ?? status;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}