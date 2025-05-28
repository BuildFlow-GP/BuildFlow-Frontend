import 'office_model.dart'; // تأكدي من أن المسار صحيح لملف OfficeModel

class ProjectModel {
  final int id;
  String name;
  String? description;
  String? status;
  double? budget;
  String? startDate;
  String? endDate;
  String? location;
  String? licenseFile;
  String? agreementFile;
  String? document2D;
  String? document3D;
  double? landArea;
  String? plotNumber;
  String? basinNumber;
  String? landLocation;
  final String createdAt;
  OfficeModel? office; // <-- الإضافة الجديدة
  // يمكنك إضافة UserModel? user; و CompanyModel? company; بنفس الطريقة إذا احتجتِ لها

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
    required this.createdAt,
    this.office, // <-- الإضافة الجديدة
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      name: json['name'] as String? ?? 'Unknown Name',
      description: json['description'] as String? ?? 'Unknown Description',
      status: json['status'] as String? ?? 'Unknown Status',
      budget:
          json['budget'] != null
              ? double.tryParse(json['budget'].toString())
              : null as double?,
      startDate: json['start_date'] as String? ?? 'Unknown Start Date',
      endDate: json['end_date'] as String? ?? 'Unknown End Date',
      location: json['location'] as String? ?? 'Unknown Location',
      licenseFile: json['license_file'] as String? ?? 'Unknown License',
      agreementFile: json['agreement_file'] as String? ?? 'Unknown Agreement',
      document2D: json['document_2d'] as String? ?? 'Unknown Document 2D',
      document3D: json['document_3d'] as String? ?? 'Unknown Document 3D',
      landArea:
          json['land_area'] != null
              ? double.tryParse(json['land_area'].toString())
              : null as double?,
      plotNumber: json['plot_number'] as String? ?? 'Unknown Plot Number',
      basinNumber: json['basin_number'] as String? ?? 'Unknown Basin Number',
      landLocation: json['land_location'] as String? ?? 'Unknown Land Location',
      createdAt: json['created_at'] as String? ?? 'Unknown Created At',
      office:
          json['office'] !=
                  null // <-- الإضافة الجديدة
              ? OfficeModel.fromJson(json['office']) // <-- الإضافة الجديدة
              : null, // <-- الإضافة الجديدة
      // user: json['user'] != null ? UserModel.fromJson(json['user']) : null, // إذا أردتِ المستخدم
      // company: json['company'] != null ? CompanyModel.fromJson(json['company']) : null, // إذا أردتِ الشركة
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "description": description,
    "status": status,
    "budget": budget,
    "start_date": startDate,
    "end_date": endDate,
    "location": location,
    "license_file": licenseFile,
    "agreement_file": agreementFile,
    "document_2d": document2D,
    "document_3d": document3D,
    "land_area": landArea,
    "plot_number": plotNumber,
    "basin_number": basinNumber,
    "land_location": landLocation,
    // لا نرسل عادة الكائنات المتداخلة الكاملة عند إنشاء/تحديث المشروع،
    // بل نرسل الـ id الخاص بالمكتب مثلاً. هذا يعتمد على تصميم الـ API.
    // "office_id": office?.id, // مثال إذا كان الـ API يتوقع office_id
  };
}
