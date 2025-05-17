import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            // Navigate to new project creation
          },
          child: const Text("Start New Project"),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: () {
            // Navigate to previous projects
          },
          child: const Text("My Previous Projects"),
        ),
      ],
    );
  }
}
