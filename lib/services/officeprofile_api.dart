import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/office.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  static final _storage = FlutterSecureStorage();

  static Future<Office?> fetchOfficeProfile() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Office.fromJson(data['user']);
    } else {
      return null;
    }
  }

  static Future<bool> updateOfficeProfile(
    Office office,
    File? imageFile,
  ) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return false;

    final uri = Uri.parse('$baseUrl/profile');
    final request = http.MultipartRequest('PUT', uri);
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

    request.fields['name'] = office.name;
    request.fields['email'] = office.email;
    request.fields['phone'] = office.phone;
    request.fields['location'] = office.location;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_image', imageFile.path),
      );
    }

    final response = await request.send();
    return response.statusCode == 200;
  }

  static Future<List<Office>> fetchSuggestedOffices() async {
    final response = await http.get(Uri.parse('$baseUrl/offices/suggestions'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Office.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load suggested offices');
    }
  }
}
