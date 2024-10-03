class Product {
  final String id;
  final String name;
  final double price;
  final String? description;
  final List<String> image;
  final Category category;
  final bool status;
  final Vendor vendor;
  final Type type;
  final int totalStock;
  final List<Variant>? variant;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.image,
    required this.category,
    required this.status,
    required this.vendor,
    required this.type,
    required this.totalStock,
    this.variant,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        price: json['price'].toDouble(),
        description: json['description'],
        image: List<String>.from(json['image']),
        category: Category.fromJson(json['category']),
        status: json['status'],
        vendor: Vendor.fromJson(json['vendor']),
        type: Type.fromJson(json['type']),
        totalStock: json['total_stock'],
        variant: List<Variant>.from(
            json['variants'].map((x) => Variant?.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'image': image,
        'category': category.toJson(),
        'status': status,
        'vendor': vendor.toJson(),
        'type': type.toJson(),
        'total_stock': totalStock,
        'variants': List<dynamic>.from(variant!.map((x) => x.toJson())),
      };
}

class Category {
  final String id;
  final String name;
  final String description;
  Category({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'],
        name: json['name'],
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };
}

class Vendor {
  final String id;
  final String storeName;

  Vendor({
    required this.id,
    required this.storeName,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
        id: json['id'],
        storeName: json['store_name'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'store_name': storeName,
      };
}

class Type {
  final String id;
  final String name;
  final String description;

  Type({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Type.fromJson(Map<String, dynamic> json) => Type(
        id: json['id'],
        name: json['name'],
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };
}

class Variant {
  final String? size;
  final String? color;
  final int? stock;

  Variant({
    this.size,
    this.color,
    this.stock,
  });

  factory Variant.fromJson(Map<String, dynamic> json) => Variant(
        size: json['size'],
        color: json['color'],
        stock: json['stock'],
      );

  Map<String, dynamic> toJson() => {
        'size': size,
        'color': color,
        'stock': stock,
      };
}
