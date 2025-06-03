import 'package:flutter/material.dart';
import 'package:preciso/domain/entities/user_entity.dart';
import 'package:preciso/presentation/viewmodels/auth_viewmodel.dart';
import 'package:preciso/presentation/views/client/requested_services_view.dart';
import 'package:provider/provider.dart';

class ClientSpecificSection extends StatefulWidget {
  final UserEntity user;
  final bool isEditing;
  final VoidCallback onLogout;

  const ClientSpecificSection({
    super.key,
    required this.user,
    required this.isEditing,
    required this.onLogout,
  });

  @override
  State<ClientSpecificSection> createState() => _ClientSpecificSectionState();
}

class _ClientSpecificSectionState extends State<ClientSpecificSection> {
  @override
  Widget build(BuildContext context) {
    Provider.of<AuthViewModel>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: widget.onLogout,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.logout, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    'Sair',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),

        const Text(
          'Preferências',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: widget.user.services.join(', '),
          enabled: widget.isEditing,
          decoration: const InputDecoration(
            hintText: 'Ex: Encanador, Pintor',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const Text(
          'Endereços Salvos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16.0),
        InkWell(
          onTap: () {            
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RequestedServicesView(services: [],)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Serviços Solicitados',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.grey[700]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
