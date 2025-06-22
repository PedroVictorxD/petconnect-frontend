import 'package:json_annotation/json_annotation.dart';

part 'pet.g.dart';

@JsonSerializable()
class Pet {
  final int? id;
  final String name;
  final String type; // 'Cachorro' ou 'Gato'
  final String? breed; // Raça
  final int age;
  final double weight;
  final Map<String, dynamic>? tutor; // Agora tutor é um objeto com id
  final String? photoUrl;
  final String? activityLevel;
  final String? notes;
  final bool? atendido;

  Pet({
    this.id,
    required this.name,
    required this.type,
    this.breed,
    required this.age,
    required this.weight,
    this.tutor,
    this.photoUrl,
    this.activityLevel,
    this.notes,
    this.atendido,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);
  Map<String, dynamic> toJson() => _$PetToJson(this);
} 