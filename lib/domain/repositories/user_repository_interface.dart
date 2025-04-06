import 'package:preciso/core/models/user_model.dart';
import 'package:preciso/domain/entities/user_entity.dart';

abstract class IUserRepository {
  Future<List<UserModel>> getProfessionalsByService(String serviceType);
  Future<UserEntity?> getUserById(String userId);
  Future<void> updateUser(UserEntity user);
  Future<UserEntity> registerProfessional({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String profession,
  });
  Future<String> uploadProfileImage(String userId, String imagePath);
}