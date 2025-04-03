import 'package:firebase_auth/firebase_auth.dart';
import 'package:preciso/data/models/user_model.dart';
import 'package:preciso/domain/repositories/auth_repository_interface.dart';

class AuthRepository implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<UserModel?> get user {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return UserModel(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        phone: firebaseUser.phoneNumber ?? '',
        isProfessional: false,
      );
    });
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebase(userCredential.user);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<UserModel?> registerClient(
    String name,
    String email,
    String password,
    String phone,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      return _userFromFirebase(userCredential.user, phone: phone);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  UserModel? _userFromFirebase(User? user, {String phone = ''}) {
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      phone: user.phoneNumber ?? phone,
      isProfessional: false,
    );
  }
}