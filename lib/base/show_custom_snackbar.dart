import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'big_text.dart';

void showCustomSnackBar(
    String message, {
      bool isError = true,
      String? title,
    }) {
  Get.snackbar(
    '',
    '',
    titleText: BigText(
      text: title ?? (isError ? "Error" : "Alert"),
      color: Colors.white,
    ),
    messageText: Text(
      message,
      style: const TextStyle(
        color: Colors.white,
      ),
    ),
    colorText: Colors.white,
    snackPosition: SnackPosition.TOP,
    backgroundColor: isError ? Colors.red.withOpacity(0.9) : Colors.green.withOpacity(0.9),
  );
}