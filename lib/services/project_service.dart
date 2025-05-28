import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/userprojects/project_simplified_model.dart';
import '../services/session.dart';
import '../utils/Constants.dart';
import '../models/project_readonly_model.dart'; // تأكدي من أن المسار صحيح لملف ProjectModel

class ProjectService {
  final String _baseUrl = Constants.baseUrl;

  // (1) دالة لجلب مشاريع المستخدم الحالي (تعتمد على وجود الـ endpoint في الـ backend)
  Future<List<ProjectsimplifiedModel>> getMyProjects() async {
    print("getMyProjects CALLED"); // <<<<<< DEBUG PRINT
    final token = await Session.getToken();
    print("Token for getMyProjects: $token"); // <<<<<< DEBUG PRINT

    if (token == null || token.isEmpty) {
      print(
        "getMyProjects: No token found, throwing exception.",
      ); // <<<<<< DEBUG PRINT
      throw Exception('Authentication token not found. Please log in.');
    }

    final String url = '$_baseUrl/users/me/projects';
    print("getMyProjects: Requesting URL: $url"); // <<<<<< DEBUG PRINT

    try {
      //  <<<<< إضافة try-catch حول طلب الـ HTTP
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
        "getMyProjects: Response status: ${response.statusCode}",
      ); // <<<<<< DEBUG PRINT
      if (response.statusCode != 200) {
        print(
          "getMyProjects: Response body: ${response.body}",
        ); // <<<<<< DEBUG PRINT
      }

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body
            .map(
              (dynamic item) =>
                  ProjectsimplifiedModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else if (response.statusCode == 404) {
        print(
          'My Projects endpoint not found (404): $url',
        ); //  تم تعديل هذه للطباعة دائماً
        throw Exception(
          'Could not find your projects. The service might be unavailable (404). URL: $url',
        );
      } else {
        print(
          'Failed to load my projects (Status: ${response.statusCode}): ${response.body}',
        );
        throw Exception(
          'Failed to load your projects. Please try again later.',
        );
      }
    } catch (e) {
      print(
        "getMyProjects: HTTP request FAILED or error during processing: $e",
      ); // <<<<<< DEBUG PRINT
      // أعد رمي الخطأ الأصلي أو خطأ مخصص
      if (e is Exception) {
        rethrow; // أعد رمي الخطأ الأصلي إذا كان Exception
      }
      throw Exception(
        "An unexpected error occurred in getMyProjects: ${e.toString()}",
      );
    }
  }

  // (2) دالة لجلب تفاصيل مشروع واحد (هذه التي كانت ناقصة)
  Future<ProjectreadonlyModel> getProjectDetails(int projectId) async {
    final token =
        await Session.getToken(); // التوكن قد يكون اختيارياً هنا إذا كانت تفاصيل المشروع عامة
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/projects/$projectId',
      ), // هذا الـ endpoint موجود لديكِ
      headers: {
        'Content-Type': 'application/json',
        // أرسلي التوكن إذا كان الـ backend يتوقعه لعرض تفاصيل معينة أو للتحقق
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return ProjectreadonlyModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else if (response.statusCode == 404) {
      throw Exception('Project with ID $projectId not found.');
    } else {
      print(
        'Failed to load project details for ID $projectId (Status: ${response.statusCode}): ${response.body}',
      );
      throw Exception('Failed to load project details for ID $projectId');
    }
  }
}
