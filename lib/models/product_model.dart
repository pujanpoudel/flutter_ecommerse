class ProductResponse {
  final String message;
  final bool success;
  final ProductData data;
  final dynamic warning;

  ProductResponse({
    required this.message,
    required this.success,
    required this.data,
    this.warning,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      ProductResponse(
        message: json['message'],
        success: json['success'],
        data: ProductData.fromJson(json['data']),
        warning: json['warning'],
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'success': success,
        'data': data.toJson(),
        'warning': warning,
      };
}

class ProductData {
  final int totalPages;
  final int currentPage;
  final List<Product> data;

  ProductData({
    required this.totalPages,
    required this.currentPage,
    required this.data,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) => ProductData(
        totalPages: json['total_pages'],
        currentPage: json['current_page'],
        data: List<Product>.from(json['data'].map((x) => Product.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'total_pages': totalPages,
        'current_page': currentPage,
        'data': List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> image;
  final Category category;
  final bool status;
  final Vendor vendor;
  final ProductType type;
  final int totalStock;
  final List<Variant> variants;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.category,
    required this.status,
    required this.vendor,
    required this.type,
    required this.totalStock,
    required this.variants,
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
        type: ProductType.fromJson(json['type']),
        totalStock: json['total_stock'],
        variants: List<Variant>.from(json['variants'].map((x) => Variant.fromJson(x))),
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
        'variants': List<dynamic>.from(variants.map((x) => x.toJson())),
      };
}

class Category {
  final String id;
  final String name;
  final String description;
    bool isSelected;


  Category({
    required this.id,
    required this.name,
    required this.description,
        this.isSelected = false,

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

class ProductType {
  final String id;
  final String name;
  final String description;

  ProductType({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ProductType.fromJson(Map<String, dynamic> json) => ProductType(
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
  final String size;
  final String color;
  final int stock;

  Variant({
    required this.size,
    required this.color,
    required this.stock,
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