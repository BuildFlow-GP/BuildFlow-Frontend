import 'package:flutter/material.dart';

class TypeOfProjectPage extends StatelessWidget {
  const TypeOfProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> projectTypes = ["Design", "Supervision", "Consultation"];

    return Scaffold(
      appBar: AppBar(
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
                // Navigate to project detail / form based on selection
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
