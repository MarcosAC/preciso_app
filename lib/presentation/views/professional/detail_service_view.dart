import 'package:flutter/material.dart';
import 'package:preciso/domain/entities/service_entity.dart';
import 'package:preciso/presentation/viewmodels/auth_viewmodel.dart';
import 'package:preciso/presentation/viewmodels/service_viewmodel.dart';
import 'package:provider/provider.dart';

class DetailServiceView extends StatefulWidget {
  final ServiceEntity service;
  final String professionalId;

  const DetailServiceView({super.key, required this.service, required this.professionalId});

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

  void _updateServiceStatus(String newStatus) async {
    // 1. Capturar o ServiceViewModel ANTES do async gap
    // Isso garante que você está usando um BuildContext válido no momento da captura.
    final serviceViewModel = Provider.of<ServiceViewModel>(context, listen: false);

    // 2. Capturar o ScaffoldMessenger ANTES do async gap
    // Isso também previne o uso de um BuildContext inválido para mostrar o SnackBar.
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Primeiro, atualiza o estado local para a UI responder imediatamente
    setState(() {
      _currentStatus = newStatus;
    });

    // Mostra um feedback inicial enquanto a operação real acontece
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Atualizando serviço para ${_translateStatus(newStatus)}...'),
        duration: const Duration(seconds: 2), // Pode ser um pouco mais curto para feedback inicial
      ),
    );

    // --- Chamada REAL ao ViewModel para persistir a mudança ---
    // Acessa o ServiceViewModel usando Provider (listen: false pois só vamos chamar um método)
    // final serviceViewModel = Provider.of<ServiceViewModel>(context, listen: false);

    try {
      // Chama o método do ViewModel que, por sua vez, usará o UpdateRequestStatusUseCase
      await serviceViewModel.updateRequestStatus(widget.service.id, widget.professionalId, newStatus);
          
      // Se a atualização for bem-sucedida no backend
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Status do serviço atualizado com sucesso para ${_translateStatus(newStatus)}!'),
          backgroundColor: Colors.blue,
        ),
      );

    } catch (e) {
      // Se houver um erro na atualização
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar o serviço: $e'),
          backgroundColor: Colors.red,
        ),
      );
      // Opcional: Reverter o estado da UI se a atualização falhar no backend
      setState(() {
        _currentStatus = widget.service.status; // Volta ao status original para consistência
      });
    }
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
            // Cor ajustada para hexadecimal com opacidade
            color: const Color(0x1A000000), // 0x1A é 10% de FF (opacidade total)
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
    // Os botões só aparecem se o status atual for 'pending'
    if (_currentStatus != 'pending') {
      return const SizedBox.shrink(); // Widget vazio se não for 'pending'
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateServiceStatus('confirmed'), // Chama para confirmar
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Aceitar', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateServiceStatus('rejected'), // Chama para rejeitar
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
        return Colors.blue[700]!; // Verde para confirmado
      case 'completed':
        return Colors.green[700]!; // Azul para concluído
      case 'canceled':
        return Colors.grey[700]!; // Cinza para cancelado
      case 'rejected':
        return Colors.red[700]!; // Vermelho para rejeitado
      default:
        return Colors.grey[600]!;
    }
  }
}