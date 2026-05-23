import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.unit,
    this.category = 'General',
    this.description = '',
    this.emoji = '??',
  });

  final String id;
  final String name;
  final double price;
  final int stock;
  final String imageUrl;
  final String unit;
  final String category;
  final String description;
  final String emoji;

  bool get isAvailable => stock > 0;

  /// Stock level label for UI chips.
  String get stockLabel {
    if (!isAvailable) return 'Out of Stock';
    if (stock <= 3) return 'Limited';
    return 'In Stock';
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
    String? imageUrl,
    String? unit,
    String? category,
    String? description,
    String? emoji,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
      'unit': unit,
      'category': category,
      'description': description,
      'emoji': emoji,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      imageUrl: map['image_url'] as String? ?? '',
      unit: map['unit'] as String? ?? 'kg',
      category: map['category'] as String? ?? 'General',
      description: map['description'] as String? ?? '',
      emoji: map['emoji'] as String? ?? '??',
    );
  }

  @override
  List<Object?> get props =>
      [id, name, price, stock, imageUrl, unit, category, description, emoji];
}
