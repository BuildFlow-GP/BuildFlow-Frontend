import 'package:flutter/material.dart';
import 'screens/sign/signin_screen.dart';
import 'package:get/get.dart';
import 'screens/search.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // مهم قبل async init
  await GetStorage.init(); // ✅ تهيئة التخزين المحلي
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BuildFlow',
      debugShowCheckedModeBanner: false,
      // home: SignInScreen(),
      home: const SearchScreen(),
    );
  }
}
