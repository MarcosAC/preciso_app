import 'package:preciso/core/models/user_model.dart';
import 'package:preciso/domain/entities/user_entity.dart';
import 'package:preciso/domain/repositories/user_repository_interface.dart';

class GetProfessionalsByServiceUseCase {
  final IUserRepository _repository;

  GetProfessionalsByServiceUseCase(this._repository);

  Future<List<UserModel>> call(String serviceType) async {
    return await _repository.getProfessionalsByService(serviceType);
  }
}

class GetUserByIdUseCase {
  final IUserRepository _repository;

  GetUserByIdUseCase(this._repository);

  Future<UserEntity?> call(String userId) async {
    return await _repository.getUserById(userId);
  }
}

class UpdateUserProfileUseCase {
  final IUserRepository _repository;

  UpdateUserProfileUseCase(this._repository);

  Future<void> call(UserEntity user) async {
    return await _repository.updateUser(user);
  }
}

class UploadProfileImageUseCase {
  final IUserRepository _repository;

  UploadProfileImageUseCase(this._repository);

  Future<String> call(String userId, String imagePath) async {
    return await _repository.uploadProfileImage(userId, imagePath);
  }
}