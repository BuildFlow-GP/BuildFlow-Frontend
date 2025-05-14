import 'package:flutter/material.dart';

class OfficeSuggestions extends StatelessWidget {
  const OfficeSuggestions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Suggested Offices",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(5, (index) => _suggestionCard(index)),
          ),
        ),
      ],
    );
  }

  Widget _suggestionCard(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        width: 160,
        child: Column(
          children: [
            Icon(Icons.apartment, size: 80),
            Text("Office #$index"),
            Text("Architecture Inc."),
          ],
        ),
      ),
    );
  }
}
