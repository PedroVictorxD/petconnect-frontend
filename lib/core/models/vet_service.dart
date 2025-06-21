class VetService {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String specialty;
  final String duration;
  final int? vetId;

  VetService({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.specialty,
    required this.duration,
    this.vetId,
  });

  factory VetService.fromJson(Map<String, dynamic> json) => VetService(
    id: json['id'],
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    specialty: json['specialty'] ?? '',
    duration: json['duration'] ?? '',
    vetId: json['vetId'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'specialty': specialty,
    'duration': duration,
    'vetId': vetId,
  };
} 