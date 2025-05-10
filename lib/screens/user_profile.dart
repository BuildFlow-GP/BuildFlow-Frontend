import 'package:flutter/material.dart';
import '../models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

// Replace this with your actual API base URL
const String apiUrl = 'http://localhost:5000/api/profile';
final Logger logger = Logger();

// Function to fetch user data
Future<User?> fetchUserProfile() async {
  const storage = FlutterSecureStorage();

  // Retrieve token from secure storage
  String? token = await storage.read(key: 'jwt_token');

  if (token == null) {
    return null;
  }

  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token', // Add the token to headers
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to load profile');
    }
  } catch (e) {
    logger.e('Error fetching profile: $e');
    return null;
  }
}

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: fetchUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text("User Profile")),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text("User Profile")),
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text("User Profile")),
            body: Center(child: Text("No profile data found")),
          );
        }

        final user = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: Text("User Profile")),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(user.profileImageUrl),
                ),
                SizedBox(height: 20),
                Text(
                  user.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text("Email: ${user.email}"),
                Text("Phone: ${user.phone}"),
                Text("ID Number: ${user.idNumber}"),
                Text("Bank Account: ${user.bankAccount}"),
                Text("Location: ${user.location}"),
              ],
            ),
          ),
        );
      },
    );
  }
}
