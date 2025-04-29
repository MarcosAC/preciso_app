import 'package:flutter/foundation.dart';
import 'package:preciso/core/models/user_model.dart';
import 'package:preciso/domain/entities/user_entity.dart';
import 'package:preciso/domain/usecases/user_usecases.dart';

class UserViewModel with ChangeNotifier {
  late GetProfessionalsByServiceUseCase getProfessionalsByServiceUseCase;
  late GetUserByIdUseCase getUserByIdUseCase;
  late UpdateUserProfileUseCase updateUserProfileUseCase;
  late UploadProfileImageUseCase uploadProfileImageUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void updateDependencies({
    required GetProfessionalsByServiceUseCase getProfessionalsByServiceUseCase,
    required GetUserByIdUseCase getUserByIdUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required UploadProfileImageUseCase uploadProfileImageUseCase,
  }) {
    this.getProfessionalsByServiceUseCase = getProfessionalsByServiceUseCase;
    this.getUserByIdUseCase = getUserByIdUseCase;
    this.updateUserProfileUseCase = updateUserProfileUseCase;
    this.uploadProfileImageUseCase = uploadProfileImageUseCase;
  }

  Future<List<UserModel>> getProfessionalsByService(String serviceType) async {
    _isLoading = true;
    notifyListeners();

    try {
      final professionals = await getProfessionalsByServiceUseCase(serviceType);
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
      final user = await getUserByIdUseCase(userId);
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
      await updateUserProfileUseCase(user);
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
      final imageUrl = await uploadProfileImageUseCase(userId, imagePath);
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
