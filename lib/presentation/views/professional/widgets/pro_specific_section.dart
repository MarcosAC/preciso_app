import 'package:flutter/material.dart';
import 'package:preciso/domain/entities/user_entity.dart';
import 'package:preciso/presentation/views/client/requested_services_view.dart';
import 'package:preciso/presentation/views/professional/service_list_view.dart';

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
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RequestedServicesView()),
            );             
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                Expanded(child: const Text('Serviços Aceitos', style: TextStyle(fontWeight: FontWeight.bold))),
                Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.grey[700]),
              ])),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ServiceListView()),
            );             
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                Expanded(child: const Text('Serviços Disponíveis', style: TextStyle(fontWeight: FontWeight.bold))),
                Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.grey[700]),
              ])),
            )
      ],
    );
  }
}