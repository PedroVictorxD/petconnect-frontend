// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vet_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VetService _$VetServiceFromJson(Map<String, dynamic> json) => VetService(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num).toDouble(),
  imageUrl: json['imageUrl'] as String?,
  ownerId: (json['ownerId'] as num?)?.toInt(),
  ownerName: json['ownerName'] as String?,
  ownerLocation: json['ownerLocation'] as String?,
  ownerPhone: json['ownerPhone'] as String?,
  ownerCrmv: json['ownerCrmv'] as String?,
  operatingHours: json['operatingHours'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$VetServiceToJson(VetService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'ownerId': instance.ownerId,
      'ownerName': instance.ownerName,
      'ownerLocation': instance.ownerLocation,
      'ownerPhone': instance.ownerPhone,
      'ownerCrmv': instance.ownerCrmv,
      'operatingHours': instance.operatingHours,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
