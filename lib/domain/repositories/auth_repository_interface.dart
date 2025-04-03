import 'package:preciso/domain/entities/user_entity.dart';

abstract class IAuthRepository {
  Stream<UserEntity?> get user;
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> registerClient(
    String name,
    String email,
    String password,
    String phone,
  );
  Future<void> logout();
}