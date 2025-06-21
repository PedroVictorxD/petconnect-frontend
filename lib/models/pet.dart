import 'package:json_annotation/json_annotation.dart';

part 'pet.g.dart';

@JsonSerializable()
class Pet {
  final int? id;
  final String name;
  final String type;
  final double weight;
  final int age;
  final String activityLevel;
  final String? breed;
  final String? notes;
  final int? tutorId;
  final String? createdAt;
  final String? updatedAt;

  Pet({
    this.id,
    required this.name,
    required this.type,
    required this.weight,
    required this.age,
    required this.activityLevel,
    this.breed,
    this.notes,
    this.tutorId,
    this.createdAt,
    this.updatedAt,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);
  Map<String, dynamic> toJson() => _$PetToJson(this);
} 