import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: const [
          Text(
            "About Us",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            "BuildFlow helps users start, manage, and showcase architecture & engineering projects easily."
            "At BuildFlow, we believe great design starts with the right collaboration. "
            "Our platform bridges the gap between individuals, offices, and companies to streamline the journey from concept to construction. Whether you're planning a dream home,"
            " designing an innovative workspace, or managing large-scale developments, BuildFlow empowers you with the tools and partnerships you need to succeed."
            "With smart search, detailed profiles, and dynamic project tools, we’re reimagining how ideas become reality—faster, smarter, and more connected than ever.",
          ),
        ],
      ),
    );
  }
}
