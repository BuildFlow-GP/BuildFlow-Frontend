// models/project_model.dart
import 'office_model.dart';
import 'company_model.dart';
import 'user_model.dart';

class ProjectModel {
  final int id;
  String name;
  String? description;
  String? status;
  double? budget;
  String? startDate; //  يفضل استخدام DateTime هنا
  String? endDate; //  يفضل استخدام DateTime هنا
  String? location; //  الموقع العام للمشروع

  // حقول معلومات الأرض
  double? landArea;
  String? plotNumber;
  String? basinNumber;
  String? landLocation; //  موقع الأرض التفصيلي

  // حقول المستندات
  String? licenseFile;
  String? agreementFile;
  String? document2D;
  String? document3D;

  // === حقول معلومات الاتصال الخاصة بالمشروع (جديدة) ===
  String? contactName;
  String? contactIdNumber;
  String? contactAddress; // قد يكون مختلفاً عن location
  String? contactPhone;
  String? contactBankAccount;

  String? rejectionReason; // سبب الرفض

  final String createdAt; //  يفضل استخدام DateTime هنا
  final int? userId; //  ID المستخدم (من جدول المشاريع)
  final int? officeId; //  ID المكتب (من جدول المشاريع)

  // الكائنات المتداخلة (إذا أرجعها الـ API)
  OfficeModel? office;
  CompanyModel? company;
  UserModel? user;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    this.status,
    this.budget,
    this.startDate,
    this.endDate,
    this.location,
    this.licenseFile,
    this.agreementFile,
    this.document2D,
    this.document3D,
    this.landArea,
    this.plotNumber,
    this.basinNumber,
    this.landLocation,
    this.contactName,
    this.contactIdNumber,
    this.contactAddress,
    this.contactPhone,
    this.contactBankAccount,
    this.rejectionReason,
    required this.createdAt,
    this.userId, // تمت الإضافة
    this.officeId, // تمت الإضافة
    this.office,
    this.company,
    this.user,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    // دالة مساعدة لتحويل النصوص إلى double بأمان
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return ProjectModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unnamed Project',
      description: json['description'] as String?,
      status: json['status'] as String?,
      budget: parseDouble(json['budget']),
      startDate:
          json['start_date'] as String?, // الأفضل تحويل لـ DateTime.tryParse
      endDate: json['end_date'] as String?, // الأفضل تحويل لـ DateTime.tryParse
      location: json['location'] as String?,

      landArea: parseDouble(json['land_area']),
      plotNumber: json['plot_number'] as String?,
      basinNumber: json['basin_number'] as String?,
      landLocation: json['land_location'] as String?,

      licenseFile: json['license_file'] as String?,
      agreementFile: json['agreement_file'] as String?,
      document2D: json['document_2d'] as String?,
      document3D: json['document_3d'] as String?,

      contactName: json['contact_name'] as String?,
      contactIdNumber: json['contact_id_number'] as String?,
      contactAddress: json['contact_address'] as String?,
      contactPhone: json['contact_phone'] as String?,
      contactBankAccount: json['contact_bank_account'] as String?,

      rejectionReason: json['rejection_reason'] as String?,

      createdAt:
          json['created_at'] as String? ??
          DateTime.now().toIso8601String(), // الأفضل تحويل لـ DateTime.parse
      userId: json['user_id'] as int?,
      officeId: json['office_id'] as int?,

      office:
          json['office'] != null ? OfficeModel.fromJson(json['office']) : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      company:
          json['company'] != null
              ? CompanyModel.fromJson(json['company'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (description != null) data['description'] = description;
    if (status != null) data['status'] = status; // عادة لا يرسل المستخدم الحالة
    if (budget != null) data['budget'] = budget;
    if (startDate != null) {
      data['start_date'] = startDate; // أرسلي كـ ISOString إذا كان DateTime
    }
    if (endDate != null) data['end_date'] = endDate;
    if (location != null) data['location'] = location;

    if (landArea != null) data['land_area'] = landArea;
    if (plotNumber != null) data['plot_number'] = plotNumber;
    if (basinNumber != null) data['basin_number'] = basinNumber;
    if (landLocation != null) data['land_location'] = landLocation;

    //  لا نرسل الملفات هنا عادة، الرفع يتم بشكل منفصل
    // if (agreementFile != null) data['agreement_file'] = agreementFile;

    if (contactName != null) data['contact_name'] = contactName;
    if (contactIdNumber != null) data['contact_id_number'] = contactIdNumber;
    if (contactAddress != null) data['contact_address'] = contactAddress;
    if (contactPhone != null) data['contact_phone'] = contactPhone;
    if (contactBankAccount != null) {
      data['contact_bank_account'] = contactBankAccount;
    }

    // لا نرسل user_id أو office_id عند التحديث من المستخدم عادة، إلا إذا كان الـ API يتطلب ذلك
    // if (officeId != null) data['office_id'] = officeId;

    return data;
  }
}
