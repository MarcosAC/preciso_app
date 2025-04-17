import 'package:flutter/material.dart';
import 'package:preciso/domain/entities/user_entity.dart';

class UserInfoSection extends StatelessWidget {
  final UserEntity user;
  final bool isEditing;
  final Function(String)? onImageChanged;

  const UserInfoSection({
    super.key,
    required this.user,
    required this.isEditing,
    this.onImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : const AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
            if (isEditing)
              FloatingActionButton.small(
                onPressed: () async {
                  // Implementar seleção de imagem
                },
                child: const Icon(Icons.camera_alt),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(user.email),
      ],
    );
  }
}