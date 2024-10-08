import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:quick_cart/controller/cart_controller.dart';

class Khalti {
  final CartController cartController = Get.find<CartController>();

  Widget build(BuildContext context) {
    return KhaltiScope(
      publicKey: '3ded9f4191f142d7938f0446f830c752',
      enabledDebugging: true,
      builder: (BuildContext context, navKey) {
        return MaterialApp(
          title: 'Payment',
          navigatorKey: navKey,
          localizationsDelegates: const [
            KhaltiLocalizations.delegate,
          ],
          home: Scaffold(
            appBar: AppBar(title: const Text('Khalti Payment')),
            body: const Center(child: Text('Payment Page')),
          ),
        );
      },
    );
  }

  void payWithKhaltiInApp(BuildContext context, CartController cartController) {
    for (var cartItem in cartController.cartItems) {
      KhaltiScope.of(context).pay(
        config: PaymentConfig(
          amount: cartItem.price.toInt(),
          productIdentity: cartItem.id,
          productName: cartItem.name,
        ),
        preferences: [PaymentPreference.khalti],
        onSuccess: (PaymentSuccessModel success) => onSuccess(context, success),
        onFailure: (PaymentFailureModel failure) => onFailure(context, failure),
        onCancel: onCancel,
      );
    }
  }

  void onSuccess(BuildContext context, PaymentSuccessModel success) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Payment Successful"),
          content: Text('Transaction ID: ${success.idx}'),
          actions: [
            SimpleDialogOption(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void onFailure(BuildContext context, PaymentFailureModel failure) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Payment Failed"),
          content: Text('Error Message: ${failure.message}'),
          actions: [
            SimpleDialogOption(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void onCancel() {
    debugPrint('Payment canceled');
  }
}
