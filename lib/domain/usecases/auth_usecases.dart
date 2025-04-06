import 'package:preciso/domain/entities/user_entity.dart';
import 'package:preciso/domain/repositories/auth_repository_interface.dart';

class LoginUseCase {
  final IAuthRepository _repository;

  LoginUseCase(this._repository);

  Future<UserEntity?> call(String email, String password) async {
    return await _repository.login(email, password);
  }
}

class RegisterClientUseCase {
  final IAuthRepository _repository;

  RegisterClientUseCase(this._repository);

  Future<UserEntity?> call(String name, String email, String password, String phone) async {
    return await _repository.registerClient(name, email, password, phone);
  }
}

class LogoutUseCase {
  final IAuthRepository _repository;
  LogoutUseCase(this._repository);
  Future<void> call() => _repository.logout();
}

// class GetAvailableRequestsUseCase {
//   final IServiceRepository _repository;
//   GetAvailableRequestsUseCase(this._repository);
//   Stream<List<ServiceEntity>> call(String serviceType) => 
//       _repository.getAvailableRequests(serviceType);
// }

// class UpdateRequestStatusUseCase {
//   final IServiceRepository _repository;
//   UpdateRequestStatusUseCase(this._repository);
//   Future<void> call(String requestId, String status) => 
//       _repository.updateRequestStatus(requestId, status);
// }

// class RateProfessionalUseCase {
//   final IServiceRepository _repository;
//   RateProfessionalUseCase(this._repository);
//   Future<void> call(String professionalId, double rating) => 
//       _repository.rateProfessional(professionalId, rating);
// }