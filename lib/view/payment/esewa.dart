import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_cart/controller/cart_controller.dart';
import 'package:quick_cart/utils/app_constants.dart';

class Esewa {
  final CartController cartController = Get.find<CartController>();

  pay(CartController cartController) {
    for (var cartItem in cartController.cartItems) {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test,
          clientId: AppConstants.Esewa_Client_Id,
          secretId: AppConstants.Esewa_Secret_key,
        ),
        esewaPayment: EsewaPayment(
          productId: cartItem.id,
          productName: cartItem.name,
          productPrice: cartItem.price.toString(),
          callbackUrl: '',
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult data) {
          debugPrint(":::SUCCESS::: => $data");

          // verifyTransactionStatus(data);
        },
        onPaymentFailure: (data) {
          debugPrint(":::FAILURE::: => $data");
        },
        onPaymentCancellation: (data) {
          debugPrint(":::CANCELLATION::: => $data");
        },
      );
    }
  }

  verify(EsewaPaymentSuccessResult result) {
    return result;
  }
}
