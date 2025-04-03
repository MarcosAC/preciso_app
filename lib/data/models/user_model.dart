import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:preciso/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required bool isProfessional,
    String? profession,
    double? rating,
    int? completedServices,
    String? photoUrl,
  }) : super(
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

  factory UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel(
      uid: snapshot.id,
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      isProfessional: data['isProfessional'],
      profession: data['profession'],
      rating: data['rating']?.toDouble(),
      completedServices: data['completedServices'],
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'isProfessional': isProfessional,
      if (profession != null) 'profession': profession,
      if (rating != null) 'rating': rating,
      if (completedServices != null) 'completedServices': completedServices,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }
}