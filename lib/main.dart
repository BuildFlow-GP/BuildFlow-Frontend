import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'screens/sign/signin_screen.dart';
import 'screens/Design/choose_office.dart';
import 'package:get/get.dart';
import 'screens/search.dart';
import 'widgets/drawer_wrapper.dart';
import 'screens/payment_screen.dart';

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
      home: ChooseOfficeScreen(),
      //home: DrawerWrapper(child: const PaymentScreen()),
      //home: DrawerWrapper(child: const NoPermitScreen()),
    );
  }
}
