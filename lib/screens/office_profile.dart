import 'package:flutter/material.dart';
import '../models/office.dart';

class OfficeProfilePage extends StatelessWidget {
  final Office office;

  const OfficeProfilePage({super.key, required this.office});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Office Profile")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(office.profileImageUrl),
            ),
            SizedBox(height: 20),
            Text(
              office.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Location: ${office.location}"),
            Text("Rating: ${office.rating} ⭐"),
            Text("Capacity: ${office.capacity}"),
            Text("Points: ${office.points}"),
            Text("Bank Account: ${office.bankAccount}"),
            Text("Staff Count: ${office.staffCount}"),
            Text("Active Projects: ${office.activeProjects}"),
            Text("Branches: ${office.branches}"),
          ],
        ),
      ),
    );
  }
}
