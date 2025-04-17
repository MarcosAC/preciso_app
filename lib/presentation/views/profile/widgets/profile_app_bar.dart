import 'package:flutter/material.dart';
import 'package:preciso/presentation/viewmodels/profile_viewmodel.dart';
import 'package:provider/provider.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showEditButton;

  const ProfileAppBar({
    super.key,
    required this.title,
    this.showEditButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return AppBar(
      title: Text(title),
      actions: [
        if (showEditButton && !viewModel.isEditing)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: viewModel.toggleEditing,
          ),
        if (viewModel.isEditing)
          TextButton(
            onPressed: () async {
              await viewModel.updateUserProfile();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perfil atualizado!')),
                );
              }
            },
            child: const Text('SALVAR', style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}