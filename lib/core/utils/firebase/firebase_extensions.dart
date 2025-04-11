import 'package:firebase_auth/firebase_auth.dart';
import 'package:preciso/domain/entities/user_entity.dart';

extension FirebaseTimestampExtensions on dynamic {
  DateTime? toDateTime() {
    if (this == null) return null;
    
    // Se já for DateTime, retorna direto
    if (this is DateTime) {
      return this as DateTime;
    }
    
    if (this is int) {
      return DateTime.fromMillisecondsSinceEpoch(this as int);
    } else if (this is String) {
      final milliseconds = int.tryParse(this as String);
      if (milliseconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(milliseconds);
      }
    } else if (this is Map && (this as Map)['.sv'] == 'timestamp') {
      return DateTime.now();
    }
    
    return null;
  }
}

extension DateTimeExtensions on DateTime {
  int toFirebaseTimestamp() => millisecondsSinceEpoch;
  
  Map<String, String> toServerTimestamp() => {'.sv': 'timestamp'};
}

extension UserEntityConversion on Map<String, dynamic> {
  UserEntity toUserEntity(User firebaseUser) {
    return UserEntity(
      uid: firebaseUser.uid,
      name: this['name'] as String? ?? firebaseUser.displayName ?? '',
      email: this['email'] as String? ?? firebaseUser.email ?? '',
      phone: this['phone'] as String? ?? firebaseUser.phoneNumber ?? '',
      isProfessional: this['isProfessional'] as bool? ?? false,
      profession: this['profession'] as String?,
      rating: (this['rating'] as num?)?.toDouble() ?? 0,
      completedServices: this['completedServices'] as int? ?? 0,
      photoUrl: this['photoUrl'] as String?,
      services: List<String>.from(this['services'] as List? ?? []),
      createdAt: this['createdAt'].toDateTime() ?? DateTime.now(),
    );
  }
}