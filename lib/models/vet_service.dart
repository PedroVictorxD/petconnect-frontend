import 'package:json_annotation/json_annotation.dart';

part 'vet_service.g.dart';

@JsonSerializable()
class VetService {
  final int? id;
  final String name;
  final String? description;
  final double price;
  final int? ownerId;
  final String? ownerName;
  final String? ownerLocation;
  final String? ownerPhone;
  final String? ownerCrmv;
  final String? operatingHours;
  final String? createdAt;
  final String? updatedAt;

  VetService({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.ownerId,
    this.ownerName,
    this.ownerLocation,
    this.ownerPhone,
    this.ownerCrmv,
    this.operatingHours,
    this.createdAt,
    this.updatedAt,
  });

  factory VetService.fromJson(Map<String, dynamic> json) => _$VetServiceFromJson(json);
  Map<String, dynamic> toJson() => _$VetServiceToJson(this);
} 