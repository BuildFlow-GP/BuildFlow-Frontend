class CompanyModel {
  final int id;
  String name;
  String? email;
  String? phone;
  String? description;
  double? rating;
  String? companyType;
  String? location;
  String? bankAccount;
  int? staffCount;
  String? profileImage;
  final String createdAt;

  CompanyModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.description,
    this.rating,
    this.companyType,
    this.location,
    this.bankAccount,
    this.staffCount,
    this.profileImage,
    required this.createdAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    description: json['description'],
    rating: json['rating']?.toDouble(),
    companyType: json['company_type'],
    location: json['location'],
    bankAccount: json['bank_account'],
    staffCount: json['staff_count'],
    profileImage: json['profile_image'],
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "phone": phone,
    "description": description,
    "rating": rating,
    "company_type": companyType,
    "location": location,
    "bank_account": bankAccount,
    "staff_count": staffCount,
    "profile_image": profileImage,
  };
}
