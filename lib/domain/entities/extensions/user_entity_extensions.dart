import 'package:preciso/domain/entities/user_entity.dart';

extension UserEntityExtensions on UserEntity {
  UserEntity copyWith({
    String? name,
    String? email,
    String? phone,
    bool? isProfessional,
    String? profession,
    double? rating,
    int? completedServices,
    String? photoUrl,
    List<String>? services,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isProfessional: isProfessional ?? this.isProfessional,
      profession: profession ?? this.profession,
      rating: rating ?? this.rating,
      completedServices: completedServices ?? this.completedServices,
      photoUrl: photoUrl ?? this.photoUrl,
      services: services ?? this.services,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}