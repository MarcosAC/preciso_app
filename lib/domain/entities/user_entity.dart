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
  dynamic createdAt = map['createdAt'];
  DateTime createdAtDate;
  
  if (createdAt is DateTime) {
    createdAtDate = createdAt;
  } else {
    createdAtDate = createdAt.toDateTime() ?? DateTime.now();
  }

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
      'services': services,
      'createdAt': createdAt.toFirebaseTimestamp(),
    };
  }
}