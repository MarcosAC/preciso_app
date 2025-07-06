import 'package:preciso/domain/entities/service_entity.dart';
import 'package:preciso/domain/repositories/service_repository_interface.dart';

class GetClientRequestsUseCase {
  final IServiceRepository _repository;

  GetClientRequestsUseCase(this._repository);

  Stream<List<ServiceEntity>> call(String clientId) {
    return _repository.getClientRequests(clientId);
  }
}

class GetAvailableRequestsUseCase {
  final IServiceRepository _repository;

  GetAvailableRequestsUseCase(this._repository);

  Stream<List<ServiceEntity>> call(String serviceType) {
    return _repository.getAvailableRequests(serviceType);
  }
}

class CreateServiceRequestUseCase {
  final IServiceRepository _repository;

  CreateServiceRequestUseCase(this._repository);

  Future<void> call(ServiceEntity request) {
    return _repository.createServiceRequest(request);
  }
}

class UpdateRequestStatusUseCase {
  final IServiceRepository _repository;

  UpdateRequestStatusUseCase(this._repository);

  Future<void> call(String requestId, String professionalId, String status) {
    return _repository.updateRequestStatus(requestId, professionalId, status);
  }
}

class RateProfessionalUseCase {
  final IServiceRepository _repository;

  RateProfessionalUseCase(this._repository);

  Future<void> call(String professionalId, double rating) {
    return _repository.rateProfessional(professionalId, rating);
  }
}