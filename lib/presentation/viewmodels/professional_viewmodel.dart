import 'package:flutter/foundation.dart';
import 'package:preciso/core/models/user_model.dart';
import 'package:preciso/data/repositories/service_repository.dart';
import 'package:preciso/data/repositories/user_repository.dart';
import 'package:preciso/domain/entities/service_entity.dart';

class ProfessionalViewModel with ChangeNotifier {
  late UserRepository _userRepository;
  late ServiceRepository _serviceRepository;

  List<UserModel> _professionals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UserModel> get professionals => _professionals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  void updateDependencies({
    required UserRepository userRepository,
    required ServiceRepository serviceRepository,
  }) {
    _userRepository = userRepository;
    _serviceRepository = serviceRepository;
    notifyListeners();
  }

  Future<void> loadProfessionals(String serviceType) async {
    _isLoading = true;
    notifyListeners();

    try {
      _professionals = await _userRepository.getProfessionalsByService(serviceType);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _professionals = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createRequest({
    required String professionalId,
    required String serviceType,
    String description = '',
    String address = '',
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final request = ServiceEntity(
        id: '',
        clientId: '',
        professionalId: professionalId,
        serviceType: serviceType,
        description: description,
        address: address,
        requestDate: DateTime.now(),
        status: 'pending',
      );

      await _serviceRepository.createServiceRequest(request);
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
}