import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:preciso/domain/entities/user_entity.dart';
import 'package:preciso/domain/usecases/auth_usecases.dart';
import 'package:preciso/core/utils/firebase/firebase_extensions.dart';

class AuthViewModel with ChangeNotifier {
  late LoginUseCase loginUseCase;
  late RegisterClientUseCase registerClientUseCase;
  late LogoutUseCase logoutUseCase;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

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
    
    final snapshot = await _dbRef.child('users/${firebaseUser.uid}').get();
    
    if (!snapshot.exists) {
      return UserEntity(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        phone: firebaseUser.phoneNumber ?? '',
        isProfessional: false,
        createdAt: DateTime.now(),
      );
    }

    final userData = Map<String, dynamic>.from(snapshot.value as Map);
    
    dynamic createdAt = userData['createdAt'];
    DateTime createdAtDate;
    
    if (createdAt is DateTime) {
      createdAtDate = createdAt;
    } else {
      createdAtDate = createdAt.toDateTime() ?? DateTime.now();
    }

    return UserEntity(
      uid: firebaseUser.uid,
      name: userData['name'] ?? firebaseUser.displayName ?? '',
      email: userData['email'] ?? firebaseUser.email ?? '',
      phone: userData['phone'] ?? firebaseUser.phoneNumber ?? '',
      isProfessional: userData['isProfessional'] ?? false,
      profession: userData['profession'],
      rating: (userData['rating'] ?? 0).toDouble(),
      completedServices: userData['completedServices'] ?? 0,
      photoUrl: userData['photoUrl'],
      services: List<String>.from(userData['services'] ?? []),
      createdAt: createdAtDate,
    );
  });
}

  Future<UserEntity?> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await loginUseCase(email: email, password: password);
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

  Future<UserEntity?> registerClient({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await registerClientUseCase(
        name: name,
        email: email,
        password: password,
        phone: phone,
        photoUrl: photoUrl,
      );
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