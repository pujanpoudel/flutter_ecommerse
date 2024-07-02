import 'package:ecommerse_demo/auth/sign_in_pagr.dart';
import 'package:ecommerse_demo/home_page.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Column(
        children: [
          const TextField(
            obscureText: false,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(hintText: 'Enter Your Full Name'),
          ),
          const SizedBox(height: 20),
          const TextField(
            obscureText: false,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(hintText: 'Enter Your Email'),
          ),
          const SizedBox(height: 20),
          const TextField(
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(hintText: 'Enter Your Password'),
          ),
          const SizedBox(height: 20),
          const TextField(
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(hintText: 'Enter Your Password'),
          ),
          const SizedBox(height: 30),
          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
              child: const Text('Sign Up'))
        ],
      ),
    );
  }
}
