import 'package:flutter/material.dart';
import 'package:preciso/domain/entities/service_entity.dart';

class RequestedServicesView extends StatelessWidget {
  final List<ServiceEntity> services;

  const RequestedServicesView({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços Solicitados'),
      ),
      body: services.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                return _buildServiceCard(services[index]);
              },
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
            'Nenhum serviço solicitado ainda',
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
      'confirmed': 'Confirmado',
      'completed': 'Concluído',
      'canceled': 'Cancelado',
    };
    return statusMap[status.toLowerCase()] ?? status;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Colors.orange;
      case 'confirmado':
        return Colors.blue;
      case 'concluído':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}