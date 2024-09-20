import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_cart/controller/auth_controller.dart';
import 'package:quick_cart/utils/colors.dart';
import 'package:quick_cart/view/profile/edit_profile_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final AuthController _authController = Get.find<AuthController>();
  String selectedDeliveryMethod = 'home';
  int selectedPaymentMethod = 0;

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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Checkout', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shipping address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() {
              // Use Obx to reactively update the UI when the user data changes
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
            const SizedBox(height: 24),
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
                    Text(
                      paymentMethods[selectedPaymentMethod]['name']!,
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
                      setState(() {
                        selectedPaymentMethod = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedPaymentMethod == index
                              ? Colors.blue
                              : Colors.grey,
                          width: selectedPaymentMethod == index ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Image.network(paymentMethods[index]['logo']!),
                          Text(paymentMethods[index]['name']!),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order:', style: TextStyle(color: Colors.grey)),
                Text('112\$', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery:', style: TextStyle(color: Colors.grey)),
                Text('15\$', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('127\$', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 80),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
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
