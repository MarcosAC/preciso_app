import 'package:flutter/foundation.dart';
import 'package:preciso/domain/entities/service_entity.dart';
import 'package:preciso/domain/usecases/service_usecases.dart';

class ServiceViewModel with ChangeNotifier {
  final GetClientRequestsUseCase getClientRequestsUseCase;
  final CreateServiceRequestUseCase createServiceRequestUseCase;

  ServiceViewModel({
    required this.getClientRequestsUseCase,
    required this.createServiceRequestUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Stream<List<ServiceEntity>> getClientRequests(String clientId) {
    return getClientRequestsUseCase(clientId);
  }

  Future<void> createServiceRequest(ServiceEntity request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await createServiceRequestUseCase(request);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
}