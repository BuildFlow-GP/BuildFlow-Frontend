import 'package:get/get.dart';
import '../services/signin_api.dart';
import 'dart:developer';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();

  var isLoading = false.obs;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final result = await _authService.login(email, password);
      // Handle successful login, e.g., navigate to home screen
      log('Login successful: $result');
    } catch (e) {
      // Handle login error, e.g., show error message
      log('Login error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
