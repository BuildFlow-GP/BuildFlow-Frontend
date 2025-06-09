// models/project_model.dart (أو المسار الصحيح لديكِ models/Basic/project_model.dart)
import 'office_model.dart'; // تأكدي من المسارات الصحيحة
import 'company_model.dart';
import 'user_model.dart';

class ProjectModel {
  final int id;
  String name; // اسم المشروع، لا يجب أن يكون null
  String? description; // الوصف، سنجعله نص فارغ إذا كان null
  String? status; // الحالة، سنجعلها قيمة افتراضية إذا كانت null
  double? budget;
  DateTime? startDate; //  تم تحويله لـ DateTime
  DateTime? endDate; //  تم تحويله لـ DateTime
  String? location; //  سنجعله نص فارغ إذا كان null

  // حقول معلومات الأرض
  double? landArea;
  String? plotNumber; //  سنجعله نص فارغ إذا كان null
  String? basinNumber; //  سنجعله نص فارغ إذا كان null
  String? landLocation; //  سنجعله نص فارغ إذا كان null

  // حقول المستندات (تبقى String? لأنها قد لا تكون موجودة دائماً)
  String? licenseFile;
  String? agreementFile;
  String? document2D;
  String? document3D;

  String? rejectionReason; //  إذا أضفتيه في الـ backend model
  // ✅✅✅ الحقول الجديدة للدفع والتقدم ✅✅✅
  final double? proposedPaymentAmount;
  final String? paymentNotes;
  final String? paymentStatus;
  final int? progressStage; //  (0-5 مثلاً)
  final DateTime createdAt; //  تم تحويله لـ DateTime

  // IDs للربط (مهمة جداً)
  final int? userId;
  final int? officeId;
  // final int? companyId; // إذا كنتِ ستضيفينه

  // الكائنات المتداخلة (إذا أرجعها الـ API)
  OfficeModel? office;
  CompanyModel? company;
  UserModel? user;

  ProjectModel({
    required this.id,
    required this.name,
    this.description = '', // قيمة افتراضية
    this.status = 'Unknown', // قيمة افتراضية
    this.budget,
    this.startDate,
    this.endDate,
    this.location = '', // قيمة افتراضية
    this.licenseFile,
    this.agreementFile,
    this.document2D,
    this.document3D,
    this.landArea,
    this.plotNumber = '', // قيمة افتراضية
    this.basinNumber = '', // قيمة افتراضية
    this.landLocation = '', // قيمة افتراضية
    this.rejectionReason,
    this.proposedPaymentAmount,
    this.paymentNotes,
    this.paymentStatus,
    this.progressStage,
    required this.createdAt,
    this.userId, //  تمت الإضافة
    this.officeId, //  تمت الإضافة
    // this.companyId,
    this.office,
    this.company,
    this.user,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) return null;
      return DateTime.tryParse(dateString);
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return ProjectModel(
      id: json['id'] as int,
      name:
          json['name'] as String? ??
          'Unnamed Project', // قيمة افتراضية قوية للاسم
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'Unknown',
      budget: parseDouble(json['budget']),
      startDate: parseDate(json['start_date'] as String?),
      endDate: parseDate(json['end_date'] as String?),
      location: json['location'] as String? ?? '',
      proposedPaymentAmount: parseDouble(json['proposed_payment_amount']),
      paymentNotes: json['payment_notes'] as String?,
      paymentStatus: json['payment_status'] as String?,
      progressStage: json['progress_stage'] as int?,

      licenseFile: json['license_file'] as String?,
      agreementFile: json['agreement_file'] as String?,
      document2D: json['document_2d'] as String?,
      document3D: json['document_3d'] as String?,

      landArea: parseDouble(json['land_area']),
      plotNumber: json['plot_number'] as String? ?? '',
      basinNumber: json['basin_number'] as String? ?? '',
      landLocation: json['land_location'] as String? ?? '',

      rejectionReason: json['rejection_reason'] as String?,

      createdAt:
          parseDate(json['created_at'] as String?) ??
          DateTime.now(), // قيمة افتراضية قوية

      userId: json['user_id'] as int?, //  قراءة الـ ID
      officeId: json['office_id'] as int?, //  قراءة الـ ID

      office:
          json['office'] != null
              ? OfficeModel.fromJson(json['office'] as Map<String, dynamic>)
              : null,
      user:
          json['user'] != null
              ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      company:
          json['company'] != null
              ? CompanyModel.fromJson(json['company'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    // هذا الـ toJson يستخدم لإرسال البيانات للـ backend
    // يجب أن يعكس الحقول التي يتوقعها الـ API عند الإنشاء أو التحديث
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (description!.isNotEmpty) data['description'] = description;
    // status عادة لا يتم إرساله من المستخدم عند التحديث الجزئي، الـ backend يديره
    // if (status.isNotEmpty && status != 'Unknown') data['status'] = status;
    if (budget != null) data['budget'] = budget;
    if (startDate != null) data['start_date'] = startDate!.toIso8601String();
    if (endDate != null) data['end_date'] = endDate!.toIso8601String();
    if (location!.isNotEmpty) data['location'] = location;

    // لا نرسل عادة مسارات الملفات هنا، الرفع وتحديث المسار يتم بعملية منفصلة
    // if (licenseFile != null) data['license_file'] = licenseFile;
    // if (agreementFile != null) data['agreement_file'] = agreementFile;
    // if (document2D != null) data['document_2d'] = document2D;
    // if (document3D != null) data['document_3d'] = document3D;

    if (landArea != null) data['land_area'] = landArea;
    if (plotNumber!.isNotEmpty) data['plot_number'] = plotNumber;
    if (basinNumber!.isNotEmpty) data['basin_number'] = basinNumber;
    if (landLocation!.isNotEmpty) data['land_location'] = landLocation;
    if (proposedPaymentAmount != null) {
      data['proposed_payment_amount'] = proposedPaymentAmount;
    }
    if (paymentNotes != null) data['payment_notes'] = paymentNotes;
    if (paymentStatus != null) data['payment_status'] = paymentStatus;
    if (progressStage != null) data['progress_stage'] = progressStage;
    // لا نرسل user_id أو office_id عند تحديث المستخدم للتفاصيل، هذه يتم تعيينها عند الإنشاء
    // if (userId != null) data['user_id'] = userId;
    // if (officeId != null) data['office_id'] = officeId;

    // إذا كان API الإنشاء المبدئي يتوقع office_id، يجب أن يكون في toJson آخر أو يتم تمريره بشكل منفصل
    // في حالتنا، `requestInitialProject` في السيرفس يبني الـ body بشكل مخصص.
    return data;
  }
}
