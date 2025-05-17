class ProjectModel {
  final int id;
  String name;
  String? description;
  String status;
  double? budget;
  String? startDate;
  String? endDate;
  String? location;
  String? licenseFile;
  String? agreementFile;
  String? document2D;
  String? document3D;
  final String createdAt;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    this.budget,
    this.startDate,
    this.endDate,
    this.location,
    this.licenseFile,
    this.agreementFile,
    this.document2D,
    this.document3D,
    required this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    status: json['status'],
    budget:
        json['budget'] != null
            ? double.tryParse(json['budget'].toString())
            : null,
    startDate: json['start_date'],
    endDate: json['end_date'],
    location: json['location'],
    licenseFile: json['license_file'],
    agreementFile: json['agreement_file'],
    document2D: json['document_2d'],
    document3D: json['document_3d'],
    createdAt: json['created_at'],
  );

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
  };
}
