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
  final String image;
  final Category category;
  final int stock;
  final bool status;
  final dynamic size;
  final Color? color;
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
    this.color,
    required this.vendor,
    required this.type,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        price: json['price'].toDouble(),
        description: json['description'],
        image: json['image'],
        category: Category.fromJson(json['category']),
        stock: json['stock'],
        status: json['status'],
        size: json['size'],
        color: json['color'] != null ? Color.fromJson(json['color']) : null,
        vendor: Vendor.fromJson(json['vendor']),
        type: ProductType.fromJson(json['type']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'image': image,
        'category': category.toJson(),
        'stock': stock,
        'status': status,
        'size': size,
        'color': color?.toJson(),
        'vendor': vendor.toJson(),
        'type': type.toJson(),
      };
}

class Category {
  final String id;
  final String name;
  final String description;
  final bool status;
  final bool isSelected;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    this.isSelected = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        status: json['status'],
        isSelected: json['isSelected'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'status': status,
        'isSelected': isSelected,
      };

  Category copyWith({
    String? id,
    String? name,
    String? description,
    bool? status,
    bool? isSelected,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class Color {
  final String id;
  final String hex;

  Color({
    required this.id,
    required this.hex,
  });

  factory Color.fromJson(Map<String, dynamic> json) => Color(
        id: json['id'],
        hex: json['hex'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'hex': hex,
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
