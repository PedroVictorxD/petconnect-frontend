import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? location;
  final String? createdAt;
  final String? updatedAt;
  final String? crmv; // Para veterinários
  final String? cnpj; // Para lojistas
  final String? responsibleName; // Para lojistas
  final String? storeType; // Para lojistas
  final String? operatingHours; // Para lojistas
  final String? dtype; // Adicionado para identificar o tipo de usuário

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.location,
    this.createdAt,
    this.updatedAt,
    this.crmv,
    this.cnpj,
    this.responsibleName,
    this.storeType,
    this.operatingHours,
    this.dtype,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool get isVeterinario => dtype == 'VETERINARIO';
  bool get isLojista => dtype == 'LOJISTA';
  bool get isTutor => dtype == 'TUTOR';
  bool get isAdmin => dtype == 'ADMIN';
} 