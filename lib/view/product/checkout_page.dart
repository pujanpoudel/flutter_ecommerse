import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_cart/controller/auth_controller.dart';
import 'package:quick_cart/controller/cart_controller.dart';
import 'package:quick_cart/models/cart_model.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/profile/edit_profile_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  CheckoutPageState createState() => CheckoutPageState();
}

class CheckoutPageState extends State<CheckoutPage> {
  final AuthController _authController = Get.find<AuthController>();
  final CartController _cartController = Get.find<CartController>();

  String selectedDeliveryMethod = 'Home Delivery';

  final List<Map<String, String>> paymentMethods = [
    {
      'name': 'eSewa',
      'logo':
          'https://play-lh.googleusercontent.com/MRzMmiJAe0-xaEkDKB0MKwv1a3kjDieSfNuaIlRo750_EgqxjRFWKKF7xQyRSb4O95Y'
    },
    {
      'name': 'Khalti',
      'logo':
          'https://play-lh.googleusercontent.com/Xh_OlrdkF1UnGCnMN__4z-yXffBAEl0eUDeVDPr4UthOERV4Fll9S-TozSfnlXDFzw'
    },
    {
      'name': 'COD',
      'logo':
          'https://static.vecteezy.com/system/resources/previews/028/825/029/non_2x/speed-style-cash-on-delivery-banner-label-clipart-vector.jpg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.mainColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            ..._cartController.cartItems
                .map((cartItem) => _buildProductTile(cartItem)),
            const SizedBox(height: 10),
            const Text('Shipping address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() {
              final user = _authController.user.value;
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName ?? 'No name',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(user.address ?? 'No address'),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(EditProfilePage());
                      },
                      child: const Text('Change',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Payment',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(
                  width: 5,
                ),
                Row(
                  children: [
                    const Text(
                      '(Selected: ',
                    ),
                    Obx(() {
                      return Text(
                        _cartController.selectedPaymentMethod.value,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mainColor),
                      );
                    }),
                    const Text(
                      ')',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _cartController.selectedPaymentMethod.value =
                          paymentMethods[index]['name']!;
                    },
                    child: Obx(() {
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                _cartController.selectedPaymentMethod.value ==
                                        paymentMethods[index]['name']
                                    ? Colors.blue
                                    : Colors.grey,
                            width:
                                _cartController.selectedPaymentMethod.value ==
                                        paymentMethods[index]['name']
                                    ? 2
                                    : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Image.network(paymentMethods[index]['logo']!),
                            const SizedBox(width: 8),
                            Text(paymentMethods[index]['name']!),
                          ],
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Delivery method',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(
                  width: 5,
                ),
                const Text(
                  '(Selected: ',
                ),
                Text(
                  selectedDeliveryMethod,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainColor),
                ),
                const Text(
                  ')',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDeliveryMethodButton('Home Delivery',
                    'https://www.jotform.com/blog/wp-content/uploads/2020/05/How-to-start-a-food-delivery-business.png'),
                _buildDeliveryMethodButton('Pick Up',
                    'https://www.shutterstock.com/image-vector/isometric-pack-station-chain-autonomous-600nw-1699185274.jpg'),
              ],
            ),
            const SizedBox(height: 20),
            _buildOrderSummary(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // _cartController.submitOrder();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: const Text(
                  'SUBMIT ORDER',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  CartVariant? _getSelectedVariant(CartModel cartItem) {
    return cartItem.variant;
  }

  Widget _buildProductTile(CartModel cartItem) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              cartItem.imageUrl[0],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cartItem.category,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NRS ${cartItem.price.toString()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (cartItem.quantity > 1) {
                                CartVariant? selectedVariant =
                                    _getSelectedVariant(cartItem);

                                _cartController.updateQuantity(
                                  cartItem.id,
                                  cartItem.quantity - 1,
                                  color: selectedVariant!.color,
                                  size: selectedVariant.size,
                                );
                              }
                            },
                          ),
                          Text(
                            cartItem.quantity.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              CartVariant? selectedVariant =
                                  _getSelectedVariant(cartItem);

                              _cartController.updateQuantity(
                                cartItem.id,
                                cartItem.quantity + 1,
                                color: selectedVariant?.color,
                                size: selectedVariant?.size,
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildOrderSummary() {
    double totalPrice = _cartController.cartItems
        .fold(0, (sum, item) => sum + (item.price * item.quantity));

    double deliveryFee = selectedDeliveryMethod == 'Home Delivery' ? 100 : 0;

    double summary = totalPrice + deliveryFee;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Order:', style: TextStyle(color: Colors.grey)),
            Text('NRS ${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Delivery:', style: TextStyle(color: Colors.grey)),
            Text(
              deliveryFee > 0
                  ? 'NRS ${deliveryFee.toStringAsFixed(2)}'
                  : 'Free',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Summary:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('NRS ${summary.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryMethodButton(String method, String logo) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDeliveryMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            width: 3,
            color: selectedDeliveryMethod == method ? Colors.blue : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Image.network(
              logo,
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 4),
            Text(method, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
