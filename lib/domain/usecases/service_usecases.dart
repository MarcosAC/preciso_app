import 'package:preciso/domain/entities/service_entity.dart';
import 'package:preciso/domain/repositories/service_repository_interface.dart';

class GetClientRequestsUseCase {
  final IServiceRepository repository;

  GetClientRequestsUseCase(this.repository);

  Stream<List<ServiceEntity>> call(String clientId) {
    return repository.getClientRequests(clientId);
  }
}

class CreateServiceRequestUseCase {
  final IServiceRepository repository;

  CreateServiceRequestUseCase(this.repository);

  Future<void> call(ServiceEntity request) {
    return repository.createServiceRequest(request);
  }
}