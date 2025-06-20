// user.dart

class User {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String userType;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Campos opcionais específicos de cada tipo de usuário
  final String? nome;
  final String? location;
  final String? contactNumber;
  final String? cnpj;
  final String? crmv;
  final String? storeType;
  final String? businessHours;
  final String? guardian; // Supondo que 'guardian' seja um campo de Tutor

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.userType,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.nome,
    this.location,
    this.contactNumber,
    this.cnpj,
    this.crmv,
    this.storeType,
    this.businessHours,
    this.guardian,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'],
      userType: json['userType'],
      active: json['active'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      nome: json['nome'],
      location: json['location'],
      contactNumber: json['contactNumber'],
      cnpj: json['cnpj'],
      crmv: json['crmv'],
      storeType: json['storeType'],
      businessHours: json['businessHours'],
      guardian: json['guardian'],
    );
  }
} 