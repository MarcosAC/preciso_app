class ServiceEntity {
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

  const ServiceEntity({
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
}