import 'package:preciso/domain/repositories/auth_repository_interface.dart';

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity?> call(String email, String password) async {
    return await repository.login(email, password);
  }
}

class RegisterClientUseCase {
  final IAuthRepository repository;

  RegisterClientUseCase(this.repository);

  Future<UserEntity?> call(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    return await repository.registerClient(name, email, password, phone);
  }
}

class LogoutUseCase {
  final IAuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call() async {
    await repository.logout();
  }
}