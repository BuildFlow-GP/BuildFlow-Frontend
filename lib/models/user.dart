class User {
  final String name;
  final String email;
  final String phone;
  final String idNumber;
  final String bankAccount;
  final String location;
  final String profileImageUrl;

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.idNumber,
    required this.bankAccount,
    required this.location,
    required this.profileImageUrl,
  });

  // Method to convert the response data into a User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? 'No Name',
      email: json['email'] ?? 'No Email',
      phone: json['phone'] ?? 'No Phone',
      idNumber: json['id_number'] ?? 'No ID Number',
      bankAccount: json['bank_account'] ?? 'No Bank Account',
      location: json['location'] ?? 'No Location',
      profileImageUrl:
          json['profile_image_url'] ??
          'https://via.placeholder.com/150', // default image URL
    );
  }
}
