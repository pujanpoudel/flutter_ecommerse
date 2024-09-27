class CartModel {
  final String id;
  final String name;
  final String? color;
  final String? size;
  final String imageUrl;
  final double price;
  int quantity;

  CartModel({
    required this.id,
    required this.name,
    this.color,
    this.size,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
    id: json['id'],
    name: json['name'],
    color: json['color'],
    size: json['size'],
    imageUrl: json['imageUrl'],
    price: json['price'].toDouble(),
    quantity: json['quantity'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'size': size,
    'imageUrl': imageUrl,
    'price': price,
    'quantity': quantity,
  };
}