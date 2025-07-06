import 'package:preciso/domain/entities/service_entity.dart';

abstract class IServiceRepository {
  Stream<List<ServiceEntity>> getClientRequests(String clientId);
  Stream<List<ServiceEntity>> getAvailableRequests(String serviceType);
  Future<void> createServiceRequest(ServiceEntity request);
  Future<void> updateRequestStatus(String requestId, String professionalId, String status);
  Future<void> rateProfessional(String professionalId, double rating);
}