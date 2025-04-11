import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:preciso/domain/entities/user_entity.dart';
import 'package:preciso/domain/repositories/auth_repository_interface.dart';

class AuthRepository implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final DatabaseReference _dbRef;

  AuthRepository({FirebaseAuth? firebaseAuth, DatabaseReference? dbRef})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _dbRef = dbRef ?? FirebaseDatabase.instance.ref();

  @override
  Stream<UserEntity?> get user {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _fetchUserData(firebaseUser);
    });
  }

  @override
  Future<UserEntity?> login({required String email, required String password}) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _fetchUserData(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Falha no login: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> registerClient({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? photoUrl,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);
      
      final userData = {
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'photoUrl': photoUrl,
        'isProfessional': false,
        'createdAt': ServerValue.timestamp,
        'rating': 0,
        'completedServices': 0,
      };

      await _dbRef.child('users/${userCredential.user!.uid}').set(userData);

      return UserEntity.fromMap({
        'uid': userCredential.user!.uid, ...userData,
        'createdAt': DateTime.now(), // Valor temporário até ser atualizado pelo servidor
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Falha no cadastro: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> registerProfessional({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String profession,
    List<String>? services,
    String? photoUrl,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);

      final userData = {
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'photoUrl': photoUrl,
        'isProfessional': true,
        'profession': profession,
        'services': services ?? [],
        'createdAt': ServerValue.timestamp,
        'rating': 0,
        'completedServices': 0,
      };

      await _dbRef.child('users/${userCredential.user!.uid}').set(userData);

      return UserEntity.fromMap({'uid': userCredential.user!.uid, ...userData});
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Falha no cadastro profissional: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Falha ao sair: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  @override
  Future<void> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      await user.verifyBeforeUpdateEmail(newEmail);
      await _dbRef.child('users/${user.uid}/email').set(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserEntity> _fetchUserData(User firebaseUser) async {
    try {
      final snapshot = await _dbRef.child('users/${firebaseUser.uid}').get();

      if (!snapshot.exists) {
        return UserEntity(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          phone: firebaseUser.phoneNumber ?? '',
          isProfessional: false,
          createdAt: DateTime.now(),
          services: [],
          rating: 0,
          completedServices: 0,
        );
      }

      final userData = Map<String, dynamic>.from(snapshot.value as Map);

      // Convertendo o timestamp do Firebase para DateTime
      dynamic createdAt = userData['createdAt'];
      DateTime createdAtDate;
      
      if (createdAt is int) {
        createdAtDate = DateTime.fromMillisecondsSinceEpoch(createdAt);
      } else if (createdAt == null) {
        createdAtDate = DateTime.now();
      } else {
        // Se for outro tipo inesperado, usa a data atual
        createdAtDate = DateTime.now();
      }

      return UserEntity.fromMap({
        'uid': firebaseUser.uid,
        ...userData,        
        'createdAt': createdAtDate,
      });
    } catch (e) {
      throw Exception('Failed to fetch user data: ${e.toString()}');
    }
  }

  Exception _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return Exception('Email inválido');
      case 'user-disabled':
        return Exception('Usuário desativado');
      case 'user-not-found':
        return Exception('Usuário não encontrado');
      case 'wrong-password':
        return Exception('Senha incorreta');
      case 'email-already-in-use':
        return Exception('Email já cadastrado');
      case 'weak-password':
        return Exception('Senha fraca (mínimo 6 caracteres)');
      case 'operation-not-allowed':
        return Exception('Operação não permitida');
      case 'requires-recent-login':
        return Exception('Reautenticação necessária');
      default:
        return Exception(e.message ?? 'Erro desconhecido');
    }
  }
}
