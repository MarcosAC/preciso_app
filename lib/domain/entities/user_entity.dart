import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final bool isProfessional;
  final String? profession;
  final double? rating;
  final int? completedServices;
  final String? photoUrl;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.isProfessional,
    this.profession,
    this.rating,
    this.completedServices,
    this.photoUrl,
  });

  factory UserEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserEntity(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      isProfessional: data['isProfessional'] ?? false,
      profession: data['profession'],
      rating: data['rating']?.toDouble(),
      completedServices: data['completedServices'],
      photoUrl: data['photoUrl'],
    );
  }
}