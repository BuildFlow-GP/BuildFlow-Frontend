import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/office.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<Office?> fetchOfficeProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Office.fromJson(data['user']);
    } else {
      // Handle error
      return null;
    }
  }

  static Future<bool> updateOfficeProfile(
    Office office,
    File? imageFile,
  ) async {
    final uri = Uri.parse('$baseUrl/profile');
    var request = http.MultipartRequest('PUT', uri);
    request.headers[HttpHeaders.authorizationHeader] =
        'Bearer your_jwt_token_here';

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

    if (response.statusCode == 200) {
      // Successfully updated
      return true;
    } else {
      // Handle error
      return false;
    }
  }
}
