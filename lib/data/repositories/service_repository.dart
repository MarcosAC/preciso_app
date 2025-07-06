import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:preciso/core/models/service_model.dart';
import 'package:preciso/domain/entities/service_entity.dart';
import 'package:preciso/domain/repositories/service_repository_interface.dart';

class ServiceRepository implements IServiceRepository {
  final DatabaseReference _dbRef;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  ServiceRepository({
    DatabaseReference? dbRef,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _dbRef = dbRef ?? FirebaseDatabase.instance.ref(),
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // Função auxiliar para converter Realtime Database snapshot children para Lista de ServiceEntity
  List<ServiceEntity> _mapSnapshotToList(DataSnapshot snapshot) {
    final List<ServiceEntity> requests = [];
    if (snapshot.value != null) {
      final Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;
      if (values != null) {
        values.forEach((key, value) {
          if (value is Map) {
            try {
               // Garantir que o mapa está corretamente tipado para fromMap
              requests.add(ServiceModel.fromMap(Map<String, dynamic>.from(value)).toEntity());
            } catch (e) {
              print('Erro mapeando dados do Realtime DB: $e');              
            }
          }
        });
      }
    }
    return requests;
  }

  @override
  Stream<List<ServiceEntity>> getClientRequests(String clientId) {  
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');

    return _dbRef
      .child('serviceRequests')
      .orderByChild('clientId')
      .equalTo(clientId)
      .onValue
      .map((event) {
         List<ServiceEntity> requests = _mapSnapshotToList(event.snapshot);
         requests.sort((a, b) => b.requestDate.compareTo(a.requestDate));
         return requests;
      });
  }

  @override
  Stream<List<ServiceEntity>> getAvailableRequests(String serviceType) {
    return _dbRef
      .child('serviceRequests')
      .orderByChild('serviceType')
      .equalTo(serviceType)
      .onValue
      .map((event) {
         List<ServiceEntity> requests = _mapSnapshotToList(event.snapshot);
         requests = requests.where((request) => request.status == 'pending').toList();
         requests.sort((a, b) => b.requestDate.compareTo(a.requestDate));
         return requests;
      });
  }

  @override
  Future<void> createServiceRequest(ServiceEntity request) async {
    try {
      await _dbRef
          .child('serviceRequests')
          .child(request.id)
          .set(ServiceModel.fromEntity(request).toMap());
    } catch (e) {
      throw Exception('Falha ao criar solicitação de serviço: $e');
    }
  }

  @override
  Future<void> updateRequestStatus(String requestId, String professionalId, String status) async {
    try {
      await _dbRef
          .child('serviceRequests')
          .child(requestId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Falha ao atualizar status da solicitação: $e');
    }
  }

  @override
  Future<void> rateProfessional(String professionalId, double rating) async {
    try {
      final event = await _dbRef.child('users]').child(professionalId).once();
      final snapshot = event.snapshot;

      if (snapshot.value != null) {
        final Map<dynamic, dynamic>? userData = snapshot.value as Map<dynamic, dynamic>?;

        if (userData != null) {
          final currentRating = (userData['rating'] as num?)?.toDouble() ?? 0.0;
          final completedServices = (userData['completedServices'] as int?) ?? 0;

          final newCompletedServices = completedServices + 1;

          final newRating = newCompletedServices > 0
              ? ((currentRating * completedServices) + rating) / newCompletedServices
              : rating;

          await _dbRef.child('users').child(professionalId).update({
            'rating': newRating,
            'completedServices': newCompletedServices,
          });
        } else {
         print('Usuário com ID $professionalId not found.');
        }     
      }
    } catch (e) {
      throw Exception('Falha ao avaliar profissional: $e');
    }
  }
}