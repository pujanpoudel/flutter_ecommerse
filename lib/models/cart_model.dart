class CartModel {
  final String id;
  final String name;
  final String? description;
  final List<CartVariant>? variant;
  final List<String> imageUrl;
  final String category;
  final String vendor;
  final double price;
  int quantity;

  CartModel({
    required this.id,
    required this.name,
    required this.description,
    this.variant,
    required this.imageUrl,
    required this.category,
    required this.vendor,
    required this.price,
    required this.quantity,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        variant: json['variant'] != null
            ? List<CartVariant>.from(
                json['variant'].map((x) => CartVariant?.fromJson(x)))
            : null,
        imageUrl: List<String>.from(json['imageUrl']),
        category: json['category'],
        vendor: json['vendor'],
        price: json['price'],
        quantity: json['quantity'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'variant': variant,
        'imageUrl': imageUrl,
        'category': category,
        'vendor': vendor,
        'price': price,
        'quantity': quantity,
      };
}

class CartVariant {
  String? color;
  String? size;
  int? stock;
  int quantity;

  CartVariant({
    this.color,
    this.size,
    this.stock,
    this.quantity = 1,
  });

  factory CartVariant.fromJson(Map<String, dynamic> json) => CartVariant(
        size: json['size'],
        color: json['color'],
        stock: json['stock'],
      );

  Map<String, dynamic> toJson() =>
      {'size': size, 'color': color, 'stock': stock};
}
