// screens/project_details_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // لـ DateFormat
import '../../services/create/project_service.dart'; // أو اسم السيرفس الصحيح
import '../../models/project_readonly_model.dart';
// import '../../models/office_model.dart';
// import '../../models/company_model.dart';
// import '../../models/user_model.dart';
import '../../utils/constants.dart'; // لمسار الصور
import '../../services/Basic/favorite_service.dart'; // لإضافة/إزالة المفضلة
import '../../services/session.dart'; // للتحقق من التوكن
// استيراد صفحات بروفايل المكتب والشركة للقراءة فقط (أو العادية)
// import 'office_readonly_profile.dart';
// import 'company_readonly_profile.dart';
// import 'ReadonlyProfiles/user_readonly_profile.dart'; // إذا كان لديك

class ProjectreadDetailsScreen extends StatefulWidget {
  final int projectId;

  const ProjectreadDetailsScreen({super.key, required this.projectId});

  @override
  State<ProjectreadDetailsScreen> createState() =>
      _ProjectreadDetailsScreenState();
}

class _ProjectreadDetailsScreenState extends State<ProjectreadDetailsScreen> {
  final ProjectService _projectService = ProjectService();
  final FavoriteService _favoriteService = FavoriteService();
  Future<ProjectreadonlyModel>? _projectDetailsFuture;
  bool _isFavorite = false; // حالة المفضلة للمشروع الحالي
  bool _isFavoriteLoading = true; // حالة تحميل المفضلة

  @override
  void initState() {
    super.initState();
    _loadProjectDetails();
    _checkIfFavorite(); // تحقق من حالة المفضلة
  }

  void _loadProjectDetails() {
    _projectDetailsFuture = _projectService.getProjectDetails(widget.projectId);
  }

  Future<void> _checkIfFavorite() async {
    final token = await Session.getToken();
    if (token == null || token.isEmpty) {
      if (mounted) setState(() => _isFavoriteLoading = false);
      return; // لا يمكن التحقق من المفضلة بدون توكن
    }
    try {
      final favorites = await _favoriteService.getFavorites();
      if (mounted) {
        setState(() {
          _isFavorite = favorites.any(
            (fav) =>
                fav.itemId == widget.projectId && fav.itemType == 'project',
          );
          _isFavoriteLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isFavoriteLoading = false);
      print("Error checking if project is favorite: $e");
    }
  }

  Future<void> _toggleFavorite(ProjectreadonlyModel project) async {
    final token = await Session.getToken();
    if (token == null || token.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to manage favorites.')),
        );
      }
      return;
    }

    setState(() => _isFavoriteLoading = true); // إظهار تحميل لزر المفضلة
    try {
      if (_isFavorite) {
        await _favoriteService.removeFavorite(project.id, 'project');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${project.name} removed from favorites.')),
          );
        }
      } else {
        await _favoriteService.addFavorite(project.id, 'project');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${project.name} added to favorites.')),
          );
        }
      }
      // تحديث حالة الأيقونة بعد النجاح
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
          _isFavoriteLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorites: ${e.toString()}'),
          ),
        );
        setState(() => _isFavoriteLoading = false);
      }
      print("Error toggling favorite for project ${project.id}: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Details')),
      body: FutureBuilder<ProjectreadonlyModel>(
        future: _projectDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Project not found.'));
          } else {
            final project = snapshot.data!;
            return _buildProjectContent(project);
          }
        },
      ),
    );
  }

  Widget _buildProjectContent(ProjectreadonlyModel project) {
    final dateFormat = DateFormat('dd MMM, yyyy');
    final currencyFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
    ); // عدلي حسب عملتك

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!_isFavoriteLoading) // فقط أظهر زر المفضلة إذا انتهى التحقق
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color:
                        _isFavorite
                            ? Colors.redAccent
                            : Theme.of(context).iconTheme.color,
                    size: 28,
                  ),
                  tooltip:
                      _isFavorite
                          ? 'Remove from Favorites'
                          : 'Add to Favorites',
                  onPressed: () => _toggleFavorite(project),
                )
              else
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
            ],
          ),
          const SizedBox(height: 8.0),
          _buildStatusChip(project.status),
          const SizedBox(height: 16.0),
          if (project.description != null && project.description!.isNotEmpty)
            Text(
              project.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

          const SizedBox(height: 20.0),
          _buildSectionTitle('Project Information'),
          _buildInfoRow(
            'Budget:',
            project.budget != null
                ? currencyFormat.format(project.budget)
                : 'N/A',
          ),
          _buildInfoRow(
            'Start Date:',
            project.startDate != null
                ? dateFormat.format(project.startDate!)
                : 'N/A',
          ),
          _buildInfoRow(
            'End Date:',
            project.endDate != null
                ? dateFormat.format(project.endDate!)
                : 'N/A',
          ),
          _buildInfoRow('Location:', project.location ?? 'N/A'),
          _buildInfoRow('Created On:', dateFormat.format(project.createdAt)),

          if (project.landLocation != null ||
              project.plotNumber != null ||
              project.basinNumber != null ||
              project.landArea != null) ...[
            const SizedBox(height: 20.0),
            _buildSectionTitle('Land Details'),
            if (project.landLocation != null)
              _buildInfoRow('Land Location:', project.landLocation!),
            if (project.plotNumber != null)
              _buildInfoRow('Plot Number:', project.plotNumber!),
            if (project.basinNumber != null)
              _buildInfoRow('Basin Number:', project.basinNumber!),
            if (project.landArea != null)
              _buildInfoRow('Land Area:', '${project.landArea} m²'),
          ],

          // معلومات المكتب المنفذ
          if (project.office != null) ...[
            const SizedBox(height: 20.0),
            _buildSectionTitle('Implementing Office'),
            _buildEntityCard(
              name: project.office!.name,
              imageUrl: project.office!.profileImage,
              typeLabel: project.office!.location, // مثال لعرض موقع المكتب
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder:
                //         (context) => OfficerReadOnlyProfileScreen(
                //           officeId: project.office!.id,
                //         ),
                //   ),
                // );
              },
            ),
          ],

          // معلومات الشركة المنفذة
          if (project.company != null) ...[
            const SizedBox(height: 20.0),
            _buildSectionTitle('Implementing Company'),
            _buildEntityCard(
              name: project.company!.name,
              imageUrl: project.company!.profileImage,
              typeLabel: project.company!.companyType, // مثال لعرض نوع الشركة
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder:
                //         (context) => CompanyReadOnlyProfileScreen(
                //           companyId: project.company!.id,
                //         ),
                //   ),
                // );
              },
            ),
          ],

          // معلومات مالك المشروع (إذا قررتِ عرضها)
          if (project.user != null) ...[
            const SizedBox(height: 20.0),
            _buildSectionTitle('Project Owner'),
            _buildEntityCard(
              name: project.user!.name,
              imageUrl: project.user!.profileImage,
              typeLabel: project.user!.email, // مثال لعرض إيميل المالك
              onTap: () {
                // يمكنكِ هنا الانتقال لبروفايل المستخدم إذا كان لديكِ شاشة لذلك
                // أو عدم جعلها قابلة للضغط
              },
            ),
          ],

          // روابط المستندات (إذا كانت عامة)
          if (project.document2D != null || project.document3D != null) ...[
            const SizedBox(height: 20.0),
            _buildSectionTitle('Project Documents'),
            if (project.document2D != null && project.document2D!.isNotEmpty)
              _buildDocumentLink("2D Documents", project.document2D!),
            if (project.document3D != null && project.document3D!.isNotEmpty)
              _buildDocumentLink("3D Model/Renders", project.document3D!),
          ],

          // يمكنكِ إضافة قسم للمراجعات هنا إذا أردتِ
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;
    IconData iconData;

    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        iconData = Icons.hourglass_empty_rounded;
        break;
      case 'in progress':
      case 'inprogress':
        chipColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        iconData = Icons.construction_rounded;
        break;
      case 'completed':
        chipColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        iconData = Icons.check_circle_outline_rounded;
        break;
      case 'cancelled':
        chipColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        iconData = Icons.cancel_outlined;
        break;
      default:
        chipColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
        iconData = Icons.help_outline_rounded;
    }
    return Chip(
      avatar: Icon(iconData, color: textColor, size: 18),
      label: Text(
        status,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
    );
  }

  Widget _buildEntityCard({
    required String name,
    String? imageUrl,
    String? typeLabel,
    VoidCallback? onTap,
  }) {
    ImageProvider? imageProvider;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      imageProvider = NetworkImage(
        imageUrl.startsWith('http')
            ? imageUrl
            : '${Constants.baseUrl}/$imageUrl',
      ); // تأكدي من ApiConfig
    }

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: imageProvider,
                onBackgroundImageError: (_, __) {},
                backgroundColor: Colors.grey.shade300,
                child:
                    imageProvider == null
                        ? const Icon(Icons.person, size: 28)
                        : null,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (typeLabel != null && typeLabel.isNotEmpty) ...[
                      const SizedBox(height: 2.0),
                      Text(
                        typeLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentLink(String title, String documentPath) {
    // في تطبيق حقيقي، ستستخدمين url_launcher لفتح الـ URL
    // import 'package:url_launcher/url_launcher.dart';
    // Future<void> _launchURL(String url) async {
    //   if (await canLaunchUrl(Uri.parse(url))) {
    //     await launchUrl(Uri.parse(url));
    //   } else {
    //     throw 'Could not launch $url';
    //   }
    // }
    String fullUrl =
        documentPath.startsWith('http')
            ? documentPath
            : '${Constants.baseUrl}/$documentPath';

    return ListTile(
      leading: const Icon(
        Icons.insert_drive_file_outlined,
        color: Colors.blueAccent,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.blueAccent,
          decoration: TextDecoration.underline,
        ),
      ),
      onTap: () {
        print("Attempting to open document: $fullUrl");
        // _launchURL(fullUrl); // لإلغاء التعليق بعد إضافة url_launcher
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Link to: $fullUrl (url_launcher needed)")),
        );
      },
    );
  }
}
