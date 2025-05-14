// models/office.dart
class Office {
  final int id;
  String name;
  String email;
  String phone;
  String location;
  int? capacity;
  double? rating;
  bool isAvailable;
  int points;
  String? bankAccount;
  int? staffCount;
  int activeProjectsCount;
  String? branches;
  String? profileImage;
  DateTime createdAt;

  Office({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    this.capacity,
    this.rating,
    required this.isAvailable,
    required this.points,
    this.bankAccount,
    this.staffCount,
    required this.activeProjectsCount,
    this.branches,
    this.profileImage,
    required this.createdAt,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? '',
      location: json['location'],
      capacity: json['capacity'],
      rating: (json['rating'] as num?)?.toDouble(),
      isAvailable: json['is_available'] ?? true,
      points: json['points'] ?? 0,
      bankAccount: json['bank_account'],
      staffCount: json['staff_count'],
      activeProjectsCount: json['active_projects_count'] ?? 0,
      branches: json['branches'],
      profileImage: json['profile_image'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'capacity': capacity,
      'rating': rating,
      'is_available': isAvailable,
      'points': points,
      'bank_account': bankAccount,
      'staff_count': staffCount,
      'active_projects_count': activeProjectsCount,
      'branches': branches,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
