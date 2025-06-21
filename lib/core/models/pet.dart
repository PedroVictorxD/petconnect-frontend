class Pet {
  final int? id;
  final String name;
  final String type;
  final double weight;
  final int age;
  final String activityLevel;
  final String breed;
  final String notes;
  final int? tutorId;

  Pet({
    this.id,
    required this.name,
    required this.type,
    required this.weight,
    required this.age,
    required this.activityLevel,
    required this.breed,
    required this.notes,
    this.tutorId,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
    id: json['id'],
    name: json['name'] ?? '',
    type: json['type'] ?? '',
    weight: (json['weight'] ?? 0).toDouble(),
    age: json['age'] ?? 0,
    activityLevel: json['activityLevel'] ?? '',
    breed: json['breed'] ?? '',
    notes: json['notes'] ?? '',
    tutorId: json['tutorId'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'weight': weight,
    'age': age,
    'activityLevel': activityLevel,
    'breed': breed,
    'notes': notes,
    'tutorId': tutorId,
  };
} 