import 'package:preciso/domain/entities/user_entity.dart';

abstract class IAuthRepository {
  // Stream que emite o usuário atual (null se deslogado)
  Stream<UserEntity?> get user;
  
  Future<UserEntity?> login(String email, String password);
    
  Future<UserEntity?> registerClient({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? photoUrl,
  });

  Future<UserEntity?> registerProfessional({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String profession,
    List<String>? services,
    String? photoUrl,
  });
  
  Future<void> logout();

  // Recuperação de senha (novo método)
  Future<void> sendPasswordResetEmail(String email);

  // Atualiza email do usuário logado (novo método)
  Future<void> updateEmail({
    required String newEmail,
    required String password,
  });
}