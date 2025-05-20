import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import '../services/session.dart'; // استيراد Session

class OfficeService {
  final String baseUrl = 'http://localhost:5000/api/offices';
  final Logger logger = Logger();

  Future<String?> _getToken() async {
    return await Session.getToken();
  }

  Future<Map<String, dynamic>> getOffice(String officeId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$officeId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      logger.e('Failed to fetch office: ${response.body}');
      throw Exception('Failed to fetch office profile');
    }
  }

  Future<void> updateOffice(
    String officeId,
    Map<String, dynamic> updatedData,
  ) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$officeId');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedData),
    );

    if (response.statusCode != 200) {
      logger.e('Failed to update office: ${response.body}');
      throw Exception('Failed to update office profile');
    }
  }

  Future<void> uploadProfileImage(String officeId, File imageFile) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/$officeId/upload-image');

    final request =
        http.MultipartRequest('POST', url)
          ..headers['Authorization'] = 'Bearer $token'
          ..files.add(
            await http.MultipartFile.fromPath(
              'image',
              imageFile.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      logger.e('Image upload failed: ${response.body}');
      throw Exception('Failed to upload profile image');
    }
  }

  Future<List<dynamic>> getOfficeReviews(String officeId) async {
    final token = await _getToken();
    final url = Uri.parse('http://localhost:5000/api/reviews/office/$officeId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      logger.e('Failed to fetch reviews: ${response.body}');
      throw Exception('Failed to fetch reviews');
    }
  }

  Future<void> submitOfficeReview(
    String officeId,
    double rating,
    String comment,
  ) async {
    final token = await _getToken();
    final url = Uri.parse('http://localhost:5000/api/reviews');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'office_id': officeId,
        'rating': rating,
        'comment': comment,
      }),
    );

    if (response.statusCode != 201) {
      logger.e('Failed to submit review: ${response.body}');
      throw Exception('Failed to submit review');
    }
  }
}
