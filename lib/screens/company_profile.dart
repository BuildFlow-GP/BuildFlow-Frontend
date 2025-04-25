import 'package:flutter/material.dart';
import '../models/company.dart';

class CompanyProfilePage extends StatelessWidget {
  final Company company;

  const CompanyProfilePage({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Company Profile")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(company.profileImageUrl),
            ),
            SizedBox(height: 20),
            Text(
              company.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Email: ${company.email}"),
            Text("Phone: ${company.phone}"),
            Text("Description: ${company.description}"),
            Text("Rating: ${company.rating} ⭐"),
            Text("Type: ${company.companyType}"),
            Text("Location: ${company.location}"),
            Text("Bank Account: ${company.bankAccount}"),
            Text("Staff Count: ${company.staffCount}"),
          ],
        ),
      ),
    );
  }
}
