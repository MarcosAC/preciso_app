import 'package:preciso/domain/entities/user_entity.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final bool isProfessional;
  final String? profession;
  final double rating;
  final int completedServices;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.isProfessional,
    this.profession,
    this.rating = 0,
    this.completedServices = 0,
    this.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      isProfessional: map['isProfessional'] ?? false,
      profession: map['profession'],
      rating: (map['rating'] ?? 0).toDouble(),
      completedServices: map['completedServices'] ?? 0,
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'isProfessional': isProfessional,
      'profession': profession,
      'rating': rating,
      'completedServices': completedServices,
      'photoUrl': photoUrl,
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
      rating: entity.rating ?? 0,
      completedServices: entity.completedServices ?? 0,
      photoUrl: entity.photoUrl,
    );
  }
}