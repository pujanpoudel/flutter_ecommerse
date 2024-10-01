import 'package:get/get.dart';

import '../../routes/route_helper.dart';
import '../base/show_custom_snackbar.dart';

class ApiChecker {
  static void checkApi(Response response) {
    // Check the response status code
    switch (response.statusCode) {
      case 200:
      case 201:
      // Success - do nothing or handle any successful feedback here if needed
        break;

      case 400:
      // Bad request
        showCustomSnackBar(
          response.body != null && response.body['message'] != null
              ? response.body['message']
              : 'Bad request. Please try again.',
        );
        break;

      case 401:
      // Unauthorized - Redirect to sign in
        Get.offNamed(RouteHelper.getSignIn());
        showCustomSnackBar('Session expired. Please sign in again.');
        break;

      case 403:
      // Forbidden - User does not have permission
        showCustomSnackBar('You do not have permission to perform this action.');
        break;

      case 404:
      // Not found
        showCustomSnackBar('Requested resource not found.');
        break;

      case 500:
      // Internal server error
        showCustomSnackBar('Internal server error. Please try again later.');
        break;

      default:
      // Handle any other status codes or errors
        showCustomSnackBar(
          response.statusText ?? 'An unknown error occurred. Please try again.',
        );
        break;
    }
  }
}
