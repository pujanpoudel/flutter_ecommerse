import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_cart/repo/auth_repo.dart';
import 'package:quick_cart/view/cart/cart_page.dart';
import 'package:quick_cart/view/landing%20page/landing_page.dart';
import 'package:quick_cart/view/splash%20screen/splash_screen.dart';
import '../view/auth/forgot_password_page.dart';
import '../view/auth/sign_in_page.dart';
import '../view/auth/sign_up_page.dart';
import '../view/product/home_page.dart';
import '../view/verification/email_verification_page.dart';
import '../view/profile/profile_page.dart';
import '../view/product/product_detail_page.dart';

class RouteHelper {
  static const String initial = '/splash-screen';
  static const String dashboard = '/dashboard';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/verify-email';
  static const String home = '/home';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String profile = '/profile';

  // Routes helpers
  static String getInitial() => initial;
  static String getDashboard() => dashboard;
  static String getSignIn() => signIn;
  static String getSignUp() => signUp;
  static String getForgotPassword() => forgotPassword;
  static String getEmailVerificationPage() => emailVerification;
  static String getHome() => home;
  static String getProductDetail(int productId) =>
      '$productDetail?productId=$productId';
  static String getCart() => cart;
  static String getProfile() => profile;

  static Future<bool> isLoggedIn() async {
    AuthRepo authRepo = Get.find<AuthRepo>();
    return authRepo.isLoggedIn();
  }

  static Future<bool> isFirstLaunch() async {
    AuthRepo authRepo = Get.find<AuthRepo>();
    return authRepo.isFirstRun();
  }

  static List<GetPage> routes = [
    GetPage(name: initial, page: () => const SplashScreen()),
    GetPage(name: dashboard, page: () => const LandingPage()),
    GetPage(name: signIn, page: () => SignInPage()),
    GetPage(name: signUp, page: () => const SignUpPage()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordPage()),
    GetPage(name: home, page: () => const HomePage()),
    GetPage(
      name: productDetail,
      page: () {
        final productId = Get.parameters['productId'];
        return ProductDetailPage(productId: productId ?? '');
      },
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: cart,
      page: () => const CartPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: emailVerification, page: () => const EmailVerificationPage()),
    GetPage(
      name: profile,
      page: () => const ProfilePage(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!Get.find<AuthRepo>().isLoggedIn()) {
      return const RouteSettings(name: RouteHelper.signIn);
    }
    return null;
  }
}
