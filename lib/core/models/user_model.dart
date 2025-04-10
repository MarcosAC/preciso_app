import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:preciso/domain/entities/user_entity.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final bool isProfessional;
  final String? profession;
  final List<String> services; 
  final double rating;
  final int completedServices;
  final String? photoUrl;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.isProfessional,
    this.profession,
    this.services = const [],
    this.rating = 0,
    this.completedServices = 0,
    this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      isProfessional: map['isProfessional'] ?? false,
      profession: map['profession'],
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      completedServices: (map['completedServices'] as int?) ?? 0,
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] is int 
              ? map['createdAt'] 
              : (map['createdAt'] as Timestamp).millisecondsSinceEpoch)
          : DateTime.now(), // Fallback seguro
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'isProfessional': isProfessional,
      if (profession != null) 'profession': profession,
      'rating': rating,
      'completedServices': completedServices,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      isProfessional: isProfessional,
      profession: profession,
      rating: rating,
      completedServices: completedServices,
      photoUrl: photoUrl,
      createdAt: createdAt,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      isProfessional: entity.isProfessional,
      profession: entity.profession,
      rating: entity.rating,
      completedServices: entity.completedServices,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
    );
  }
}