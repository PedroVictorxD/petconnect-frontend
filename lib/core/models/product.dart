class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String measurementUnit;
  final int quantity;
  final String category;
  final int? ownerId;
  final String? ownerName;
  final String? ownerLocation;
  final String? ownerPhone;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.measurementUnit,
    required this.quantity,
    required this.category,
    this.ownerId,
    this.ownerName,
    this.ownerLocation,
    this.ownerPhone,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    imageUrl: json['imageUrl'] ?? '',
    measurementUnit: json['measurementUnit'] ?? '',
    quantity: json['quantity'] ?? 0,
    category: json['category'] ?? '',
    ownerId: json['ownerId'],
    ownerName: json['ownerName'],
    ownerLocation: json['ownerLocation'],
    ownerPhone: json['ownerPhone'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'imageUrl': imageUrl,
    'measurementUnit': measurementUnit,
    'quantity': quantity,
    'category': category,
    'ownerId': ownerId,
    'ownerName': ownerName,
    'ownerLocation': ownerLocation,
    'ownerPhone': ownerPhone,
  };
} 