class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String image;
  final Category category;
  final int stock;
  final bool status;
  final String? size;
  final Color color;
  final Vendor vendor;
  final ProductType type;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.category,
    required this.stock,
    required this.status,
    this.size,
    required this.color,
    required this.vendor,
    required this.type,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      description: json['description'],
      image: json['image'],
      category: Category.fromJson(json['category']),
      stock: json['stock'],
      status: json['status'],
      size: json['size'],
      color: Color.fromJson(json['color']),
      vendor: Vendor.fromJson(json['vendor']),
      type: ProductType.fromJson(json['type']),
    );
  }
}

class Category {
  final String id;
  final String name;
  final String description;

  Category({required this.id, required this.name, required this.description});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class Color {
  final String id;
  final String hex;

  Color({required this.id, required this.hex});

  factory Color.fromJson(Map<String, dynamic> json) {
    return Color(
      id: json['id'],
      hex: json['hex'],
    );
  }
}

class Vendor {
  final String id;
  final String storeName;

  Vendor({required this.id, required this.storeName});

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      storeName: json['store_name'],
    );
  }
}

class ProductType {
  final String id;
  final String name;
  final String description;

  ProductType({required this.id, required this.name, required this.description});

  factory ProductType.fromJson(Map<String, dynamic> json) {
    return ProductType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}