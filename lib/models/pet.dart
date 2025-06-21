import 'package:json_annotation/json_annotation.dart';

part 'pet.g.dart';

@JsonSerializable()
class Pet {
  final int? id;
  final String name;
  final String species; // 'Cachorro' ou 'Gato'
  final String? breed; // Raça
  final int age;
  final double weight;
  final int tutorId;

  Pet({
    this.id,
    required this.name,
    required this.species,
    this.breed,
    required this.age,
    required this.weight,
    required this.tutorId,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);
  Map<String, dynamic> toJson() => _$PetToJson(this);
} 