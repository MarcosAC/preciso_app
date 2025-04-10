import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity {
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

  const UserEntity({
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

  // Converte de Map (compatível com ambos Firestore e Realtime Database)
  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      isProfessional: map['isProfessional'] ?? false,
      profession: map['profession'],
      services: List<String>.from(map['services'] ?? []),
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      completedServices: (map['completedServices'] as int?) ?? 0,
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] is int 
              ? map['createdAt'] 
              : (map['createdAt'] as Timestamp).millisecondsSinceEpoch)
          : DateTime.now(),
    );
  }

  // Converte para Map (compatível com ambos bancos)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'isProfessional': isProfessional,
      if (profession != null) 'profession': profession,
      'services': services,
      'rating': rating,
      'completedServices': completedServices,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Cópia com alterações (útil para atualizações)
  UserEntity copyWith({
    String? name,
    String? email,
    String? phone,
    String? profession,
    List<String>? services,
    double? rating,
    int? completedServices,
    String? photoUrl,
  }) {
    return UserEntity(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isProfessional: isProfessional,
      profession: profession ?? this.profession,
      services: services ?? this.services,
      rating: rating ?? this.rating,
      completedServices: completedServices ?? this.completedServices,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
    );
  }

  // Helper para verificar se é profissional de um serviço específico
  bool isProfessionalFor(String service) {
    return isProfessional && services.contains(service);
  }
}