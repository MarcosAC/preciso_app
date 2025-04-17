import 'package:flutter/material.dart';
import 'package:preciso/domain/entities/user_entity.dart';

class ProSpecificSection extends StatelessWidget {
  final UserEntity user;
  final bool isEditing;

  const ProSpecificSection({
    super.key,
    required this.user,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Chip(
              label: Text(user.profession ?? 'Profissional'),
              backgroundColor: Colors.blue[100],
            ),
            const Spacer(),
            const Icon(Icons.star, color: Colors.amber),
            Text(user.rating.toStringAsFixed(1)),
            const SizedBox(width: 16),
            const Icon(Icons.work),
            Text('${user.completedServices} serviços'),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Portfólio', style: TextStyle(fontWeight: FontWeight.bold)),
        // Galeria de trabalhos...
        const SizedBox(height: 16),
        const Text('Horários', style: TextStyle(fontWeight: FontWeight.bold)),
        // Calendário de disponibilidade...
      ],
    );
  }
}