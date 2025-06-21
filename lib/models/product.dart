import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final int? id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final String? measurementUnit;
  final int? ownerId;
  final String? ownerName;
  final String? ownerLocation;
  final String? ownerPhone;
  final String? createdAt;
  final String? updatedAt;

  Product({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.measurementUnit,
    this.ownerId,
    this.ownerName,
    this.ownerLocation,
    this.ownerPhone,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
} 