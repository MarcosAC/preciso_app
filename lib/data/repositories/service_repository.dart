import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:preciso/core/models/service_model.dart';
import 'package:preciso/domain/entities/service_entity.dart';
import 'package:preciso/domain/repositories/service_repository_interface.dart';

class ServiceRepository implements IServiceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  ServiceRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Stream<List<ServiceEntity>> getClientRequests(String clientId) {
    return _firestore
        .collection('serviceRequests')
        .where('clientId', isEqualTo: clientId)
        .orderBy('requestDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceModel.fromMap(doc.data()).toEntity())
            .toList());
  }

  @override
  Stream<List<ServiceEntity>> getAvailableRequests(String serviceType) {
    return _firestore
        .collection('serviceRequests')
        .where('serviceType', isEqualTo: serviceType)
        .where('status', isEqualTo: 'pending')
        .orderBy('requestDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceModel.fromMap(doc.data()).toEntity())
            .toList());
  }

  @override
  Future<void> createServiceRequest(ServiceEntity request) async {
    try {
      await _firestore
          .collection('serviceRequests')
          .doc(request.id)
          .set(ServiceModel.fromEntity(request).toMap());
    } catch (e) {
      throw Exception('Failed to create service request: $e');
    }
  }

  @override
  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _firestore
          .collection('serviceRequests')
          .doc(requestId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Failed to update request status: $e');
    }
  }

  @override
  Future<void> rateProfessional(String professionalId, double rating) async {
    try {
      final doc = await _firestore.collection('users').doc(professionalId).get();
      if (doc.exists) {
        final currentRating = doc.data()?['rating']?.toDouble() ?? 0.0;
        final completedServices = doc.data()?['completedServices'] ?? 0;
        
        final newCompletedServices = completedServices + 1;
        final newRating = ((currentRating * completedServices) + rating) / newCompletedServices;

        await _firestore.collection('users').doc(professionalId).update({
          'rating': newRating,
          'completedServices': newCompletedServices,
        });
      }
    } catch (e) {
      throw Exception('Failed to rate professional: $e');
    }
  }
}