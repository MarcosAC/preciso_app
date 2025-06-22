import 'package:flutter/material.dart';
import 'package:preciso/domain/entities/user_entity.dart';

class ProSpecificSection extends StatefulWidget {
  final UserEntity user;
  final bool isEditing;
  final VoidCallback onLogout;

  const ProSpecificSection({
    super.key,
    required this.user,
    required this.isEditing,
    required this.onLogout,
  });

  @override
  State<ProSpecificSection> createState() => _ProSpecificSectionState();
}

class _ProSpecificSectionState extends State<ProSpecificSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Chip(
              label: Text(widget.user.profession ?? 'Profissional'),
              backgroundColor: Colors.blue[100],
            ),
            const Spacer(),
            const Icon(Icons.star, color: Colors.amber),
            Text(widget.user.rating.toStringAsFixed(1)),
            const SizedBox(width: 16),
            const Icon(Icons.work),
            Text('${widget.user.completedServices} serviços'),
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