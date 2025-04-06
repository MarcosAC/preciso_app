import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:preciso/domain/entities/user_entity.dart';
import 'package:preciso/domain/usecases/auth_usecases.dart';

class AuthViewModel with ChangeNotifier {
  late LoginUseCase loginUseCase;
  late RegisterClientUseCase registerClientUseCase;
  late LogoutUseCase logoutUseCase;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  void updateDependencies({
    required LoginUseCase loginUseCase,
    required RegisterClientUseCase registerClientUseCase,
    required LogoutUseCase logoutUseCase,
  }) {
    this.loginUseCase = loginUseCase;
    this.registerClientUseCase = registerClientUseCase;
    this.logoutUseCase = logoutUseCase;
  }

  Stream<UserEntity?> get userStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) return null;
          
      return UserEntity.fromFirestore(userDoc);
    });
  }

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

  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await logoutUseCase();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}