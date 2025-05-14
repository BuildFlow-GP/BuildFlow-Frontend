import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/about_section.dart';
import '../widgets/office_suggestions.dart';
import '../widgets/project_suggestions.dart';
import '../widgets/action_buttons.dart';
import '../widgets/contact_us.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: const [
            Navbar(onProfileTap: _goToProfile, onLogoutTap: _logout),
            AboutSection(),
            OfficeSuggestions(),
            ProjectSuggestions(),
            ActionButtons(),
            ContactUsSection(),
          ],
        ),
      ),
    );
  }

  static void _goToProfile() {
    // Navigate to profile screen
  }

  static void _logout() {
    // Handle logout
  }
}
