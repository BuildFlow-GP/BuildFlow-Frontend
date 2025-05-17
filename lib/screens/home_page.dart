import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import '../models/office_model.dart';
import '../widgets/navbar.dart';
import '../widgets/about_section.dart';
// import '../widgets/office_suggestions.dart';
// import '../widgets/project_suggestions.dart';
import '../widgets/action_buttons.dart';
import '../widgets/contact_us.dart';
// import '../services/officeprofile_api.dart';
import '../models/session.dart';
import 'sign/signin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  void _logout() {
    Session.clearSession();
    Get.offAll(() => const SignInScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Navbar(
              userType: Session.userType,
              userId: Session.userId,
              onLogoutTap: _logout,
            ),
            const AboutSection(),
            isLoading
                ? const CircularProgressIndicator()
                : const ActionButtons(),
            const ContactUsSection(),
          ],
        ),
      ),
    );
  }
}
