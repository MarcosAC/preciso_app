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
              // Opcionalmente, tratar ou logar erros para itens individuais
            }
          }
        });
      }
    }
    return requests;
  }

  @override
  Stream<List<ServiceEntity>> getClientRequests(String clientId) {
    // Usar _dbRef.child() para referenciar o local, já que _dbRef aponta para a raiz
    return _dbRef
      .child('serviceRequests')
      .orderByChild('clientId')
      .equalTo(clientId)
      // Usar onValue para atualizações de stream
      .onValue
      .map((event) {
         List<ServiceEntity> requests = _mapSnapshotToList(event.snapshot);
         // Realtime DB não suporta ordem descendente diretamente na consulta, sort client-side
         requests.sort((a, b) => b.requestDate.compareTo(a.requestDate));
         return requests;
      });
  }

  @override
  Stream<List<ServiceEntity>> getAvailableRequests(String serviceType) {
    // Realtime DB não suporta múltiplas cláusulas where.
     // Vamos consultar por serviceType e filtrar por status client-side.
     // Sorting by requestDate descending will also be client-side.
    // Usar _dbRef.child() para referenciar o local
    return _dbRef
      .child('serviceRequests')
      .orderByChild('serviceType') // Order by serviceType
      .equalTo(serviceType)
      .onValue
      .map((event) {
         List<ServiceEntity> requests = _mapSnapshotToList(event.snapshot);
         // Filtrar por status client-side
         requests = requests.where((request) => request.status == 'pending').toList();
         // Sort by requestDate descending client-side
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
  Future<void> updateRequestStatus(String requestId, String status) async {
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
          // Garantir que as chaves existem e tratar possíveis nulos
          final currentRating = (userData['rating'] as num?)?.toDouble() ?? 0.0;
          final completedServices = (userData['completedServices'] as int?) ?? 0;

          final newCompletedServices = completedServices + 1;

           // Evitar divisão por zero se completedServices for 0 antes de incrementar
          final newRating = newCompletedServices > 0
              ? ((currentRating * completedServices) + rating) / newCompletedServices
              : rating; // Se for a primeira avaliação, a nova nota é apenas a nota fornecida
          
          // Usar update() para modificar campos específicos
          await _dbRef.child('users').child(professionalId).update({
            'rating': newRating,
            'completedServices': newCompletedServices,
          });
        } else {
          // Tratar o caso em que o nó do usuário não existe, se necessário
         print('Usuário com ID $professionalId not found.');
         // Dependendo dos requisitos, você pode lançar uma exceção ou tratar de forma diferente
        }     
      }
    } catch (e) {
      throw Exception('Falha ao avaliar profissional: $e');
    }
  }
}