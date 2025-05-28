import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'screens/sign/signin_screen.dart';
import 'package:get/get.dart';
// import 'widgets/drawer_wrapper.dart';
// import 'screens/payment_screen.dart';

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

      home: SignInScreen(),
      //home: DrawerWrapper(child: const TypeOfProjectPage()),
      //home: DrawerWrapper(child: const NoPermitScreen()),
    );
  }
}
