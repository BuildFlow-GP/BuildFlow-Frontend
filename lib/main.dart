// import 'package:buildflow_frontend/screens/Design/no_permit_screen.dart';
// import 'package:buildflow_frontend/screens/Design/project_description.dart';
// import 'package:buildflow_frontend/screens/payment_screen.dart';

import 'package:buildflow_frontend/themes/app_colors.dart';
import 'package:buildflow_frontend/widgets/drawer_wrapper.dart';
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
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.accent, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey), // لون عنوان الحقل
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.accent, // لون المؤشر
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black), // لون النص داخل الحقول
        ),
      ),

      home: SignInScreen(),
      //home: DrawerWrapper(child: const TypeOfProjectPage()),
      //home: ProjectDetailsScreen(),
      //home: DrawerWrapper(child: const SignInScreen()),
      //home: DrawerWrapper(child: const NoPermitScreen()),
    );
  }
}
