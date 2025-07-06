// preciso/presentation/viewmodels/professional_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:preciso/core/models/user_model.dart';
// Importe os use cases necessários
import 'package:preciso/domain/usecases/user_usecases.dart';   // Para GetProfessionalsByServiceUseCase, GetUserByIdUseCase
import 'package:preciso/domain/usecases/service_usecases.dart'; // Para CreateServiceRequestUseCase, GetAvailableRequestsUseCase, UpdateRequestStatusUseCase
import 'package:preciso/domain/entities/service_entity.dart'; // Para ServiceEntity

class ProfessionalViewModel with ChangeNotifier {
  // Use cases agora são final e recebidos no construtor
  final GetProfessionalsByServiceUseCase _getProfessionalsByServiceUseCase;
  final CreateServiceRequestUseCase _createServiceRequestUseCase;
  final GetAvailableRequestsUseCase _getAvailableRequestsUseCase;
  final GetUserByIdUseCase _getUserByIdUseCase;
  final UpdateRequestStatusUseCase _updateRequestStatusUseCase;


  List<UserModel> _professionals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<UserModel> get professionals => _professionals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Construtor que injeta TODOS os use cases como parâmetros nomeados obrigatórios
  ProfessionalViewModel({
    required GetProfessionalsByServiceUseCase getProfessionalsByServiceUseCase,
    required CreateServiceRequestUseCase createServiceRequestUseCase,
    required GetAvailableRequestsUseCase getAvailableRequestsUseCase,
    required GetUserByIdUseCase getUserByIdUseCase,
    required UpdateRequestStatusUseCase updateRequestStatusUseCase,
  })  : _getProfessionalsByServiceUseCase = getProfessionalsByServiceUseCase,
        _createServiceRequestUseCase = createServiceRequestUseCase,
        _getAvailableRequestsUseCase = getAvailableRequestsUseCase,
        _getUserByIdUseCase = getUserByIdUseCase,
        _updateRequestStatusUseCase = updateRequestStatusUseCase;


  Future<void> loadProfessionals(String serviceType) async {
    _isLoading = true;
    notifyListeners();

    try {
      _professionals = await _getProfessionalsByServiceUseCase.call(serviceType);
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
        clientId: '', // Lembre-se de obter o clientId do usuário logado
        professionalId: professionalId,
        serviceType: serviceType,
        description: description,
        address: address,
        requestDate: DateTime.now(),
        status: 'pending',
        price: null,
        rating: null,
      );

      await _createServiceRequestUseCase.call(request);
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- ALTERAÇÃO AQUI: Usando .first para coletar o primeiro valor do Stream ---
  Future<List<ServiceEntity>> getAvailableRequestsForProfessional(String professionalId) async {
    _isLoading = true;
    _errorMessage = null; // Limpa a mensagem de erro anterior
    notifyListeners();

    try {
      // Coleta o primeiro evento do Stream e aguarda a sua conclusão
      final requests = await _getAvailableRequestsUseCase.call(professionalId).first;
      _errorMessage = null;
      return requests;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // --- FIM DA ALTERAÇÃO ---

  Future<void> updateServiceStatusForProfessional(String requestId, professionalId, String newStatus) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _updateRequestStatusUseCase.call(requestId, professionalId, newStatus);
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
}