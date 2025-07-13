class ServiceEntity {
  final String id;
  final String clientId;
  final String? clientName;
  final String professionalId;
  final String? professionalName;
  final String serviceType;
  final String description;
  final String address;
  final DateTime requestDate;
  final String status;
  final double? price;
  final double? rating;

  const ServiceEntity({
    required this.id,
    required this.clientId,
    this.clientName,
    required this.professionalId,
    this.professionalName,
    required this.serviceType,
    required this.description,
    required this.address,
    required this.requestDate,
    this.status = 'pending',
    this.price,
    this.rating,
  });

  // Método copyWith para criar novas instâncias com dados atualizados
  ServiceEntity copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? professionalId,
    String? professionalName,
    String? serviceType,
    String? description,
    String? address,
    DateTime? requestDate,
    String? status,
    double? price,
    double? rating,
  }) {
    return ServiceEntity(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      professionalId: professionalId ?? this.professionalId,
      professionalName: professionalName ?? this.professionalName,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      address: address ?? this.address,
      requestDate: requestDate ?? this.requestDate,
      status: status ?? this.status,
      price: price ?? this.price,
      rating: rating ?? this.rating,
    );
  }  
}