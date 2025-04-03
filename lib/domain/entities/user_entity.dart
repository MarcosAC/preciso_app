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
}