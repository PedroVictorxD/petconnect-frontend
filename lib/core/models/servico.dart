class Servico {
  final String id;
  final String veterinarioId;
  final String nome;
  final String description;
  final double price;

  Servico({
    required this.id,
    required this.veterinarioId,
    required this.nome,
    required this.description,
    required this.price,
  });

  factory Servico.fromJson(Map<String, dynamic> json) {
    return Servico(
      id: json['id'],
      veterinarioId: json['veterinarioId'],
      nome: json['nome'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'veterinarioId': veterinarioId,
      'nome': nome,
      'description': description,
      'price': price,
    };
  }
} 