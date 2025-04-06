import 'package:preciso/domain/entities/service_entity.dart';

class ServiceModel {
  final String id;
  final String clientId;
  final String professionalId;
  final String serviceType;
  final String description;
  final String address;
  final DateTime requestDate;
  final String status;
  final double? price;
  final double? rating;

  ServiceModel({
    required this.id,
    required this.clientId,
    required this.professionalId,
    required this.serviceType,
    required this.description,
    required this.address,
    required this.requestDate,
    this.status = 'pending',
    this.price,
    this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'professionalId': professionalId,
      'serviceType': serviceType,
      'description': description,
      'address': address,
      'requestDate': requestDate.toIso8601String(),
      'status': status,
      'price': price,
      'rating': rating,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'],
      clientId: map['clientId'],
      professionalId: map['professionalId'],
      serviceType: map['serviceType'],
      description: map['description'],
      address: map['address'],
      requestDate: DateTime.parse(map['requestDate']),
      status: map['status'],
      price: map['price']?.toDouble(),
      rating: map['rating']?.toDouble(),
    );
  }

  ServiceEntity toEntity() {
    return ServiceEntity(
      id: id,
      clientId: clientId,
      professionalId: professionalId,
      serviceType: serviceType,
      description: description,
      address: address,
      requestDate: requestDate,
      status: status,
      price: price,
      rating: rating,
    );
  }

  factory ServiceModel.fromEntity(ServiceEntity entity) {
    return ServiceModel(
      id: entity.id,
      clientId: entity.clientId,
      professionalId: entity.professionalId,
      serviceType: entity.serviceType,
      description: entity.description,
      address: entity.address,
      requestDate: entity.requestDate,
      status: entity.status,
      price: entity.price,
      rating: entity.rating,
    );
  }
}