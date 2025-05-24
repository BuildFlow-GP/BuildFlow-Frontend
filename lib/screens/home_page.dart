import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/about_section.dart';
import '../widgets/contact_us.dart';
import 'Design/type_of_project.dart'; // import for navigation
// import '../services/Suggestions/office_suggestion_service.dart';
// import '../services/Suggestions/company_suggestion_service.dart';
// import '../widgets/Suggestions/suggestion_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false; // Changed to false to show buttons directly

  @override
  void initState() {
    super.initState();
    // You can implement data loading here if needed and update isLoading accordingly
  }

  // void _logout() {
  //   Get.offAll(() => const SignInScreen());
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            //       Navbar(onLogoutTap: _logout),
            const AboutSection(),
            isLoading
                ? const CircularProgressIndicator()
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => const TypeOfProjectPage());
                      },
                      child: const Text("Start New Project"),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {
                        // TODO: Navigate to previous projects page
                      },
                      child: const Text("My Previous Projects"),
                    ),
                  ],
                ),
            const ContactUsSection(),
          ],
        ),
      ),
    );
  }
}
