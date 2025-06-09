import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../models/Basic/project_model.dart';
import '../../models/userprojects/project_simplified_model.dart';
import '../session.dart';
import '../../utils/Constants.dart';
import 'package:logger/logger.dart';
import 'package:http_parser/http_parser.dart';

import '../../models/userprojects/project_readonly_model.dart';

class ProjectService {
  final String _baseUrl = Constants.baseUrl;
  final Logger logger = Logger();

  Future<List<ProjectModel>> getAssignedOfficeProjects({
    int limit = 20,
    int offset = 0,
  }) async {
    final token = await Session.getToken(); //  التوكن الخاص بالمكتب المسجل
    if (token == null || token.isEmpty) {
      logger.w(
        "getAssignedOfficeProjects: No office token found, throwing exception.",
      );
      throw Exception('Office authentication token not found. Please log in.');
    }

    final String url = '$_baseUrl/me/projects?limit=$limit&offset=$offset';
    logger.i("getAssignedOfficeProjects: Requesting URL: $url");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      logger.i(
        "getAssignedOfficeProjects: Response status: ${response.statusCode}",
      );
      if (response.statusCode != 200) {
        logger.w("getAssignedOfficeProjects: Response body: ${response.body}");
      }

      if (response.statusCode == 200) {
        // الـ API يرجع مصفوفة من المشاريع مباشرة (وليس كائن pagination كما في getMyNotifications)
        // إذا كان الـ API يرجع كائن pagination، ستحتاجين لتعديل هذا الجزء
        List<dynamic> body = jsonDecode(response.body);
        return body
            .map(
              (dynamic item) =>
                  ProjectModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // 403 قد تعني أن المستخدم ليس مكتباً
        throw Exception(
          'Authentication failed or not authorized (not an office). Please log in again.',
        );
      } else if (response.statusCode == 404) {
        logger.w('Assigned office projects endpoint not found (404): $url');
        throw Exception(
          'Could not find assigned projects. Service might be unavailable (404).',
        );
      } else {
        logger.w(
          'Failed to load assigned office projects (Status: ${response.statusCode}): ${response.body}',
        );
        throw Exception(
          'Failed to load assigned projects. Please try again later.',
        );
      }
    } catch (e) {
      logger.e(
        "getAssignedOfficeProjects: HTTP request FAILED or error during processing: $e",
      );
      if (e is Exception) {
        rethrow;
      }
      throw Exception(
        "An unexpected error occurred in getAssignedOfficeProjects: ${e.toString()}",
      );
    }
  }

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
        contentType: MediaType('application', 'pdf'), // اختياري
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

  // (1) تعديل getProjectProfile لترجع ProjectModel كاملاً (مع ProjectDesign)
  Future<ProjectModel> getProjectProfile(int projectId) async {
    final token = await Session.getToken();
    // الـ backend route GET /projects/:id أصبح يتطلب توثيقاً ويتحقق من الصلاحية
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/projects/$projectId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // إرسال التوكن دائماً
      },
    );

    logger.i(
      "GetProjectProfile for ID $projectId - Status: ${response.statusCode}",
    );
    if (response.statusCode != 200) {
      logger.e("GetProjectProfile Body: ${response.body}");
    }

    if (response.statusCode == 200) {
      return ProjectModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else if (response.statusCode == 404) {
      throw Exception('Project with ID $projectId not found.');
    } else if (response.statusCode == 403) {
      throw Exception(
        'Forbidden: You are not authorized to view this project.',
      );
    } else {
      throw Exception('Failed to load project details for ID $projectId');
    }
  }

  // (2) دالة لاقتراح سعر من المكتب
  Future<ProjectModel> proposePayment(
    int projectId,
    double amount,
    String? notes,
  ) async {
    final token = await Session.getToken(); // توكن المكتب
    if (token == null || token.isEmpty) {
      throw Exception('Office authentication token not found.');
    }

    final Map<String, dynamic> body = {'payment_amount': amount};
    if (notes != null && notes.isNotEmpty) {
      body['payment_notes'] = notes;
    }

    logger.i("Proposing payment for project $projectId: ${jsonEncode(body)}");

    final response = await http.put(
      Uri.parse('$_baseUrl/projects/$projectId/propose-payment'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    logger.i("ProposePayment response status: ${response.statusCode}");
    if (response.statusCode != 200) {
      logger.e("ProposePayment response body: ${response.body}");
    }

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      // الـ API يرجع { message: '...', project: { ... } }
      if (responseData.containsKey('project')) {
        return ProjectModel.fromJson(
          responseData['project'] as Map<String, dynamic>,
        );
      } else {
        throw Exception('Project data not found in propose payment response.');
      }
    } else {
      String errorMessage = 'Failed to propose payment.';
      try {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        errorMessage = responseData['message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  // (3) دالة لرفع مستند 2D (ويمكن عمل دالة مشابهة لـ 3D)
  Future<String?> uploadProjectDocument2D(
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
      Uri.parse('$_baseUrl/projects/$projectId/upload-document2d'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes(
        'document2dFile', // اسم الحقل الذي يتوقعه multer في الـ backend
        fileBytes,
        filename: fileName,
        contentType: MediaType(
          'application',
          'octet-stream',
        ), // نوع عام، أو حددي نوع الملف إذا كان معروفاً دائماً
        // (مثلاً application/pdf, image/vnd.dwg)
        // multer سيتحقق من الـ mimetype بناءً على الفلتر
      ),
    );

    logger.i("Uploading 2D document: $fileName for project $projectId");

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    logger.i("Upload 2D document response status: ${response.statusCode}");
    if (response.statusCode != 200 && response.statusCode != 201) {
      logger.e("Upload 2D document response body: ${response.body}");
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      // الـ API يرجع { message: '...', filePath: '...', project: { ... } }
      // نهتم بـ filePath هنا
      return responseData['filePath'] as String?;
    } else {
      String errorMessage = 'Failed to upload 2D document.';
      try {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        errorMessage = responseData['message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  //  يمكنكِ إضافة دالة مشابهة لـ uploadProjectDocument3D إذا احتجتِ إليها

  // (4) دالة لتحديث مرحلة تقدم المشروع
  Future<ProjectModel> updateProjectProgress(int projectId, int stage) async {
    final token = await Session.getToken(); // توكن المكتب
    if (token == null || token.isEmpty) {
      throw Exception('Office authentication token not found.');
    }

    final Map<String, dynamic> body = {'stage': stage};

    logger.i("Updating project $projectId progress to stage $stage");

    final response = await http.put(
      Uri.parse('$_baseUrl/projects/$projectId/progress'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    logger.i("Update project progress response status: ${response.statusCode}");
    if (response.statusCode != 200) {
      logger.e("Update project progress response body: ${response.body}");
    }

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      if (responseData.containsKey('project')) {
        return ProjectModel.fromJson(
          responseData['project'] as Map<String, dynamic>,
        );
      } else {
        throw Exception('Project data not found in update progress response.');
      }
    } else {
      String errorMessage = 'Failed to update project progress.';
      try {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        errorMessage = responseData['message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
