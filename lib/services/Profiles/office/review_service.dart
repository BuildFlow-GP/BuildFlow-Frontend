import 'dart:convert';
import 'package:http/http.dart' as http;

class ReviewService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<List<dynamic>> getOfficeReviews(
    int officeId,
    String? token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/reviews/office/$officeId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load reviews');
    }
  }
}
