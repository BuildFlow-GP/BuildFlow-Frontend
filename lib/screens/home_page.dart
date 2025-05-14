import 'package:flutter/material.dart';
import '../models/office.dart';
import '../widgets/navbar.dart';
import '../widgets/about_section.dart';
import '../widgets/office_suggestions.dart';
import '../widgets/project_suggestions.dart';
import '../widgets/action_buttons.dart';
import '../widgets/contact_us.dart';
import '../services/officeprofile_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Office> suggestedOffices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSuggestedOffices();
  }

  Future<void> fetchSuggestedOffices() async {
    try {
      final offices = await ApiService.fetchSuggestedOffices();
      setState(() {
        suggestedOffices = offices;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _goToProfile() {
    // Navigate to profile screen
  }

  void _logout() {
    // Handle logout
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Navbar(onProfileTap: _goToProfile, onLogoutTap: _logout),
            const AboutSection(),
            isLoading
                ? const CircularProgressIndicator()
                : OfficeSuggestions(offices: suggestedOffices),
            const ProjectSuggestions(),
            const ActionButtons(),
            const ContactUsSection(),
          ],
        ),
      ),
    );
  }
}
