import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:preciso/presentation/views/client/widgets/client_specific_section.dart';
import 'package:provider/provider.dart';
import 'package:preciso/presentation/viewmodels/profile_viewmodel.dart';
import '../../../views/profile/widgets/profile_app_bar.dart';
import '../../../views/profile/widgets/user_info_section.dart';

class ClientProfileScreen extends StatelessWidget {
  final String userId;

  const ClientProfileScreen({super.key, required this.userId});

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
     // Verificação correta para StatelessWidget
    if (pickedFile != null && context.mounted) {
      await Provider.of<ProfileViewModel>(context, listen: false)
          .uploadProfileImage(userId, pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    profileViewModel.loadUserProfile(userId);

    return Scaffold(
      appBar: const ProfileAppBar(title: 'Meu Perfil'),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading && viewModel.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.user == null) {
            return const Center(child: Text('Erro ao carregar perfil'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                UserInfoSection(
                  user: viewModel.user!,
                  isEditing: viewModel.isEditing,
                  onImageChanged: (path) => _pickImage(context),
                ),
                const SizedBox(height: 24),
                ClientSpecificSection(
                  user: viewModel.user!,
                  isEditing: viewModel.isEditing,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}