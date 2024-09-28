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
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();

    // Check app state and navigate accordingly after delay
    Timer(const Duration(seconds: 2), _checkLoginStatus);
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authRepo = Get.find<AuthRepo>();

    // Check if it's the first time the app is run
    bool isFirstRun = prefs.getBool('is_first_run') ?? true;
    bool isLoggedIn = authRepo.isLoggedIn(); // Check login status

    if (isFirstRun) {
      // First-time app launch, navigate to LandingPage
      await prefs.setBool('is_first_run', false);
      Get.off(() => const LandingPage());
    } else if (isLoggedIn) {
      // User is logged in, navigate to HomePage
      Get.off(() => const HomePage());
    } else {
      // User is logged out, navigate to SignInPage
      Get.off(() => SignInPage());
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
}
