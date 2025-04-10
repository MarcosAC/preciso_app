import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:preciso/core/models/user_model.dart';
import 'package:preciso/domain/entities/user_entity.dart';
import 'package:preciso/domain/repositories/user_repository_interface.dart';

class UserRepository implements IUserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  UserRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<List<UserModel>> getProfessionalsByService(String serviceType) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('isProfessional', isEqualTo: true)
          .where('services', arrayContains: serviceType)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel.fromMap({
          'uid': doc.id,
          ...data,
          'createdAt': data['createdAt']?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to load professionals: $e');
    }
  }

  @override
  Future<UserEntity?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap({
          'uid': doc.id,
          ...doc.data()!,
          'createdAt': doc.data()!['createdAt']?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
        }).toEntity();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(
        UserModel.fromEntity(user).toMap()
      );
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<UserEntity> registerProfessional({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String profession,
    List<String>? services,
    String? photoUrl,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);

      final user = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        isProfessional: true,
        profession: profession,
        services: services ?? [],
        rating: 0,
        completedServices: 0,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(user.toMap());

      return user.toEntity();
    } catch (e) {
      throw Exception('Failed to register professional: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, String imagePath) async {
    try {
      final ref = _storage.ref().child('profile_images/$userId.jpg');
      await ref.putFile(File(imagePath));
      final imageUrl = await ref.getDownloadURL();
      
      await _firestore.collection('users').doc(userId).update({
        'photoUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }
}