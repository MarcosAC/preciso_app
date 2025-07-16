import 'dart:io';

import 'package:flutter/material.dart';
import 'package:preciso/domain/entities/user_entity.dart';
import 'package:image_picker/image_picker.dart';

class UserInfoSection extends StatefulWidget {
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
  State<UserInfoSection> createState() => _UserInfoSectionState();
}

class _UserInfoSectionState extends State<UserInfoSection> {
  File? _pickedImage;

  // Função auxiliar para gerar as iniciais
  String _getInitials(String name) {
    if (name.isEmpty) {
      return '';
    }
    // Pega os primeiros dois caracteres e converte para maiúscula
    return name.substring(0, name.length >= 2 ? 2 : name.length).toUpperCase();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image !=null) {
      setState(() {
        _pickedImage = File(image.path);
      });

      // Notificar o widget pai sobre a mudança da imagem
      if (widget.onImageChanged != null) {
        widget.onImageChanged!(image.path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine qual imagem exibir: a recém-selecionada, a URL existente ou as iniciais.
    ImageProvider? avatarImage;

    if (_pickedImage != null) {
      avatarImage = FileImage(_pickedImage!);
    } else if (widget.user.photoUrl != null && widget.user.photoUrl!.isNotEmpty) {
      avatarImage = NetworkImage(widget.user.photoUrl!);
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: avatarImage,
              backgroundColor: avatarImage == null ? Theme.of(context).primaryColor : null,
              child: avatarImage == null
                  ? Text(_getInitials(widget.user.name), style: const TextStyle(fontSize: 40, color: Colors.white),)
                  : null),
            if (widget.isEditing)
              FloatingActionButton.small(
                onPressed: _pickImage,                
                child: const Icon(Icons.camera_alt),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.user.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(widget.user.email),
      ],
    );
  }
}