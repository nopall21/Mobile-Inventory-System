
class Item {
  int? id;
  String name;
  String description;
  double price;
  String category;
  String imagePath;
  int stock;

  Item({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imagePath,
    required this.stock,
  });

  // Convert Item object to Map (for SQLite)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imagePath': imagePath,
      'stock': stock,
    };
  }

  Item copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    double? price,
    int? stock,
    String? imagePath,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imagePath': imagePath,
      'stock': stock,
    };
  }

  // Create Item object from Map
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      category: map['category'],
      imagePath: map['imagePath'],
      stock: map['stock'],
    );
  }
}
