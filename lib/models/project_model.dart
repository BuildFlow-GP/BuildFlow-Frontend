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
  double? landArea; // مساحة الأرض
  String? plotNumber; // رقم القطعة
  String? basinNumber; // رقم الحوض
  String? landLocation; // موقع الأرض
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
    this.landArea,
    this.plotNumber,
    this.basinNumber,
    this.landLocation,
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
    landArea:
        json['land_area'] != null
            ? double.tryParse(json['land_area'].toString())
            : null,
    plotNumber: json['plot_number'],
    basinNumber: json['basin_number'],
    landLocation: json['land_location'],
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
    "land_area": landArea,
    "plot_number": plotNumber,
    "basin_number": basinNumber,
    "land_location": landLocation,
  };
}
