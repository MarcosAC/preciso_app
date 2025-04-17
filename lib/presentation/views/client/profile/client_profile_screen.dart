import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:preciso/presentation/views/client/widgets/client_specific_section.dart';
import 'package:provider/provider.dart';
import 'package:preciso/presentation/viewmodels/profile_viewmodel.dart';
import '../../../views/profile/widgets/profile_app_bar.dart';
import '../../../views/profile/widgets/user_info_section.dart';

class ClientProfileScreen extends StatefulWidget {
  final String userId;

  const ClientProfileScreen({super.key, required this.userId});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Adiciona pequeno delay para garantir que o widget está montado
    await Future.delayed(Duration.zero);
    if (mounted) {
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      await viewModel.loadUserProfile(widget.userId);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null && mounted) {
      await Provider.of<ProfileViewModel>(context, listen: false)
          .uploadProfileImage(widget.userId, pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ProfileAppBar(title: 'Meu Perfil'),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading && viewModel.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.user == null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Erro ao carregar perfil'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadProfile,
                  child: const Text('Tentar novamente'),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                UserInfoSection(
                  user: viewModel.user!,
                  isEditing: viewModel.isEditing,
                  onImageChanged: (_) => _pickImage(),
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