import 'package:flutter/material.dart';
import 'package:preciso/domain/entities/service_entity.dart';
// Mantidos caso precise de dados do usuário logado ou integrações futuras
import 'package:preciso/presentation/viewmodels/auth_viewmodel.dart';
import 'package:preciso/presentation/viewmodels/service_viewmodel.dart';
import 'package:provider/provider.dart';

class DetailServiceView extends StatefulWidget {
  final ServiceEntity service;

  const DetailServiceView({super.key, required this.service});

  @override
  State<DetailServiceView> createState() => _DetailServiceViewState();
}

class _DetailServiceViewState extends State<DetailServiceView> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    // Inicializa o status com o status do serviço recebido
    _currentStatus = widget.service.status;
  }

  void _updateServiceStatus(String newStatus) {
    setState(() {
      _currentStatus = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Serviço ${_translateStatus(newStatus)}!'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Em um cenário real, você chamaria seu ViewModel aqui
    // para persistir essa mudança no banco de dados.
  }

  @override
  Widget build(BuildContext context) {
    final ServiceEntity service = widget.service;

    // Determine a cor principal da tela com base no status atual
    final Color headerAndAppBarColor = _getStatusColor(_currentStatus);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Serviço'),
        // A cor da AppBar agora é dinâmica
        backgroundColor: headerAndAppBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Passa a cor dinâmica para o cabeçalho
            _buildServiceHeader(service, headerAndAppBarColor),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSectionCard(
                    title: 'Detalhes da Solicitação',
                    icon: Icons.info_outline,
                    children: [
                      _buildDetailRow(Icons.text_snippet, 'Descrição', service.description),
                      if (service.price != null && service.price! > 0)
                        _buildDetailRow(Icons.monetization_on, 'Preço Sugerido', 'R\$${service.price!.toStringAsFixed(2)}'),
                      _buildDetailRow(Icons.calendar_today, 'Solicitado em', _formatDate(service.requestDate)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: 'Localização do Serviço',
                    icon: Icons.location_on_outlined,
                    children: [
                      _buildDetailRow(Icons.home, 'Endereço Completo', service.address),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: 'Informações Adicionais',
                    icon: Icons.person_outline,
                    children: [
                      _buildDetailRow(Icons.perm_identity, 'ID do Cliente', service.clientId),
                      _buildDetailRow(Icons.account_circle_outlined, 'Seu ID de Profissional', service.professionalId),
                      if (service.rating != null && service.rating! > 0)
                        _buildRatingRow(service.rating!),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(context),
    );
  }

  // --- Widgets de Layout ---

  // Agora aceita a cor como parâmetro
  Widget _buildServiceHeader(ServiceEntity service, Color backgroundColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      // A cor de fundo é dinâmica
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.serviceType,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Chip(
              label: Text(
                _translateStatus(_currentStatus),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              // O chip continua usando a cor específica do status,
              // que pode ser ligeiramente diferente da cor principal do header
              backgroundColor: _getStatusColor(_currentStatus),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // A cor do ícone também pode ser ajustada, se desejar.
                // Usando primaryColor aqui, mas poderia ser _getStatusColor(_currentStatus)
                Icon(icon, color: Theme.of(context).primaryColor, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1, color: Colors.grey),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícones nas linhas de detalhe podem ter uma cor secundária do tema
          Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 16),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(double rating) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 22),
          const SizedBox(width: 8),
          Text(
            'Avaliação: ${rating.toStringAsFixed(1)}',
            style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (_currentStatus != 'pending') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateServiceStatus('confirmed'),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Aceitar', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateServiceStatus('rejected'),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Recusar', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Funções Auxiliares ---

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _translateStatus(String status) {
    const statusMap = {
      'pending': 'Pendente',
      'confirmed': 'Confirmado',
      'completed': 'Concluído',
      'canceled': 'Cancelado',
      'rejected': 'Rejeitado',
    };
    return statusMap[status.toLowerCase()] ?? status;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange[700]!; // Laranja para pendente
      case 'confirmed':
        return Colors.green[700]!; // Verde para confirmado
      case 'completed':
        return Colors.blue[700]!; // Azul para concluído
      case 'canceled':
        return Colors.grey[700]!; // Cinza para cancelado
      case 'rejected':
        return Colors.red[700]!; // Vermelho para rejeitado
      default:
        return Colors.grey[600]!;
    }
  }
}

// import 'package:flutter/material.dart';
// import 'package:preciso/domain/entities/service_entity.dart';
// import 'package:preciso/presentation/viewmodels/auth_viewmodel.dart';
// import 'package:preciso/presentation/viewmodels/service_viewmodel.dart';
// import 'package:provider/provider.dart';

// class DetailServiceView extends StatefulWidget {
//   final List<ServiceEntity>? initialServices;

//   const DetailServiceView({super.key, this.initialServices});

//   @override
//   State<DetailServiceView> createState() => _DetailServiceViewState();
// }

// class _DetailServiceViewState extends State<DetailServiceView> { 
//   late ServiceViewModel _serviceViewModel;  

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _serviceViewModel = Provider.of<ServiceViewModel>(context, listen: false);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final serviceViewModel = Provider.of<ServiceViewModel>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Detalhe Serviço'),
//       ),
//       body: Consumer<AuthViewModel>(
//         builder: (context, authViewModel, child) {
//           final currentUser = authViewModel.currentUser;
//           final currentUserId = currentUser?.uid;

//           if (currentUserId == null) {            
//             return const Center(
//               child: Text(
//                   'Por favor, faça login para ver seus serviços solicitados.'),
//             );
//           }

//           return _buildServiceCard();

//           // return StreamBuilder<List<ServiceEntity>>(
//           //   stream: serviceViewModel.getClientRequests(currentUserId),
//           //   builder: (context, snapshot) {
//           //     if (snapshot.hasError) {
//           //       return Center(child: Text('Erro ao carregar serviços: ${snapshot.error}'));
//           //     }

//           //     if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
//           //       return const Center(child: CircularProgressIndicator());
//           //     }

//           //     if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           //       return _buildEmptyState();
//           //     }

//           //     final services = snapshot.data!;

//           //     return ListView.builder(
//           //       itemCount: services.length,
//           //       itemBuilder: (context, index) {
//           //         return _buildServiceCard(services[index]);
//           //       },
//           //     );
//           //   },
//           // );
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           const Text(
//             'Nenhum serviço solicitado ainda',
//             style: TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildServiceCard(/*ServiceEntity service*/) {
//     return Card(
//       margin: const EdgeInsets.all(8),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Eletricista',
//                   //service.serviceType,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 Chip(
//                   label: Text('Pendente',
//                    // _translateStatus(service.status),
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                   backgroundColor: _getStatusColor('pending'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             if (service.price != null)
//               Text(
//                 'Preço: R\$${service.price!.toStringAsFixed(2)}',
//                 style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500),
//               ),
//             const SizedBox(height: 8),
//             Text(
//               'Endereço: ${service.address}',
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Data: ${_formatDate(service.requestDate)}',
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Descrição: ${service.description}',
//               style: TextStyle(color: Colors.grey[600]),
//             ),
//             if (service.rating != null) ...[
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   const Icon(Icons.star, color: Colors.amber, size: 16),
//                   const SizedBox(width: 4),
//                   Text(
//                     'Avaliação: ${service.rating!.toStringAsFixed(1)}',
//                     style: TextStyle(color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   String _translateStatus(String status) {
//     const statusMap = {
//       'pending': 'Pendente',
//       'confirmed': 'Confirmado',
//       'completed': 'Concluído',
//       'canceled': 'Cancelado',
//     };
//     return statusMap[status.toLowerCase()] ?? status;
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'pendente':
//         return Colors.orange;
//       case 'confirmado':
//         return Colors.blue;
//       case 'concluído':
//         return Colors.green;
//       case 'cancelado':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
// }