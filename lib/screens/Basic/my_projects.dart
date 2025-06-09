import 'package:buildflow_frontend/services/session.dart' show Session;
import 'package:flutter/material.dart';
// import '../../models/Basic/project_model.dart';
import '../../services/create/project_service.dart';

// import '../../models/userprojects/project_simplified_model.dart';

import '../../widgets/Suggestions/my_project_card.dart';
import '../Design/my_project_details.dart';

class MyProjectsScreen extends StatefulWidget {
  const MyProjectsScreen({super.key});

  @override
  State<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen> {
  final ProjectService _projectService = ProjectService();

  late Future<List<dynamic>> _myProjectsFuture;
  String? _sessionUserType;

  // ignore: unused_field
  final bool _isLoadingUserType = true; //  لتتبع تحميل نوع المستخدم

  // ignore: unused_field
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    // ✅ الآن التعيين صحيح لأن _loadDataBasedOnUserType ترجع Future<List<dynamic>>
    _myProjectsFuture = _loadDataBasedOnUserType();
  }

  // ✅  دالة _loadDataBasedOnUserType ترجع Future<List<dynamic>>
  Future<List<dynamic>> _loadDataBasedOnUserType() async {
    if (mounted) {
      setState(() {
        _isInitializing = true;
      });
    }

    try {
      _sessionUserType = await Session.getUserType();
      if (!mounted) return [];

      if (_sessionUserType == null) {
        throw Exception("User type not found in session.");
      }

      if (_sessionUserType!.toLowerCase() == 'office') {
        logger.i("Loading projects for OFFICE");
        // getAssignedOfficeProjects ترجع Future<List<ProjectModel>>
        // ProjectModel هو جزء من dynamic، لذا هذا التعيين صحيح
        return await _projectService.getAssignedOfficeProjects();
      } else if (_sessionUserType!.toLowerCase() == 'individual') {
        logger.i("Loading projects for INDIVIDUAL");
        // getMyProjects ترجع Future<List<ProjectsimplifiedModel>>
        // ProjectsimplifiedModel هو جزء من dynamic، لذا هذا التعيين صحيح
        return await _projectService.getMyProjects();
      } else {
        throw Exception("Unknown user type: $_sessionUserType");
      }
    } catch (e, s) {
      logger.e("Error in _loadDataBasedOnUserType", error: e, stackTrace: s);
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  // ✅  دالة _refreshProjects أيضاً يجب أن تعيد تعيين Future<List<dynamic>>
  Future<void> _refreshProjects() async {
    if (mounted) {
      logger.i("Refreshing projects for user type: $_sessionUserType");
      setState(() {
        _myProjectsFuture = _loadDataBasedOnUserType();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Projects',
            onPressed: _refreshProjects,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _myProjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // ... (معالجة الخطأ كما هي)
            return Center(/* ... */);
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // ... (معالجة البيانات الفارغة كما هي)
            return Center(/* ... */);
          } else {
            final projects = snapshot.data!;
            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return MyProjectCard(
                  project: project,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ProjectDetailsViewScreen(projectId: project.id),
                      ),
                    ).then((value) {
                      if (value == true) {
                        _refreshProjects();
                      }
                    });
                    logger.i("Tapped on project: ${project.name}");
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
