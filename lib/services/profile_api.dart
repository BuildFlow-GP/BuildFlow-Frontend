import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../models/user.dart';

const String apiUrl = 'http://localhost:5000/api/profile';
final Logger logger = Logger();

Future<User?> fetchUserProfile() async {
  const storage = FlutterSecureStorage();

  String? token = await storage.read(key: 'jwt_token');

  if (token == null) {
    logger.w('Token not found in secure storage');
    return null;
  }

  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      logger.i('Successfully fetched user profile');
      return User.fromJson(data['user']);
    } else {
      logger.w('Failed to load profile. Status Code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    logger.e('Error fetching profile: $e');
    return null;
  }
}
