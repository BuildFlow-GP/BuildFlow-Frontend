import 'package:flutter/material.dart';
import '../../services/create/project_service.dart';

import '../../models/userprojects/project_simplified_model.dart';

import '../../widgets/my_project_card.dart';

class MyProjectsScreen extends StatefulWidget {
  const MyProjectsScreen({super.key});

  @override
  State<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen> {
  final ProjectService _projectService = ProjectService();

  late Future<List<ProjectsimplifiedModel>> _myProjectsFuture;

  @override
  void initState() {
    super.initState();
    _loadMyProjects();
  }

  void _loadMyProjects() {
    _myProjectsFuture = _projectService.getMyProjects(); //  الآن يجب أن يتطابقا
  }

  void _refreshProjects() {
    if (mounted) {
      setState(() {
        _myProjectsFuture = _projectService.getMyProjects();
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
      // (6) الـ FutureBuilder يجب أن يستخدم نفس تعريف ProjectModel
      body: FutureBuilder<List<ProjectsimplifiedModel>>(
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
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder:
                    //         (context) =>
                    //             ProjectreadDetailsScreen(projectId: project.id),
                    //   ),
                    // ).then((value) {
                    //   if (value == true) {
                    //     _refreshProjects();
                    //   }
                    // });
                    print("Tapped on project: ${project.name}");
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
