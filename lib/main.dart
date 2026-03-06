import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart'; // ✅ Proper Smart Dustbin HomeScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Dustbin',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/splash', // ✅ Start from Splash
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const SmartDustbinApp(), // ✅ Proper Dashboard screen
      },
    );
  }
}
