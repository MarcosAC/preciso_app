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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    if (mounted) {
      await Provider.of<ProfileViewModel>(context, listen: false)
          .loadUserProfile(widget.userId);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar saída'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Provider.of<ProfileViewModel>(context, listen: false).performLogout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/login', 
          (route) => false,
        );
      }
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
                  onLogout: _handleLogout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

   Future<void> _pickImage() async {
    if (!mounted) return;
    
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile == null || !mounted) return;
    
    try {
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      await viewModel.uploadProfileImage(widget.userId, pickedFile.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao enviar imagem')),
        );
      }
    }
  }
}