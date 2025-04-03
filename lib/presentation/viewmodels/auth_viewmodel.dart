import 'package:flutter/foundation.dart';
import 'package:preciso/domain/usecases/auth_usecases.dart';
import 'package:preciso/domain/entities/user_entity.dart';

class AuthViewModel with ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterClientUseCase registerClientUseCase;
  final LogoutUseCase logoutUseCase;

  AuthViewModel({
    required this.loginUseCase,
    required this.registerClientUseCase,
    required this.logoutUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<UserEntity?> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await loginUseCase(email, password);
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<UserEntity?> registerClient(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await registerClientUseCase(name, email, password, phone);
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> logout() async {
    await logoutUseCase();
  }

  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }
}