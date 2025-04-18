import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProfilePage extends StatelessWidget {
  final User user;

  const UserProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
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
  }
}
