import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'project_description.dart'; // Import the project description screen

class TypeOfProjectPage extends StatelessWidget {
  const TypeOfProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> projectTypes = ["Design", "Supervision", "Consultation"];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back(); // Navigate back to previous screen (HomeScreen)
          },
        ),
        title: const Row(
          children: [
            Icon(Icons.category),
            SizedBox(width: 10),
            Text("Choose Project"),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: projectTypes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.build),
              title: Text(projectTypes[index]),
              onTap: () {
                Get.to(() => const ProjectDetailsScreen());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Selected: ${projectTypes[index]}")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
