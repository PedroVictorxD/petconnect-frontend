// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  price: (json['price'] as num).toDouble(),
  imageUrl: json['imageUrl'] as String?,
  measurementUnit: json['measurementUnit'] as String?,
  ownerId: (json['ownerId'] as num?)?.toInt(),
  ownerName: json['ownerName'] as String?,
  ownerLocation: json['ownerLocation'] as String?,
  ownerPhone: json['ownerPhone'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'imageUrl': instance.imageUrl,
  'measurementUnit': instance.measurementUnit,
  'ownerId': instance.ownerId,
  'ownerName': instance.ownerName,
  'ownerLocation': instance.ownerLocation,
  'ownerPhone': instance.ownerPhone,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
