import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_cart/repo/auth_repo.dart';
import 'package:quick_cart/view/auth/sign_in_page.dart';
import 'package:quick_cart/view/product/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../landing page/landing_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();

    Timer(const Duration(seconds: 2), _navigateToNextPage);
  }

  void _navigateToNextPage() async {
    final authRepo = Get.find<AuthRepo>();
    bool isLoggedIn = authRepo.isLoggedIn();

    if (isLoggedIn) {
      Get.to(() => SignInPage());
    } else {
      Get.to(() => const LandingPage());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset('assets/logo.png'),
          ),
        ),
      ),
    );
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the app has been opened before
    bool isFirstRun = prefs.getBool('is_first_run') ?? true;

    // Check if user is logged in
    bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    // Determine where to route
    if (isFirstRun) {
      // First-time app launch
      prefs.setBool('is_first_run', false);
      Get.off(() => LandingPage());
    } else if (isLoggedIn) {
      // User is logged in
      Get.off(() => HomePage());
    } else {
      // User is logged out
      Get.off(() => SignInPage());
    }
  }
}
