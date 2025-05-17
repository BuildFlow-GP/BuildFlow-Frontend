import 'package:flutter/material.dart';
//import 'app.dart'; // Import the actual app configuration

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sign In',
      //home: HomeScreen(),
    );
  }
}
