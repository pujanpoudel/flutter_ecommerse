import 'package:flutter/material.dart';
import 'package:quick_cart/models/cart_model.dart';

class CartItem extends StatelessWidget {
  final CartModel item;

  const CartItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            item.imageUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${item.color} - Size ${item.size}'),
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.remove), onPressed: () {}),
                    Text(item.quantity.toString()),
                    IconButton(icon: const Icon(Icons.add), onPressed: () {}),
                    const Spacer(),
                    Text('${item.price}\$',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
