import 'package:flutter/material.dart';
import 'package:preciso/domain/entities/user_entity.dart';

class ClientSpecificSection extends StatelessWidget {
  final UserEntity user;
  final bool isEditing;

  const ClientSpecificSection({
    super.key,
    required this.user,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preferências', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: user.services.join(', '),
          enabled: isEditing,
          decoration: const InputDecoration(
            hintText: 'Ex: Encanador, Pintor',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const Text('Endereços Salvos', style: TextStyle(fontWeight: FontWeight.bold)),
        // Lista de endereços...
      ],
    );
  }
}