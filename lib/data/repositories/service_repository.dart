import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:preciso/core/models/service_model.dart';
import 'package:preciso/domain/entities/service_entity.dart';
import 'package:preciso/domain/entities/user_entity.dart';
import 'package:preciso/domain/repositories/service_repository_interface.dart';
import 'package:preciso/domain/repositories/user_repository_interface.dart';

class ServiceRepository implements IServiceRepository {
  final DatabaseReference _dbRef;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final IUserRepository _userRepository;

  ServiceRepository({
    DatabaseReference? dbRef,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    required IUserRepository userRepository,
  })  : _dbRef = dbRef ?? FirebaseDatabase.instance.ref(),
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _userRepository = userRepository;

  // Função auxiliar para converter Realtime Database snapshot children para Lista de ServiceEntity
  Future<List<ServiceEntity>> _mapSnapshotToList(DataSnapshot snapshot) async {
    final List<ServiceEntity> requests = [];
    if (snapshot.value != null) {
      final Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;
      if (values != null) {
        // Usar um loop for para poder usar 'await' dentro
        for (var entry in values.entries) {
          final value = entry.value;

          if (value is Map) {
            try {
              // Converte o mapa para ServiceModel e depois para ServiceEntity
              final serviceModel = ServiceModel.fromMap(Map<String, dynamic>.from(value));
              ServiceEntity service = serviceModel.toEntity(); // Cria a ServiceEntity inicial

              // --- Lógica para popular os nomes ---
              String? clientName;
              String? professionalName;

              try {
                final UserEntity? client = await _userRepository.getUserById(service.clientId);
                clientName = client?.name; // Use .name conforme sua UserEntity
              } catch (e) {
                print('Erro ao buscar nome do cliente ${service.clientId}: $e');
                // Opcional: Lançar o erro ou definir um nome padrão como 'Nome desconhecido'
              }

              try {
                final UserEntity? professional = await _userRepository.getUserById(service.professionalId);
                professionalName = professional?.name; // Use .name
              } catch (e) {
                print('Erro ao buscar nome do profissional ${service.professionalId}: $e');
                // Opcional: Lançar o erro ou definir um nome padrão
              }

              // Cria uma nova ServiceEntity com os nomes populados usando copyWith
              requests.add(service.copyWith(
                clientName: clientName,
                professionalName: professionalName,
              ));
            } catch (e) {
              print('Erro mapeando e populando dados do Realtime DB: $e');
            }
          }
        }
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
        .orderByChild('professionalId') // Ajuste aqui se você quer filtrar por clientId
        .equalTo(clientId)
        .onValue
        // Use .asyncMap para processar o snapshot assincronamente com _mapSnapshotToList
        .asyncMap((event) async {
          List<ServiceEntity> requests = await _mapSnapshotToList(event.snapshot);
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
        // Use .asyncMap para processar o snapshot assincronamente com _mapSnapshotToList
        .asyncMap((event) async {
          List<ServiceEntity> requests = await _mapSnapshotToList(event.snapshot);
          requests = requests.where((request) => request.status == 'pending').toList();
          requests.sort((a, b) => b.requestDate.compareTo(a.requestDate));
          return requests;
        });
  }

   @override
  Future<void> createServiceRequest(ServiceEntity request) async {
    try {
      // O ID do request será gerado no ViewModel ou UseCase, se você não quiser passar manualmente
      final newRef = _dbRef.child('serviceRequests').push(); // Gera um novo ID único
      final requestId = newRef.key; // Pega a chave gerada
      await newRef.set(ServiceModel.fromEntity(request.copyWith(id: requestId)).toMap()); // Usa o ID gerado
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
          .update({'status': status, 'professionalId': professionalId});
    } catch (e) {
      throw Exception('Falha ao atualizar status da solicitação: $e');
    }
  }

  @override
  Future<void> rateProfessional(String professionalId, double rating) async {
    try {
      final event = await _dbRef.child('users').child(professionalId).once(); // Corrigi 'users]' para 'users'
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