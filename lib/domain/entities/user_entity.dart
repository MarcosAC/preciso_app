import 'package:firebase_auth/firebase_auth.dart';
import 'package:preciso/core/utils/firebase/firebase_extensions.dart';

class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final bool isProfessional;
  final String? profession;
  final double rating;
  final int completedServices;
  final String? photoUrl;
  final List<String> services;
  final DateTime createdAt;

  UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.isProfessional,
    this.profession,
    this.rating = 0,
    this.completedServices = 0,
    this.photoUrl,
    this.services = const [],
    required this.createdAt,
  });

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    final createdAtDate =
        (createdAt is DateTime)
            ? createdAt
            : createdAt.toDateTime() ?? DateTime.now();

    return UserEntity(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      isProfessional: map['isProfessional'] as bool? ?? false,
      profession: map['profession'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      completedServices: map['completedServices'] as int? ?? 0,
      photoUrl: map['photoUrl'] as String?,
      services: List<String>.from(map['services'] as List? ?? []),
      createdAt: createdAtDate,
    );
  }

  factory UserEntity.fromFirebase({
    required User user,
    required Map<String, dynamic> data,
  }) {
    return UserEntity(
      uid: user.uid,
      name: data['name'] ?? user.displayName ?? '',
      email: data['email'] ?? user.email ?? '',
      phone: data['phone'] ?? user.phoneNumber ?? '',
      isProfessional: data['isProfessional'] ?? false,
      profession: data['profession'],
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      completedServices: data['completedServices'] ?? 0,
      photoUrl: data['photoUrl'] ?? user.photoURL,
      services: List<String>.from(data['services'] ?? []),
      createdAt: data['createdAt']?.toDateTime() ?? DateTime.now(),
    );
  }

  factory UserEntity.fromFirebaseUser(
    User user, {
    Map<String, dynamic>? additionalData,
  }) {
    return UserEntity(
      uid: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      isProfessional: additionalData?['isProfessional'] ?? false,
      profession: additionalData?['profession'],
      rating: additionalData?['rating']?.toDouble() ?? 0,
      completedServices: additionalData?['completedServices'] ?? 0,
      photoUrl: user.photoURL ?? additionalData?['photoUrl'],
      services: List<String>.from(additionalData?['services'] ?? []),
      createdAt: additionalData?['createdAt']?.toDateTime() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirebase() {
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
      'services': services,
      'createdAt': createdAt.toFirebaseTimestamp(),
    };
  }

  Map<String, dynamic> toMap() {
    return toFirebase(); // Ou implemente diferente se necessário
  }
}
