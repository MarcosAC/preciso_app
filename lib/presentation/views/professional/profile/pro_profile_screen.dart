import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:preciso/presentation/views/professional/widgets/pro_specific_section.dart';
import 'package:provider/provider.dart';
import 'package:preciso/presentation/viewmodels/profile_viewmodel.dart';
import '../../../views/profile/widgets/profile_app_bar.dart';
import '../../../views/profile/widgets/user_info_section.dart';

class ProfessionalProfileScreen extends StatefulWidget {
  final String userId;

  const ProfessionalProfileScreen({super.key, required this.userId});

  @override
  State<ProfessionalProfileScreen> createState() => _ProfessionalProfileScreenSate();
}

class _ProfessionalProfileScreenSate extends State<ProfessionalProfileScreen> {
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
  
  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null && context.mounted) {
      await Provider.of<ProfileViewModel>(context, listen: false)
          .uploadProfileImage(widget.userId, pickedFile.path);
    }
  }

  Future<void> _performLogout(BuildContext context) async {
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    await viewModel.performLogout();
    
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/login', 
        (route) => false
      );
      
      _showLogoutMessage(context);
    }
  }

  void _showLogoutMessage(BuildContext context) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Você foi desconectado com sucesso'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar saída - Pro Profile'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
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

    if (confirmed == true && context.mounted) {
      await _performLogout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    profileViewModel.loadUserProfile(widget.userId);

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
                  onPressed: () => profileViewModel.loadUserProfile(widget.userId),
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
                  onImageChanged: (_) => _pickImage(context),
                ),
                const SizedBox(height: 24),
                ProSpecificSection(
                  user: viewModel.user!,
                  isEditing: viewModel.isEditing,
                  onLogout: () => _confirmLogout(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}