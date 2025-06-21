class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String location;
  String? type; // 'admin', 'tutor', 'lojista', 'veterinario'

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.location,
    this.type,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    password: json['password'] ?? '',
    phone: json['phone'] ?? '',
    location: json['location'] ?? '',
    type: json['type'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'phone': phone,
    'location': location,
    'type': type,
  };
} 