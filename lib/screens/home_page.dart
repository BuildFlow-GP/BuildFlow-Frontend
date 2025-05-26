import 'dart:convert';

import 'package:buildflow_frontend/screens/profiles/company_profile.dart';
import 'package:buildflow_frontend/screens/profiles/office_profile.dart';
import 'package:buildflow_frontend/screens/profiles/user_profile.dart';
import 'package:buildflow_frontend/services/session.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // ما زلتِ تستخدمين Get للتنقل
import '../widgets/about_section.dart';
import '../widgets/contact_us.dart';
import 'Design/type_of_project.dart'; // للتنقل
import '../widgets/navbar.dart';

// استيراد المودلز والسيرفس والكروت الجديدة
import '../models/office_model.dart';
import '../models/company_model.dart';
import '../models/project_model.dart';
import '../services/suggestion_service.dart';
import '../widgets/suggestions/office_suggestion_card.dart';
import '../widgets/suggestions/company_suggestion_card.dart';
import '../widgets/suggestions/project_suggestion_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SuggestionService _suggestionService = SuggestionService();

  List<OfficeModel> _suggestedOffices = [];
  List<CompanyModel> _suggestedCompanies = [];
  List<ProjectModel> _suggestedProjects = [];

  bool _isLoadingOffices = true;
  bool _isLoadingCompanies = true;
  bool _isLoadingProjects = true;
  String? _officeError;
  String? _companyError;
  String? _projectError;

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
  }

  Future<void> _fetchSuggestions() async {
    // جلب المكاتب
    try {
      final offices = await _suggestionService.getSuggestedOffices();
      if (mounted) {
        // التأكد من أن الويدجت ما زالت في الشجرة
        setState(() {
          _suggestedOffices = offices;
          _isLoadingOffices = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingOffices = false;
          _officeError = "Failed to load offices: ${e.toString()}";
          print("Error fetching offices: $e"); // للـ debugging
        });
      }
    }

    // جلب الشركات
    try {
      final companies = await _suggestionService.getSuggestedCompanies();
      if (mounted) {
        setState(() {
          _suggestedCompanies = companies;
          _isLoadingCompanies = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCompanies = false;
          _companyError = "Failed to load companies: ${e.toString()}";
          print("Error fetching companies: $e"); // للـ debugging
        });
      }
    }

    // جلب المشاريع
    try {
      final projects = await _suggestionService.getSuggestedProjects();
      if (mounted) {
        setState(() {
          _suggestedProjects = projects;
          _isLoadingProjects = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProjects = false;
          _projectError = "Failed to load projects: ${e.toString()}";
          print("Error fetching projects: $e"); // للـ debugging
        });
      }
    }
  }

  // ويدجت لعرض قائمة مقترحات أفقية
  Widget _buildSuggestionSection<T>({
    required String title,
    required bool isLoading,
    required List<T> items,
    required Widget Function(T item) cardBuilder,
    String? error,
  }) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Center(
          child: Text(error, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Center(child: Text('No $title available at the moment.')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            top: 24.0,
            bottom: 8.0,
            right: 16.0,
          ),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height:
              title.toLowerCase().contains("project")
                  ? 190
                  : 250, // تعديل الارتفاع حسب نوع الكرت
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return cardBuilder(items[index]);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // يمكنك إضافة AppBar هنا إذا أردتِ
      // appBar: AppBar(title: const Text("BuildFlow Home")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // لجعل الأقسام تمتد
          children: [
            Navbar(), // إذا كان لديك Navbar
            const AboutSection(), // قسم "عنا"
            // أزرار الإجراءات الرئيسية
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => const TypeOfProjectPage());
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Start New Project",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      _navigateToProfile();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Profile",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () {
                      // TODO: Navigate to previous projects page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Previous Projects page coming soon!"),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "My Previous Projects",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            // قسم المكاتب المقترحة
            _buildSuggestionSection<OfficeModel>(
              title: 'Suggested Offices',
              isLoading: _isLoadingOffices,
              items: _suggestedOffices,
              error: _officeError,
              cardBuilder:
                  (office) => OfficeSuggestionCard(
                    office: office,
                    onTap: () {
                      // TODO: Navigate to Office Profile Page with office.id
                      print(
                        'Tapped on Office: ${office.name} (ID: ${office.id})',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Navigate to profile of ${office.name}',
                          ),
                        ),
                      );
                    },
                    onFavoriteToggle: () {
                      // TODO: Implement favorite logic for office
                      print('Toggled favorite for Office: ${office.name}');
                    },
                  ),
            ),

            // قسم الشركات المقترحة
            _buildSuggestionSection<CompanyModel>(
              title: 'Suggested Companies',
              isLoading: _isLoadingCompanies,
              items: _suggestedCompanies,
              error: _companyError,
              cardBuilder:
                  (company) => CompanySuggestionCard(
                    company: company,
                    onTap: () {
                      // TODO: Navigate to Company Profile Page with company.id
                      print(
                        'Tapped on Company: ${company.name} (ID: ${company.id})',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Navigate to profile of ${company.name}',
                          ),
                        ),
                      );
                    },
                    onFavoriteToggle: () {
                      // TODO: Implement favorite logic for company
                      print('Toggled favorite for Company: ${company.name}');
                    },
                  ),
            ),

            // قسم المشاريع المقترحة
            _buildSuggestionSection<ProjectModel>(
              title: 'Suggested Projects',
              isLoading: _isLoadingProjects,
              items: _suggestedProjects,
              error: _projectError,
              cardBuilder:
                  (project) => ProjectSuggestionCard(
                    project: project,
                    onTap: () {
                      // TODO: Navigate to Project Details Page with project.id
                      print(
                        'Tapped on Project: ${project.name} (ID: ${project.id})',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Navigate to details of ${project.name}',
                          ),
                        ),
                      );
                    },
                    onFavoriteToggle: () {
                      // TODO: Implement favorite logic for project
                      print('Toggled favorite for Project: ${project.name}');
                    },
                  ),
            ),

            const ContactUsSection(), // قسم "اتصل بنا"
            const SizedBox(height: 20), // مسافة إضافية في الأسفل
          ],
        ),
      ),
    );
  }

  void _navigateToProfile() async {
    final token = await Session.getToken();

    if (token == null) {
      debugPrint("No token found");
      return;
    }

    try {
      // Parse JWT payload
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint("Invalid token format");
        return;
      }

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = json.decode(payload);

      final userType =
          data['userType']?.toString(); // ✅ استخدم اسم الحقل الصحيح من الباك
      final int id = data['id'];

      // تحقق إذا الويجت مازال mounted قبل استخدام context
      if (!mounted) return;

      if (userType == null) {
        debugPrint('Token data is incomplete: type or id is null');
        return;
      }

      switch (userType.toLowerCase()) {
        case 'individual':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserProfileScreen(isOwner: true),
            ),
          );
          break;
        case 'company':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CompanyProfileScreen(isOwner: true),
            ),
          );
          break;
        case 'office':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => OfficeProfileScreen(isOwner: true, officeId: id),
            ),
          );
          break;
        default:
          debugPrint("Unknown userType: $userType");
      }
    } catch (e) {
      debugPrint("Error parsing token: $e");
    }
  }
}
