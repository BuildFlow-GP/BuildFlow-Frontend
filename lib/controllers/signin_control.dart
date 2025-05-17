import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/signin_api.dart';
import 'dart:developer';
import '../screens/home_page.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();
  final storage = FlutterSecureStorage();
  var isLoading = false.obs;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final result = await _authService.login(email, password);

      final token = result['token'];
      final user = result['user'];
      final userType = result['userType'];

      if (token != null && user != null) {
        await storage.write(key: 'jwt_token', value: token);
        await storage.write(key: 'user_type', value: userType);

        Get.offAll(() => const HomeScreen());
      } else {
        Get.snackbar('Error', 'Login failed. Invalid response.');
      }
    } catch (e) {
      log('Login error: $e');
      Get.snackbar('Error', 'Login failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
