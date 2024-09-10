import 'package:get/get.dart';
import '../view/auth/forgot_password_page.dart';
import '../view/auth/sign_in_page.dart';
import '../view/auth/sign_up_page.dart';
import '../view/product/home_page.dart';
import '../view/splash screen/splash_screen.dart';
import '../view/verification/email_verification_page.dart';

class RouteHelper {
  static const String initial = '/splash-screen';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/verify-email';
  static const String home = '/home';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String profile = '/profile';

  static String getInitial() => initial;
  static String getSignIn() => signIn;
  static String getSignUp() => signUp;
  static String getForgotPassword() => forgotPassword;
  static String getEmailVerificationPage() => emailVerification;
  static String getHome() => home;
  static String getProductDetail(int productId) =>
      '$productDetail?productId=$productId';
  static String getCart() => cart;
  static String getProfile() => profile;

  static List<GetPage> routes = [
    GetPage(name: initial, page: () => const SplashScreen()),
    GetPage(name: signIn, page: () => SignInPage()),
    GetPage(name: signUp, page: () => const SignUpPage()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordPage()),
    GetPage(name: home, page: () => const HomePage()),
    GetPage(name: emailVerification, page: () => const EmailVerificationPage()),
  ];
}
