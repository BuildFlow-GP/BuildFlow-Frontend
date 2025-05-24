import 'dart:convert';
import 'package:http/http.dart' as http;
import '../session.dart';

class CompanyService {
  static const String _baseUrl = 'http://localhost:5000/api/companies';

  static Future<List<Map<String, dynamic>>> fetchSuggestions() async {
    final token = await Session.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/suggestions'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load company suggestions');
    }
  }
}
