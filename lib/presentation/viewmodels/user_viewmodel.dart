import 'package:flutter/foundation.dart';
import 'package:preciso/core/models/user_model.dart';
import 'package:preciso/domain/entities/user_entity.dart';
import 'package:preciso/domain/usecases/user_usecases.dart'; // Contém todos os User Use Cases

class UserViewModel with ChangeNotifier {
  // Declare as propriedades finais para os use cases
  final GetProfessionalsByServiceUseCase _getProfessionalsByServiceUseCase;
  final GetUserByIdUseCase _getUserByIdUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final UploadProfileImageUseCase _uploadProfileImageUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Construtor que injeta todos os use cases como parâmetros nomeados OBRIGATÓRIOS
  UserViewModel({
    required GetProfessionalsByServiceUseCase getProfessionalsByServiceUseCase,
    required GetUserByIdUseCase getUserByIdUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required UploadProfileImageUseCase uploadProfileImageUseCase,
  })  : _getProfessionalsByServiceUseCase = getProfessionalsByServiceUseCase,
        _getUserByIdUseCase = getUserByIdUseCase,
        _updateUserProfileUseCase = updateUserProfileUseCase,
        _uploadProfileImageUseCase = uploadProfileImageUseCase;

  // Remova completamente o método updateDependencies. Ele não é mais necessário.
  // void updateDependencies({
  //   required GetProfessionalsByServiceUseCase getProfessionalsByServiceUseCase,
  //   required GetUserByIdUseCase getUserByIdUseCase,
  //   required UpdateUserProfileUseCase updateUserProfileUseCase,
  //   required UploadProfileImageUseCase uploadProfileImageUseCase,
  // }) {
  //   this.getProfessionalsByServiceUseCase = getProfessionalsByServiceUseCase;
  //   this.getUserByIdUseCase = getUserByIdUseCase;
  //   this.updateUserProfileUseCase = updateUserProfileUseCase;
  //   this.uploadProfileImageUseCase = uploadProfileImageUseCase;
  // }

  Future<List<UserModel>> getProfessionalsByService(String serviceType) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Agora usa o use case injetado
      final professionals = await _getProfessionalsByServiceUseCase.call(serviceType);
      _errorMessage = null;
      return professionals;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserEntity?> getUserById(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Agora usa o use case injetado
      final user = await _getUserByIdUseCase.call(userId);
      _errorMessage = null;
      return user;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(UserEntity user) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Agora usa o use case injetado
      await _updateUserProfileUseCase.call(user);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> uploadProfileImage(String userId, String imagePath) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Agora usa o use case injetado
      final imageUrl = await _uploadProfileImageUseCase.call(userId, imagePath);
      _errorMessage = null;
      return imageUrl;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
}