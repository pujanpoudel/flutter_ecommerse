import 'package:flutter/material.dart';
import 'package:quick_cart/models/cart_model.dart';

class CartItem extends StatefulWidget {
  final CartModel item;
  final Function(int) onQuantityChanged;
  final VoidCallback onDelete;

  const CartItem({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            widget.item.imageUrl[0],
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.item.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text(widget.item.variant!.isNotEmpty
                  ? 'Color: ${widget.item.variant?.first.color} - Size: ${widget.item.variant?.first.size}'
                  : 'No variant selected'),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () =>
                        widget.onQuantityChanged(widget.item.quantity - 1),
                  ),
                  Text(widget.item.quantity.toString()),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () =>
                        widget.onQuantityChanged(widget.item.quantity + 1),
                  ),
                  const Spacer(),
                  Text('${widget.item.price}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          )),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}
