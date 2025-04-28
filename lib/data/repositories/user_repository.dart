import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:preciso/core/models/user_model.dart';
import 'package:preciso/domain/entities/user_entity.dart';
import 'package:preciso/domain/repositories/user_repository_interface.dart';

class UserRepository implements IUserRepository {
  final DatabaseReference _dbRef;
  final FirebaseStorage _storage;

  UserRepository({
    FirebaseAuth? firebaseAuth,
    DatabaseReference? dbRef,
    FirebaseStorage? firebaseStorage,
  }) : _dbRef = dbRef ?? FirebaseDatabase.instance.ref(),
       _storage = firebaseStorage ?? FirebaseStorage.instance;

  @override
  Future<List<UserModel>> getProfessionalsByService(String serviceType) async {
    try {
      final snapshot = await _dbRef.child('users').once();
      final data = snapshot.snapshot.value as Map?;

      if (data == null) return [];

      final professionals =
          data.entries
              .where(
                (entry) =>
                    entry.value['isProfessional'] == true &&
                    (entry.value['services'] as List<dynamic>?)?.contains(
                          serviceType,
                        ) ==
                        true,
              )
              .map(
                (entry) => UserModel.fromMap({
                  'uid': entry.key,
                  ...Map<String, dynamic>.from(entry.value),
                  'createdAt':
                      entry.value['createdAt'] ??
                      DateTime.now().millisecondsSinceEpoch,
                }),
              )
              .toList();

      return professionals;
    } catch (e) {
      throw Exception('Failed to load professionals: $e');
    }
  }

  @override
  Future<UserEntity?> getUserById(String userId) async {
    try {
      final snapshot = await _dbRef.child('users/$userId').once();
      final data = snapshot.snapshot.value;

      if (data == null) return null;

      final userData = Map<String, dynamic>.from(data as Map);

      return UserModel.fromMap({
        'uid': userId,
        ...userData,
        'createdAt':
            userData['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      }).toEntity();
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _dbRef.child('users/${user.uid}').update(userModel.toMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, String imagePath) async {
    try {
      final ref = _storage.ref().child('profile_images/$userId.jpg');
      await ref.putFile(File(imagePath));
      final imageUrl = await ref.getDownloadURL();

      await _dbRef.child('users/$userId').update({
        'photoUrl': imageUrl,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }
}
