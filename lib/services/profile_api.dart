import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'package:logger/logger.dart';

// Replace this with your API base URL
const String apiUrl = 'http://localhot:5000/api/profile';

final Logger logger = Logger();

Future<User?> fetchUserProfile() async {
  const storage = FlutterSecureStorage();

  // Retrieve token from secure storage
  String? token = await storage.read(key: 'jwt_token');

  if (token == null) {
    return null;
  }

  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token', // Add the token to headers
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to load profile');
    }
  } catch (e) {
    logger.e('Error fetching profile: $e');
    return null;
  }
}
