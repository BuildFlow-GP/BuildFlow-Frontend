import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../models/Basic/project_model.dart';
import '../../models/userprojects/project_simplified_model.dart';
import '../session.dart';
import '../../utils/Constants.dart';
import 'package:logger/logger.dart';

import '../../models/userprojects/project_readonly_model.dart'; // تأكدي من أن المسار صحيح لملف ProjectModel

class ProjectService {
  final String _baseUrl = Constants.baseUrl;
  final Logger logger = Logger();

  Future<List<ProjectsimplifiedModel>> getMyProjects() async {
    logger.i("getMyProjects CALLED");
    final token = await Session.getToken();
    logger.i("Token for getMyProjects: $token");

    if (token == null || token.isEmpty) {
      logger.w("getMyProjects: No token found, throwing exception.");
      throw Exception('Authentication token not found. Please log in.');
    }

    final String url = '$_baseUrl/users/me/projects';
    logger.i("getMyProjects: Requesting URL: $url");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      logger.i("getMyProjects: Response status: ${response.statusCode}");
      if (response.statusCode != 200) {
        logger.w("getMyProjects: Response body: ${response.body}");
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
        logger.w('My Projects endpoint not found (404): $url');
        throw Exception(
          'Could not find your projects. The service might be unavailable (404). URL: $url',
        );
      } else {
        logger.w(
          'Failed to load my projects (Status: ${response.statusCode}): ${response.body}',
        );
        throw Exception(
          'Failed to load your projects. Please try again later.',
        );
      }
    } catch (e) {
      logger.e(
        "getMyProjects: HTTP request FAILED or error during processing: $e",
      );
      // أعد رمي الخطأ الأصلي أو خطأ مخصص
      if (e is Exception) {
        rethrow; // أعد رمي الخطأ الأصلي إذا كان Exception
      }
      throw Exception(
        "An unexpected error occurred in getMyProjects: ${e.toString()}",
      );
    }
  }

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
      logger.e(
        'Failed to load project details for ID $projectId (Status: ${response.statusCode}): ${response.body}',
      );
      throw Exception('Failed to load project details for ID $projectId');
    }
  }

  Future<ProjectModel> requestInitialProject({
    // تم تعديل اسم الدالة والبارامترات
    required int officeId,
    required String projectType, // يمكن أن يكون نوع التصميم أو اسم مبدئي
    String? initialDescription,
  }) async {
    final token = await Session.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/projects/request-initial'), // المسار الجديد
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'office_id': officeId,
        'project_type': projectType,
        if (initialDescription != null && initialDescription.isNotEmpty)
          'initial_description': initialDescription,
      }),
    );

    if (response.statusCode == 201) {
      // تم إنشاء الطلب بنجاح، الـ API يرجع المشروع المبدئي
      return ProjectModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else if (response.statusCode == 400) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
        'Failed to send project request: ${responseBody['message'] ?? "Invalid data."}',
      );
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Authentication failed. Please log in again.');
    } else if (response.statusCode == 404) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(
        'Failed to send project request: ${responseBody['message'] ?? "Office not found."}',
      );
    } else {
      logger.e(
        'Error in requestInitialProject (Status: ${response.statusCode}): ${response.body}',
      );
      throw Exception(
        'An unexpected error occurred while sending your project request.',
      );
    }
  }

  Future<void> respondToProjectRequest(
    int projectId,
    String action, {
    String? rejectionReason,
  }) async {
    final token = await Session.getToken(); // التوكن الخاص بالمكتب
    if (token == null || token.isEmpty) {
      throw Exception('Office authentication token not found.');
    }

    final Map<String, String> body = {'action': action.toLowerCase()};
    if (action.toLowerCase() == 'reject' &&
        rejectionReason != null &&
        rejectionReason.isNotEmpty) {
      body['rejection_reason'] = rejectionReason;
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/projects/$projectId/respond'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      logger.i(
        'Project request $projectId action ${action.toLowerCase()} successful.',
      );
      // يمكنكِ تحليل الـ response.body إذا أردتِ استخدام المشروع المحدث
      // final responseData = jsonDecode(response.body);
      // final updatedProject = ProjectModel.fromJson(responseData['project']); // إذا أردتِ إرجاعه
    } else {
      logger.e(
        'Failed to ${action.toLowerCase()} project request $projectId (Status: ${response.statusCode}): ${response.body}',
      );
      String errorMessage = 'Failed to ${action.toLowerCase()} request.';
      try {
        final responseBody = jsonDecode(response.body);
        errorMessage = responseBody['message'] ?? errorMessage;
      } catch (_) {
        // فشل تحليل JSON، استخدم الرسالة الافتراضية
      }
      throw Exception(errorMessage);
    }
  }

  Future<ProjectModel> updateProjectDetails(
    int projectId,
    Map<String, dynamic> dataToUpdate,
  ) async {
    final token = await Session.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please log in.');
    }

    // إزالة المفاتيح ذات القيم null لتجنب إرسالها إذا كان الـ backend لا يتوقعها
    // أو إذا كانت ستسبب خطأ (مثلاً، تحويل null إلى نص فارغ أو ما شابه)
    dataToUpdate.removeWhere(
      (key, value) => value == null || (value is String && value.isEmpty),
    );
    // التأكد من أن القيم الرقمية يتم إرسالها كأرقام إذا كانت كذلك في الـ backend
    // (jsonEncode يتعامل مع هذا بشكل جيد عادة)

    logger.i(
      "Updating project $projectId with data: ${jsonEncode(dataToUpdate)}",
    );

    final response = await http.put(
      Uri.parse('$_baseUrl/projects/$projectId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dataToUpdate),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseData.containsKey('project')) {
        return ProjectModel.fromJson(
          responseData['project'] as Map<String, dynamic>,
        );
      } else {
        // إذا لم يرجع الـ API كائن المشروع، قد تحتاج لإعادة جلبه
        // return getProjectDetails(projectId); // أو رمي خطأ
        throw Exception('Project data not returned in update response.');
      }
    } else {
      String errorMessage = 'Failed to update project details.';
      try {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
        errorMessage = responseBody['message'] ?? errorMessage;
        if (responseBody['errors'] != null) {
          errorMessage += "\nDetails: ${responseBody['errors'].join(', ')}";
        }
      } catch (_) {}
      logger.e(
        'Error updating project $projectId (Status: ${response.statusCode}): ${response.body}',
      );
      throw Exception(errorMessage);
    }
  }

  Future<ProjectModel> getProjectDetailscreate(int projectId) async {
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
      return ProjectModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else if (response.statusCode == 404) {
      throw Exception('Project with ID $projectId not found.');
    } else {
      logger.e(
        'Failed to load project details for ID $projectId (Status: ${response.statusCode}): ${response.body}',
      );
      throw Exception('Failed to load project details for ID $projectId');
    }
  }

  /// Uploads a project agreement file to the server.
  Future<String?> uploadProjectAgreement(
    int projectId,
    Uint8List fileBytes,
    String fileName,
  ) async {
    final token = await Session.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found.');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${Constants.baseUrl}/projects/$projectId/upload-agreement',
      ), // استخدام الـ endpoint الجديد
    );
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes(
        'agreementFile', //  اسم الحقل الذي يتوقعه multer
        fileBytes,
        filename: fileName,
        // contentType: MediaType('application', 'pdf'), // اختياري
      ),
    );

    logger.i("Uploading agreement file: $fileName for project $projectId");

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    logger.i("Upload agreement response status: ${response.statusCode}");
    logger.i("Upload agreement response body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      // افترض أن الـ API يرجع المسار/الاسم الجديد للملف في حقل 'filePath'
      return responseData['filePath'] as String?;
    } else {
      String errorMessage = 'Failed to upload agreement file.';
      try {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        errorMessage = responseData['message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  Future<ProjectModel> submitFinalProjectDetails(
    int projectId, {
    String? finalAgreementFilePathFromUpload,
  }) async {
    final token = await Session.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found.');
    }

    // هذا الـ body اختياري. إذا كان API الرفع يحدث agreement_file مباشرة،
    // وكان API الـ submit-final-details لا يتوقع أي body (فقط يغير الحالة بناءً على projectId)،
    // يمكنكِ إرسال body فارغ.
    // إذا كان submit-final-details يتوقع مسار الملف لتحديثه مرة أخرى (للتأكيد مثلاً)،
    // يمكنكِ إرساله. حالياً، الـ backend route الذي كتبناه لا يستخدم الـ body.
    Map<String, dynamic> body = {};
    // if (finalAgreementFilePathFromUpload != null && finalAgreementFilePathFromUpload.isNotEmpty) {
    //   body['agreement_file'] = finalAgreementFilePathFromUpload; // اسم الحقل كما يتوقعه الـ backend
    // }

    logger.i(
      "Service: Submitting final details for project $projectId. Body (if any): ${jsonEncode(body)}",
    );

    final response = await http.put(
      Uri.parse(
        '${Constants.baseUrl}/projects/$projectId/submit-final-details',
      ), //  الـ Endpoint الجديد
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(
        body,
      ), // أرسلي body فارغ إذا كان الـ API لا يحتاج لبيانات إضافية
    );

    logger.i(
      "Service: Submit final details response status: ${response.statusCode}",
    );
    logger.i("Service: Submit final details response body: ${response.body}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseData.containsKey('project')) {
        return ProjectModel.fromJson(
          responseData['project'] as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          "Project data not found in submit-final-details response.",
        );
      }
    } else {
      String errorMessage = 'Failed to submit final project details.';
      try {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        errorMessage = responseData['message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
