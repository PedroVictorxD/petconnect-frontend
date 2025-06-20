class Produto {
  final String id;
  final String lojistaId;
  final String nome;
  final String description;
  final double price;
  final String unitOfMeasure;

  Produto({
    required this.id,
    required this.lojistaId,
    required this.nome,
    required this.description,
    required this.price,
    required this.unitOfMeasure,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      lojistaId: json['lojistaId'],
      nome: json['nome'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      unitOfMeasure: json['unitOfMeasure'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lojistaId': lojistaId,
      'nome': nome,
      'description': description,
      'price': price,
      'unitOfMeasure': unitOfMeasure,
    };
  }
} 