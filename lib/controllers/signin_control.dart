// // login_controller.dart
// import 'package:get/get.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../services/signin_api.dart';
// import '../screens/user_profile.dart'; // Your UserProfilePage
// import 'dart:developer';

// class LoginController extends GetxController {
//   final AuthService _authService = AuthService();
//   final storage = FlutterSecureStorage();
//   var isLoading = false.obs;

//   Future<void> login(String email, String password) async {
//     try {
//       isLoading.value = true;
//       final result = await _authService.login(email, password);

//       // ✅ Save token
//       final token = result['token'];
//       if (token != null) {
//         await storage.write(key: 'jwt_token', value: token);

//         // ✅ Navigate to profile page
//         Get.off(() => const UserProfilePage());
//       } else {
//         Get.snackbar('Error', 'Token not found in response');
//       }
//     } catch (e) {
//       log('Login error: $e');
//       Get.snackbar('Error', 'Login failed. Please try again.');
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
