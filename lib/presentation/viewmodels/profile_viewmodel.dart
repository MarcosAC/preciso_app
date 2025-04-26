import 'package:flutter/material.dart';
import 'package:preciso/domain/entities/extensions/user_entity_extensions.dart';
import 'package:preciso/domain/entities/user_entity.dart';
import 'package:preciso/domain/usecases/auth_usecases.dart';
import 'package:preciso/domain/usecases/user_usecases.dart';

class ProfileViewModel with ChangeNotifier {
  final GetUserByIdUseCase _getUserByIdUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final UploadProfileImageUseCase _uploadProfileImageUseCase;
  final LogoutUseCase logoutUseCase;

  UserEntity? _user;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;

  ProfileViewModel({
    required GetUserByIdUseCase getUserByIdUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required UploadProfileImageUseCase uploadProfileImageUseCase,
    required this.logoutUseCase,
  })  : _getUserByIdUseCase = getUserByIdUseCase,
        _updateUserProfileUseCase = updateUserProfileUseCase,
        _uploadProfileImageUseCase = uploadProfileImageUseCase;

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserProfile(String userId) async {
    _isLoading = true;
    _scheduleNotify();

    try {
      _user = await _getUserByIdUseCase(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao carregar perfil: ${e.toString()}';
    } finally {
      _isLoading = false;
      _scheduleNotify();
    }
  }

  void _scheduleNotify() {
    if (!_isDisposed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) notifyListeners();
      });
    }
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void toggleEditing() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  Future<bool> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? profession,
    List<String>? services,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = _user!.copyWith(
        name: name,
        email: email,
        phone: phone,
        profession: profession,
        services: services,
      );

      await _updateUserProfileUseCase(updatedUser);
      _user = updatedUser;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar perfil: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadProfileImage(String userId, String imagePath) async {
    _isLoading = true;
    notifyListeners();

    try {
      final imageUrl = await _uploadProfileImageUseCase(userId, imagePath);
      _user = _user?.copyWith(photoUrl: imageUrl);
      await _updateUserProfileUseCase(_user!);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao enviar imagem: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> performLogout() async {
    try {
      await logoutUseCase();
      _user = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Falha ao fazer logout: ${e.toString()}';
      notifyListeners();
      return false;
    }
  } 

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
} 