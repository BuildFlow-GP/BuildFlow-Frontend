import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/office_model.dart';
import '../models/company_model.dart';

class SearchService {
  static const String baseUrl =
      'http://localhost:5000/api/search'; // غيّر الرابط حسب مشروعك

  static Future<List<UserModel>> searchUsers(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/user?q=$query'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['results'];
      return data.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search users');
    }
  }

  static Future<List<OfficeModel>> searchOffices(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/office?q=$query'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['results'];
      return data.map((json) => OfficeModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search offices');
    }
  }

  static Future<List<CompanyModel>> searchCompanies(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/company?q=$query'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['results'];
      return data.map((json) => CompanyModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search companies');
    }
  }
}
