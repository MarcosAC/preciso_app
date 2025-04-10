import 'package:preciso/domain/entities/user_entity.dart';
import 'package:preciso/domain/repositories/auth_repository_interface.dart';

class LoginUseCase {
  final IAuthRepository _repository;

  LoginUseCase(this._repository);

  Future<UserEntity?> call({
    required String email,
    required String password,
  }) async {
    return await _repository.login(
      email: email,
      password: password,
    );
  }
}

class RegisterClientUseCase {
  final IAuthRepository _repository;

  RegisterClientUseCase(this._repository);

  Future<UserEntity?> call({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? photoUrl,
  }) async {
    return await _repository.registerClient(
      name: name,
      email: email,
      password: password,
      phone: phone,
      photoUrl: photoUrl,
    );
  }
}

// class RegisterProfessionalUseCase {
//   final IAuthRepository _repository;

//   RegisterProfessionalUseCase(this._repository);

//   Future<UserEntity?> call({
//     required String name,
//     required String email,
//     required String password,
//     required String phone,
//     required String profession,
//     List<String>? services,
//     String? photoUrl,
//   }) async {
//     return await _repository.registerProfessional(
//       name: name,
//       email: email,
//       password: password,
//       phone: phone,
//       profession: profession,
//       services: services,
//       photoUrl: photoUrl,
//     );
//   }
// }

class LogoutUseCase {
  final IAuthRepository _repository;
  
  LogoutUseCase(this._repository);
  
  Future<void> call() => _repository.logout();
}

class SendPasswordResetEmailUseCase {
  final IAuthRepository _repository;

  SendPasswordResetEmailUseCase(this._repository);

  Future<void> call({required String email}) {
    return _repository.sendPasswordResetEmail(email: email);
  }
}

class UpdateEmailUseCase {
  final IAuthRepository _repository;

  UpdateEmailUseCase(this._repository);

  Future<void> call({
    required String newEmail,
    required String currentPassword,
  }) {
    return _repository.updateEmail(
      newEmail: newEmail,
      password: currentPassword,
    );
  }
}