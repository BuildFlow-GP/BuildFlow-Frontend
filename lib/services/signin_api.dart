import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class AuthService {
  final String baseUrl = 'http://localhost:5000/api/auth';
  final Logger logger = Logger();

  Future<Map<String, dynamic>> signIn(
    String email,
    String password,
    String userType,
  ) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'userType': userType,
        }),
      );

      final data = jsonDecode(response.body);

      logger.i('Response: ${response.body}');
      if (response.statusCode == 200) {
        return data;
      } else {
        logger.e('Login failed: ${response.body}');
        throw Exception('Login failed: ${data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      logger.e('Error during login request: $e');
      rethrow;
    }
  }
}
