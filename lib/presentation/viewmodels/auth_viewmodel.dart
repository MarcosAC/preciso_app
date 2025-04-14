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

  // Getters para estado do usuário
  User? get firebaseUser => _auth.currentUser;
  
 UserEntity? get currentUser {
    final user = firebaseUser;
    return user != null 
      ? UserEntity.fromFirebase(user: user, data: {}) 
      : null;
  }

  Future<UserEntity?> getCurrentUserWithData() async {
    final user = firebaseUser;
    if (user == null) return null;

    try {
      final snapshot = await _dbRef.child('users/${user.uid}').get();
      final data = snapshot.exists 
          ? Map<String, dynamic>.from(snapshot.value as Map) 
          : <String, dynamic>{};
      
      return UserEntity.fromFirebase(
        user: user,
        data: data,
      );
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return UserEntity.fromFirebaseUser(user);
    }
  }

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
      
      try {
        final snapshot = await _dbRef.child('users/${firebaseUser.uid}').get();
        final userData = snapshot.exists 
            ? Map<String, dynamic>.from(snapshot.value as Map) 
            : <String, dynamic>{};
        
        return UserEntity.fromFirebase(
          user: firebaseUser,
          data: userData,
        );
      } catch (e) {
        debugPrint('Error in userStream: $e');
        return UserEntity.fromFirebaseUser(firebaseUser);
      }
    });
  }

  Future<UserEntity?> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final user = await loginUseCase(email: email, password: password);
      _setLoading(false);
      return user;
    } catch (e) {
      _setError(e.toString());
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
    _setLoading(true);
    try {
      final user = await registerClientUseCase(
        name: name,
        email: email,
        password: password,
        phone: phone,
        photoUrl: photoUrl,
      );
      _setLoading(false);
      return user;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await logoutUseCase();
      _errorMessage = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void resetError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Métodos privados para manipulação de estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
}