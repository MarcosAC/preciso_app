import 'package:flutter/foundation.dart';
import 'package:preciso/domain/entities/service_entity.dart';
import 'package:preciso/domain/usecases/service_usecases.dart';

class ServiceViewModel with ChangeNotifier {
  late GetClientRequestsUseCase getClientRequestsUseCase;
  late GetAvailableRequestsUseCase getAvailableRequestsUseCase;
  late CreateServiceRequestUseCase createServiceRequestUseCase;
  late UpdateRequestStatusUseCase updateRequestStatusUseCase;
  late RateProfessionalUseCase rateProfessionalUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  void updateDependencies({
    required GetClientRequestsUseCase getClientRequestsUseCase,
    required GetAvailableRequestsUseCase getAvailableRequestsUseCase,
    required CreateServiceRequestUseCase createServiceRequestUseCase,
    required UpdateRequestStatusUseCase updateRequestStatusUseCase,
    required RateProfessionalUseCase rateProfessionalUseCase,
  }) {
    this.getClientRequestsUseCase = getClientRequestsUseCase;
    this.getAvailableRequestsUseCase = getAvailableRequestsUseCase;
    this.createServiceRequestUseCase = createServiceRequestUseCase;
    this.updateRequestStatusUseCase = updateRequestStatusUseCase;
    this.rateProfessionalUseCase = rateProfessionalUseCase;
  }

  Stream<List<ServiceEntity>> getClientRequests(String clientId) {
    return getClientRequestsUseCase(clientId);
  }  

  Stream<List<ServiceEntity>> getAvailableRequests(String serviceType) {
    return getAvailableRequestsUseCase(serviceType);
  }

  Future<void> createServiceRequest(ServiceEntity request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await createServiceRequestUseCase(request);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
 
  Future<void> updateRequestStatus(String requestId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await updateRequestStatusUseCase(requestId, status);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rateProfessional(String professionalId, double rating) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await rateProfessionalUseCase(professionalId, rating);
      _errorMessage = null;
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

  Future<void> createServiceRequestWithCallback(
    ServiceEntity request, {
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      await createServiceRequest(request);
      if (onSuccess != null) onSuccess();
    } catch (e) {
      if (onError != null) onError(e.toString());
      rethrow;
    }
  }
}