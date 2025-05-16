import 'LoginPage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'notification_setup.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeNotifications();
  runApp(const CartSnapApp());
}

class CartSnapApp extends StatelessWidget {
  const CartSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CartSnap',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCCE9FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            Icon(
              Icons.shopping_cart,
              size: 100,
              color: Color(0xFF7BA8F9),
            ),
            SizedBox(height: 20),
            Text(
              'CartSnap',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7BA8F9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}