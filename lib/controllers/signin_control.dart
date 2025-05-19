import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/signin_api.dart';
import '../models/user_model.dart'; // Add this
import '../models/session.dart';
import '../screens/home_page.dart';
import 'package:logger/logger.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();
  final storage = FlutterSecureStorage();
  final Logger logger = Logger();

  var isLoading = false.obs;

  Future<void> login(String email, String password, String userType) async {
    try {
      isLoading.value = true;

      final result = await _authService.signIn(email, password, userType);
      final token = result['token'];
      final userData = result['user'];

      if (token != null && userData != null) {
        final user = UserModel.fromJson(userData);

        if (!kIsWeb) {
          await storage.write(key: 'jwt_token', value: token);
          await storage.write(key: 'user_type', value: userType);
        }

        logger.i('Login successful: ${user.toJson()}');
        Session.setSession(type: userType, id: user.id);

        Get.offAll(() => const HomeScreen());
      } else {
        Get.snackbar('Error', 'Login failed. Invalid credentials.');
        logger.w('Login failed: token or user is null');
      }
    } catch (e) {
      logger.e('Login error: $e');
      Get.snackbar('Error', 'Login failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
