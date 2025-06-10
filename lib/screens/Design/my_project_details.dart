// screens/project_details_view_screen.dart
import 'package:buildflow_frontend/models/Basic/user_model.dart';
import 'package:buildflow_frontend/services/create/project_design_service.dart';
import 'package:buildflow_frontend/services/create/user_update_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:logger/logger.dart';

import '../../services/create/project_service.dart'; // تم تغيير المسار
import '../../services/session.dart';
import '../../models/Basic/project_model.dart'; // يجب أن يكون هذا الموديل محدثاً

import '../../themes/app_colors.dart';
import '../../utils/constants.dart';

import 'project_description.dart';
import '../Profiles/office_profile.dart';
// import 'payment_screen.dart'; //  للدفع
// import 'planner_5d_viewer_screen.dart'; // للـ 3D

final Logger logger = Logger(
  printer: PrettyPrinter(methodCount: 1, errorMethodCount: 5),
);

class ProjectDetailsViewScreen extends StatefulWidget {
  final int projectId;
  const ProjectDetailsViewScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailsViewScreen> createState() =>
      _ProjectDetailsViewScreenState();
}

class _ProjectDetailsViewScreenState extends State<ProjectDetailsViewScreen> {
  final ProjectService _projectService = ProjectService();
  // ignore: unused_field
  final ProjectDesignService _projectDesignService = ProjectDesignService();
  final UserService _userService = UserService();

  ProjectModel? _project;
  UserModel? _currentUser;
  String? _sessionUserType;

  bool _isLoading = true;
  String? _error;

  // حالات UI للمكتب
  bool _isOfficeProposingPayment = false;
  bool _isOfficeUpdatingProgress = false;
  bool _isOfficeUploadingDoc = false;
  bool _isOfficeEditingName = false;

  final TextEditingController _paymentAmountController =
      TextEditingController();
  final TextEditingController _paymentNotesController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();

  final List<String> _progressStageLabels = [
    "Kick-off", // Stage 0 (المرحلة الأولية)
    "Architectural Design", // Stage 1
    "Structural Design", // Stage 2
    "Electrical Design", // Stage 3
    "Mechanical Design", // Stage 4
    "Final 2D Drawings", // Stage 5
  ];
  //  أسماء حقول الملفات في ProjectModel لمراحل التقدم
  // ignore: unused_field
  final List<String> _progressDocumentKeys = [
    '', // لا يوجد ملف للمرحلة 0
    'document_1', // Architectural
    'document_2', // Structural
    'document_3', // Electrical
    'document_4', // Mechanical
    'document_2d', // Final 2D (يحدث document_2d)
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _paymentAmountController.dispose();
    _paymentNotesController.dispose();
    _projectNameController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData({bool showLoadingIndicator = true}) async {
    if (!mounted) return;
    if (showLoadingIndicator) {
      setState(() => _isLoading = true);
    }
    _error = null;

    try {
      final results = await Future.wait([
        // استخدام getbyofficeProjectDetails لجلب كل شيء
        _projectService.getbyofficeProjectDetails(widget.projectId),
        _userService.getCurrentUserDetails(),
        Session.getUserType(), // جلب نوع المستخدم من السيشن مباشرة
      ]);

      if (mounted) {
        setState(() {
          _project = results[0] as ProjectModel;
          _currentUser = results[1] as UserModel;
          _sessionUserType = results[2] as String?;

          if (_project != null) {
            _projectNameController.text = _project!.name;
            if (_project!.proposedPaymentAmount != null) {
              _paymentAmountController.text = _project!.proposedPaymentAmount!
                  .toStringAsFixed(2);
            }
            _paymentNotesController.text = _project!.paymentNotes ?? '';
          }
          _isLoading = false;
        });
      }
    } catch (e, s) {
      logger.e(
        "Error loading project details for view screen",
        error: e,
        stackTrace: s,
      );
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // === دوال الأفعال ===
  Future<void> _handleProposePayment() async {
    if (_isOfficeProposingPayment || _project == null) return;
    final amount = double.tryParse(_paymentAmountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid payment amount.")),
      );
      return;
    }
    setState(() => _isOfficeProposingPayment = true);
    try {
      final updatedProject = await _projectService.proposePayment(
        widget.projectId,
        amount,
        _paymentNotesController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment proposal sent successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        setState(
          () => _project = updatedProject,
        ); // تحديث المشروع بالبيانات الجديدة
      }
    } catch (e) {
      logger.e("Error proposing payment", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send proposal: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isOfficeProposingPayment = false);
    }
  }

  Future<void> _handleUploadProgressDocument(
    String documentKeyInModel,
    String formFieldNameForMulter,
  ) async {
    if (_isOfficeUploadingDoc || _project == null) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'dwg', 'zip', 'jpg', 'png'], //  أنواع شائعة
      withData: kIsWeb,
    );

    if (result != null) {
      PlatformFile file = result.files.single;
      if (file.size > 10 * 1024 * 1024) {
        // 10MB حد أقصى لملفات التقدم
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("File is too large (max 10MB).")),
          );
        }
        return;
      }
      Uint8List? fileBytes;
      if (kIsWeb) {
        fileBytes = file.bytes;
      } else if (file.path != null)
        // ignore: curly_braces_in_flow_control_structures
        fileBytes = await File(file.path!).readAsBytes();

      if (fileBytes != null) {
        setState(() => _isOfficeUploadingDoc = true);
        try {
          //  استخدام دالة الرفع العامة من ProjectService
          //  نحتاج لتمرير الـ apiEndpointSuffix الصحيح والـ formFieldName
          // ignore: unused_local_variable
          String apiSuffix;
          if (documentKeyInModel == 'document_1') {
            apiSuffix = 'upload-document1';
          } else if (documentKeyInModel == 'document_2')
            apiSuffix = 'upload-document2';
          else if (documentKeyInModel == 'document_3')
            apiSuffix = 'upload-document3';
          else if (documentKeyInModel == 'document_4')
            apiSuffix = 'upload-document4';
          else if (documentKeyInModel == 'document_2d')
            apiSuffix = 'upload-final2d'; // لـ 2D النهائي
          else if (documentKeyInModel == 'document_3d')
            apiSuffix = 'upload-optional3d'; // لـ 3D الاختياري
          else if (documentKeyInModel == 'license_file')
            apiSuffix = 'upload-license';
          else if (documentKeyInModel == 'agreement_file')
            apiSuffix = 'upload-agreement'; // من DesignAgreementScreen
          else {
            throw Exception(
              "Unknown document type key for upload: $documentKeyInModel",
            );
          }

          final uploadedPath = await _projectService
              ._uploadProjectDocumentInternal(
                widget.projectId,
                fileBytes,
                file.name,
                documentKeyInModel,
                formFieldNameForMulter,
              );

          if (uploadedPath != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "${documentKeyInModel.replaceAll('_', ' ')} uploaded successfully!",
                ),
                backgroundColor: Colors.green,
              ),
            );
            _loadInitialData(
              showLoadingIndicator: false,
            ); // تحديث بيانات المشروع
          }
        } catch (e) {
          logger.e("Error uploading $documentKeyInModel", error: e);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Failed to upload $documentKeyInModel: ${e.toString()}",
                ),
              ),
            );
          }
        } finally {
          if (mounted) setState(() => _isOfficeUploadingDoc = false);
        }
      }
    }
  }

  Future<void> _handleUpdateProgress(int newStage) async {
    if (_isOfficeUpdatingProgress || _project == null) return;
    setState(() => _isOfficeUpdatingProgress = true);
    try {
      final updatedProject = await _projectService.updateProjectProgress(
        widget.projectId,
        newStage,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Project progress updated!"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _project = updatedProject);
      }
    } catch (e) {
      logger.e("Error updating progress", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update progress: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isOfficeUpdatingProgress = false);
    }
  }

  Future<void> _handleUpdateProjectName() async {
    if (_projectNameController.text.isEmpty ||
        _isOfficeEditingName ||
        _project == null) {
      return;
    }
    if (_projectNameController.text == _project!.name) {
      if (mounted) setState(() => _isOfficeEditingName = false);
      return;
    }
    setState(() => _isOfficeEditingName = true);
    try {
      //  استخدام updatebyofficeProjectDetails إذا كان المكتب هو من يعدل
      final updatedProject = await _projectService.updatebyofficeProjectDetails(
        widget.projectId,
        {'name': _projectNameController.text},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Project name updated!"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _project = updatedProject);
      }
    } catch (e) {
      logger.e("Error updating project name", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update project name: ${e.toString()}"),
          ),
        );
        _projectNameController.text = _project?.name ?? '';
      }
    } finally {
      if (mounted) setState(() => _isOfficeEditingName = false);
    }
  }

  void _handleEditDesignDetails() {
    if (_project == null) return;
    const editableStates = [
      'Office Approved - Awaiting Details',
      'Details Submitted - Pending Office Review',
    ];
    if (editableStates.contains(_project!.status)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ProjectDescriptionScreen(projectId: widget.projectId),
        ),
      ).then((value) {
        if (value == true || value == null) {
          _loadInitialData(showLoadingIndicator: false); //  تحديث بعد العودة
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Design details cannot be edited in the current project status: ${_project!.status}",
          ),
        ),
      );
    }
  }

  void _handleMakePayment() {
    if (_project == null) return;
    const paymentRequiredStates = [
      'Payment Proposal Sent',
      'Awaiting User Payment',
    ];
    if (paymentRequiredStates.contains(_project!.status) &&
        _project!.proposedPaymentAmount != null) {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen(projectId: widget.projectId, amount: _project!.proposedPaymentAmount!)));
      logger.i(
        "TODO: Navigate to PaymentScreen for project ${widget.projectId}, amount: ${_project!.proposedPaymentAmount}",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Screen (Not Implemented Yet)")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No pending payment or payment not yet proposed by office.",
          ),
        ),
      );
    }
  }

  void _handleView3DViaPlanner5D() {
    //  تم تغيير اسم الدالة
    logger.i(
      "TODO: Implement Planner 5D integration for project ${widget.projectId}",
    );
    //  هنا يمكنكِ فتح رابط Planner 5D أو استخدام الـ SDK إذا كان متاحاً
    //  String planner5dUrl = "https://planner5d.com/view/?key=YOUR_PROJECT_KEY_OR_ID_ON_PLANNER5D";
    //  await launchUrl(Uri.parse(planner5dUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("3D Viewer (Planner 5D - Not Implemented Yet)"),
      ),
    );
  }

  final dateFormat = DateFormat('dd MMM, yyyy');
  final currencyFormat = NumberFormat.currency(
    locale: 'ar_JO',
    symbol: 'د.أ',
    name: 'JOD',
  );

  Widget _buildInfoRow(
    String label,
    String? value, {
    IconData? icon,
    bool isLink = false,
    VoidCallback? onLinkTap,
  }) {
    if (value == null || value.isEmpty || value.toLowerCase() == 'n/a') {
      return const SizedBox.shrink(); //  تحسين: إخفاء الصف إذا كانت القيمة N/A
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0), // تقليل المسافة
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 16,
              color: AppColors.textSecondary.withOpacity(0.8),
            )
          else
            const SizedBox(width: 26), // مساحة للأيقونة
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                fontSize: 13.5,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child:
                isLink
                    ? InkWell(
                      onTap:
                          onLinkTap ??
                          () {
                            String fullUrl =
                                value.startsWith('http')
                                    ? value
                                    : '${Constants.baseUrl}/$value';
                            logger.i("Tapped link: $fullUrl");
                            //  TODO: Implement launchUrl(Uri.parse(fullUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Open: $fullUrl (Not implemented)",
                                ),
                              ),
                            );
                          },
                      child: Text(
                        value.split('/').last,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                          fontSize: 13.5,
                        ),
                      ),
                    )
                    : Text(
                      value,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0), // تعديل المسافات
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    if (status == null || status.isEmpty) return const SizedBox.shrink();
    Color statusColor = Colors.grey.shade600;
    IconData statusIcon = Icons.info_outline_rounded;
    switch (status.toLowerCase().replaceAll(' ', '').replaceAll('-', '')) {
      case 'pendingofficeapproval':
        statusColor = Colors.orange.shade700;
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case 'officeapprovedawaitingdetails':
        statusColor = Colors.blue.shade700;
        statusIcon = Icons.playlist_add_check_rounded;
        break;
      case 'detailssubmittedpendingofficereview':
        statusColor = Colors.teal.shade700;
        statusIcon = Icons.rate_review_outlined;
        break;
      case 'awaitingpaymentproposalbyoffice':
        statusColor = Colors.purple.shade700;
        statusIcon = Icons.request_quote_outlined;
        break;
      case 'paymentproposalsent':
      case 'awaitinguserpayment':
        statusColor = Colors.deepPurple.shade700;
        statusIcon = Icons.payment_outlined;
        break;
      case 'inprogress':
        statusColor = Colors.lightBlue.shade700;
        statusIcon = Icons.construction_rounded;
        break; // تغيير اللون
      case 'completed':
        statusColor = Colors.green.shade700;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'officerejected':
      case 'cancelled':
        statusColor = Colors.red.shade700;
        statusIcon = Icons.cancel_rounded;
        break;
    }
    return Chip(
      avatar: Icon(statusIcon, color: Colors.white, size: 15),
      label: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: statusColor,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ), // تقليل الحشو
      labelPadding: const EdgeInsets.only(left: 3, right: 5),
      materialTapTargetSize:
          MaterialTapTargetSize.shrinkWrap, // لجعل الـ chip أصغر
    );
  }

  Widget _buildEntityCard({
    required String name,
    String? imageUrl,
    String? typeLabel,
    IconData defaultIcon = Icons.person,
    VoidCallback? onTap,
  }) {
    ImageProvider? imageProv;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      imageProv = NetworkImage(imageUrl);
    }
    return Card(
      elevation: 1,
      shadowColor: AppColors.shadow.withOpacity(0.05),
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundImage: imageProv,
          onBackgroundImageError: imageProv != null ? (_, __) {} : null,
          backgroundColor: AppColors.background,
          child:
              imageProv == null
                  ? Icon(defaultIcon, size: 16, color: AppColors.textSecondary)
                  : null,
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ), // تصغير الخط
        subtitle:
            typeLabel != null
                ? Text(
                  typeLabel,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                )
                : null,
        onTap: onTap,
        trailing:
            onTap != null
                ? Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.accent.withOpacity(0.7),
                )
                : null,
        dense: true, // لجعل الـ ListTile أصغر
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _project?.name ?? 'Loading Project...',
        ), //  عرض اسم المشروع أو تحميل
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Project Data',
            onPressed: _isLoading ? null : () => _loadInitialData(),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 40),
                      SizedBox(height: 10),
                      Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _loadInitialData,
                        child: Text("Retry"),
                      ),
                    ],
                  ),
                ),
              )
              : _project == null
              ? const Center(child: Text('Project data could not be loaded.'))
              : _buildProjectContentView(),
    );
  }

  Widget _buildProjectContentView() {
    if (_project == null || _currentUser == null || _sessionUserType == null) {
      return const Center(
        child: Text("Required data is missing to display project details."),
      );
    }

    final project = _project!;
    final design = project.projectDesign;
    final isUserOwner =
        _currentUser!.id == project.userId &&
        _sessionUserType!.toLowerCase() == 'individual';
    final isAssignedOffice =
        _currentUser!.id == project.officeId &&
        _sessionUserType!.toLowerCase() == 'office';

    return RefreshIndicator(
      onRefresh: () => _loadInitialData(showLoadingIndicator: false),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:
                      (isAssignedOffice &&
                              [
                                'Pending Office Approval',
                                'Office Approved - Awaiting Details',
                              ].contains(project.status))
                          ? Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  // استخدام TextFormField لتعديل أفضل
                                  controller: _projectNameController,
                                  decoration: InputDecoration(
                                    hintText: "Project Name",
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                  ),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ), // استخدام titleLarge
                                  onFieldSubmitted:
                                      (value) => _handleUpdateProjectName(),
                                ),
                              ),
                              _isOfficeEditingName
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : IconButton(
                                    icon: Icon(
                                      Icons.save_alt_rounded,
                                      color: AppColors.accent,
                                      size: 22,
                                    ),
                                    onPressed: _handleUpdateProjectName,
                                    tooltip: "Save Name",
                                  ),
                            ],
                          )
                          : Text(
                            project.name,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(project.status),
              ],
            ),
            if (project.description!.isNotEmpty) ...[
              const SizedBox(height: 10.0),
              Text(
                project.description ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14.5,
                ),
              ),
            ],

            _buildSectionTitle('Key Information'),
            _buildInfoRow(
              'Est. Budget (User):',
              project.budget != null
                  ? currencyFormat.format(project.budget)
                  : 'N/A',
              icon: Icons.account_balance_wallet_outlined,
            ),
            _buildInfoRow(
              'Start Date:',
              project.startDate != null
                  ? dateFormat.format(project.startDate!.toLocal())
                  : 'N/A',
              icon: Icons.calendar_today_outlined,
            ),
            _buildInfoRow(
              'Expected End Date:',
              project.endDate != null
                  ? dateFormat.format(project.endDate!.toLocal())
                  : 'N/A',
              icon: Icons.event_busy_outlined,
            ),
            _buildInfoRow(
              'General Location:',
              project.location!.isNotEmpty ? project.location : 'N/A',
              icon: Icons.location_city_outlined,
            ),
            _buildInfoRow(
              'Created:',
              dateFormat.format(project.createdAt.toLocal()),
              icon: Icons.history_edu_outlined,
            ),

            if (project.landArea != null || project.plotNumber!.isNotEmpty) ...[
              _buildSectionTitle('Land Specifics'),
              _buildInfoRow(
                'Land Area:',
                project.landArea != null
                    ? '${project.landArea!.toStringAsFixed(2)} m²'
                    : 'N/A',
                icon: Icons.landscape_outlined,
              ),
              _buildInfoRow(
                'Plot Number:',
                project.plotNumber!.isNotEmpty ? project.plotNumber : 'N/A',
                icon: Icons.signpost_outlined,
              ),
              _buildInfoRow(
                'Basin Number:',
                project.basinNumber!.isNotEmpty ? project.basinNumber : 'N/A',
                icon: Icons.document_scanner_outlined,
              ),
              _buildInfoRow(
                'Land Location (Detail):',
                project.landLocation!.isNotEmpty ? project.landLocation : 'N/A',
                icon: Icons.explore_outlined,
              ),
            ],

            _buildSectionTitle(
              'Design Specifications',
              trailing:
                  (isUserOwner &&
                          [
                            'Office Approved - Awaiting Details',
                            'Details Submitted - Pending Office Review',
                          ].contains(project.status))
                      ? Tooltip(
                        message: "Edit Design Details",
                        child: InkWell(
                          onTap: _handleEditDesignDetails,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.edit_note_rounded,
                              color: AppColors.accent,
                              size: 22,
                            ),
                          ),
                        ),
                      )
                      : null,
            ),
            if (design != null) ...[
              _buildInfoRow(
                'Floors:',
                design.floorCount?.toString() ?? 'N/A',
                icon: Icons.stairs_outlined,
              ),
              _buildInfoRow(
                'Bedrooms:',
                design.bedrooms?.toString() ?? 'N/A',
                icon: Icons.bed_outlined,
              ),
              _buildInfoRow(
                'Bathrooms:',
                design.bathrooms?.toString() ?? 'N/A',
                icon: Icons.bathtub_outlined,
              ),
              _buildInfoRow(
                'Kitchens:',
                design.kitchens?.toString() ?? 'N/A',
                icon: Icons.kitchen_outlined,
              ),
              _buildInfoRow(
                'Balconies:',
                design.balconies?.toString() ?? 'N/A',
                icon: Icons.balcony_outlined,
              ),
              _buildInfoRow(
                'Kitchen Type:',
                design.kitchenType ?? 'N/A',
                icon: Icons.restaurant_menu_outlined,
              ),
              _buildInfoRow(
                'Master Has Bathroom:',
                design.masterHasBathroom == true
                    ? 'Yes'
                    : (design.masterHasBathroom == false ? 'No' : 'N/A'),
                icon: Icons.wc_rounded,
              ),
              if (design.specialRooms != null &&
                  design.specialRooms!.isNotEmpty)
                _buildInfoRow(
                  'Special Rooms:',
                  design.specialRooms!.join(', '),
                  icon: Icons.meeting_room_outlined,
                ),
              if (design.directionalRooms != null &&
                  design.directionalRooms!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.compass_calibration_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Directional Rooms:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30, top: 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              (design.directionalRooms! as List<dynamic>).map((
                                e,
                              ) {
                                final roomMap = e as Map<String, dynamic>;
                                return Text(
                                  '• ${roomMap['room']}: ${roomMap['direction']}',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: AppColors.textPrimary,
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              if (design.budgetMin != null || design.budgetMax != null) ...[
                _buildSectionTitle('User\'s Design Budget Range'),
                _buildInfoRow(
                  'Min:',
                  design.budgetMin != null
                      ? currencyFormat.format(design.budgetMin)
                      : 'N/A',
                  icon: Icons.remove_circle_outline_outlined,
                ),
                _buildInfoRow(
                  'Max:',
                  design.budgetMax != null
                      ? currencyFormat.format(design.budgetMax)
                      : 'N/A',
                  icon: Icons.add_circle_outline_outlined,
                ),
              ],
              _buildSectionTitle('User\'s Design Descriptions'),
              if (design.generalDescription != null &&
                  design.generalDescription!.isNotEmpty)
                _buildInfoRow(
                  'General:',
                  design.generalDescription,
                  icon: Icons.notes_outlined,
                ),
              if (design.interiorDesign != null &&
                  design.interiorDesign!.isNotEmpty)
                _buildInfoRow(
                  'Interior:',
                  design.interiorDesign,
                  icon: Icons.palette_outlined,
                ),
              if (design.roomDistribution != null &&
                  design.roomDistribution!.isNotEmpty)
                _buildInfoRow(
                  'Room Layout:',
                  design.roomDistribution,
                  icon: Icons.space_dashboard_outlined,
                ),
            ] else if ((project.status ==
                        'Office Approved - Awaiting Details' ||
                    project.status ==
                        'Details Submitted - Pending Office Review') &&
                isUserOwner)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        "You haven't submitted design details yet.",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.description_outlined),
                        label: const Text("Submit Design Details Now"),
                        onPressed: _handleEditDesignDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: Text(
                    "No design details submitted for this project yet.",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ),

            if (project.office != null) ...[
              _buildSectionTitle('Assigned Office'),
              _buildEntityCard(
                name: project.office!.name,
                imageUrl: project.office!.profileImage,
                typeLabel: project.office!.location,
                defaultIcon: Icons.maps_home_work_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => OfficeProfileScreen(
                            officeId: project.office!.id,
                            isOwner: true,
                          ),
                    ),
                  );
                },
              ),
            ],
            if (project.user != null && !isUserOwner) ...[
              //  لا تعرض مالك المشروع إذا كان هو نفسه المستخدم الحالي
              _buildSectionTitle('Project Owner'),
              _buildEntityCard(
                name: project.user!.name,
                imageUrl: project.user!.profileImage,
                typeLabel: project.user!.email,
                defaultIcon: Icons.person_outline,
              ),
            ],

            _buildSectionTitle('Documents'),
            _buildDocumentItem(
              'Agreement Document:',
              project.agreementFile,
              'agreement_file',
              canUserUpload:
                  isUserOwner &&
                  project.status ==
                      'Office Approved - Awaiting Details' /* أو حالة أخرى تسمح للمستخدم برفع الاتفاقية */,
            ),
            _buildDocumentItem(
              'License File:',
              project.licenseFile,
              'license_file',
              canUserUpload:
                  isUserOwner &&
                  project.status ==
                      'Office Approved - Awaiting Details' /* أو حالة أخرى تسمح للمستخدم برفع الرخصة */,
            ),
            _buildDocumentItem(
              '2D Architectural (from Office):',
              project.document1,
              'document_1',
            ), // هذا ملف التقدم الأول
            _buildDocumentItem(
              '2D Structural (from Office):',
              project.document2,
              'document_2',
            ),
            _buildDocumentItem(
              '2D Electrical (from Office):',
              project.document3,
              'document_3',
            ),
            _buildDocumentItem(
              '2D Mechanical (from Office):',
              project.document4,
              'document_4',
            ),
            _buildDocumentItem(
              'Final 2D Drawings (from Office):',
              project.document2D,
              'document_2d',
            ), // هذا هو document_2d من المشروع
            _buildDocumentItem(
              'Optional 3D Model (from Office):',
              project.document3D,
              'document_3d',
            ), // هذا هو document_3d من المشروع
            // === أقسام خاصة بالمكتب ===
            if (isAssignedOffice) ...[
              _buildOfficePaymentSection(project),
              _buildOfficeProgressSection(project),
              _buildOfficeDocumentUploadSectionForProgress(
                project,
              ), //  دالة جديدة لرفع ملفات التقدم
            ],

            // === أقسام خاصة بالمستخدم ===
            if (isUserOwner) ...[
              _buildUserPaymentActionSection(project),
              _buildUser3DViewSection(project),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficeDocumentUploadSectionForProgress(ProjectModel project) {
    final bool canUpload = [
      'In Progress',
      'Details Submitted - Pending Office Review',
      'Awaiting User Payment',
      'Payment Proposal Sent',
    ].contains(project.status);
    if (!canUpload) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Upload Progress Documents (Office)'),
        _buildUploadButtonForProgressStage(
          project,
          1,
          'document_1',
          'Architectural',
        ), //  المرحلة 1 -> document_1
        _buildUploadButtonForProgressStage(
          project,
          2,
          'document_2',
          'Structural',
        ), //  المرحلة 2 -> document_2
        _buildUploadButtonForProgressStage(
          project,
          3,
          'document_3',
          'Electrical',
        ), //  المرحلة 3 -> document_3
        _buildUploadButtonForProgressStage(
          project,
          4,
          'document_4',
          'Mechanical',
        ), //  المرحلة 4 -> document_4
        _buildUploadButtonForProgressStage(
          project,
          5,
          'document_2d',
          'Final 2D',
        ), //  المرحلة 5 -> document_2d
        _buildUploadButtonForProgressStage(
          project,
          -1,
          'document_3d',
          'Optional 3D Model',
        ), //  -1 لتمييزه كاختياري
        if (_isOfficeUploadingDoc)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: LinearProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildUploadButtonForProgressStage(
    ProjectModel project,
    int stageNumber,
    String documentKeyInModel,
    String buttonLabel,
  ) {
    // استخراج المسار الحالي للملف من كائن المشروع
    String? currentFilePath;
    // هذه طريقة غير مباشرة للوصول للحقل، الأفضل إذا كان ProjectModel لديه طريقة للوصول للحقول بالاسم
    // أو يمكنكِ عمل switch case هنا
    if (documentKeyInModel == 'document_1') {
      currentFilePath = project.document1;
    } else if (documentKeyInModel == 'document_2')
      // ignore: curly_braces_in_flow_control_structures
      currentFilePath = project.document2;
    else if (documentKeyInModel == 'document_3')
      // ignore: curly_braces_in_flow_control_structures
      currentFilePath = project.document3;
    else if (documentKeyInModel == 'document_4')
      // ignore: curly_braces_in_flow_control_structures
      currentFilePath = project.document4;
    else if (documentKeyInModel == 'document_2d')
      // ignore: curly_braces_in_flow_control_structures
      currentFilePath = project.document2D;
    else if (documentKeyInModel == 'document_3d')
      // ignore: curly_braces_in_flow_control_structures
      currentFilePath = project.document3D;

    String formFieldName = '';
    if (documentKeyInModel == 'document_1') {
      formFieldName = 'document1File';
    } else if (documentKeyInModel == 'document_2')
      formFieldName = 'document2File';
    else if (documentKeyInModel == 'document_3')
      formFieldName = 'document3File';
    else if (documentKeyInModel == 'document_4')
      formFieldName = 'document4File';
    else if (documentKeyInModel == 'document_2d')
      formFieldName = 'final2dFile';
    else if (documentKeyInModel == 'document_3d')
      formFieldName = 'optional3dFile';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Stage ${stageNumber > 0 ? stageNumber : ''}: $buttonLabel",
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          if (currentFilePath != null && currentFilePath.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.visibility_outlined,
                color: AppColors.accent,
                size: 20,
              ),
              onPressed: () {
                String fullUrl =
                    currentFilePath!.startsWith('http')
                        ? currentFilePath
                        : '${Constants.baseUrl}/$currentFilePath';
                logger.i("Viewing document: $fullUrl");
                // TODO: launchUrl(Uri.parse(fullUrl));
              },
              tooltip: "View ${currentFilePath.split('/').last}",
            )
          else
            const Icon(
              Icons.description_outlined,
              color: Colors.grey,
              size: 20,
            ), // أيقونة إذا لم يتم الرفع بعد
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed:
                _isOfficeUploadingDoc
                    ? null
                    : () => _handleUploadProgressDocument(
                      documentKeyInModel,
                      formFieldName,
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (currentFilePath != null && currentFilePath.isNotEmpty)
                      ? Colors.orangeAccent
                      : AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              textStyle: const TextStyle(fontSize: 11),
            ),
            child: Text(
              (currentFilePath != null && currentFilePath.isNotEmpty)
                  ? "Re-upload"
                  : "Upload",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficePaymentSection(ProjectModel project) {
    // ... (نفس الكود من الرد السابق مع تعديل بسيط في validator إذا لزم الأمر)
    const SizedBoxtiny = SizedBox(height: 8);
    final bool canProposePayment =
        project.status == 'Details Submitted - Pending Office Review' ||
        project.status == 'Awaiting Payment Proposal by Office';
    final bool paymentAlreadyProposed =
        project.proposedPaymentAmount != null &&
        (project.status == 'Payment Proposal Sent' ||
            project.status == 'Awaiting User Payment' ||
            project.status == 'In Progress' ||
            project.status == 'Completed');

    if (!canProposePayment && !paymentAlreadyProposed) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Payment Proposal (Office)'),
        if (paymentAlreadyProposed) ...[
          _buildInfoRow(
            'Proposed Amount:',
            currencyFormat.format(project.proposedPaymentAmount!),
            icon: Icons.price_check_rounded,
          ),
          if (project.paymentNotes != null && project.paymentNotes!.isNotEmpty)
            _buildInfoRow(
              'Office Notes:',
              project.paymentNotes,
              icon: Icons.notes_rounded,
            ),
          _buildInfoRow(
            'Payment Status:',
            project.paymentStatus ?? 'N/A',
            icon: Icons.credit_card_outlined,
          ),
          if (project.paymentStatus?.toLowerCase().contains('pending') ??
              true) //  إذا كان لا يزال pending
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Payment proposal has been sent to the user.",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.blue.shade700,
                ),
              ),
            )
          else if (project.paymentStatus?.toLowerCase() == 'paid')
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Payment received. Project is active.",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.green.shade700,
                ),
              ),
            ),
        ] else if (canProposePayment) ...[
          TextFormField(
            controller: _paymentAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Proposed Payment Amount (JOD)',
              prefixText: '${currencyFormat.currencySymbol} ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ), // تعديل الـ radius
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ), // تعديل الحشو
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Amount is required';
              final pValue = double.tryParse(value);
              if (pValue == null || pValue <= 0) {
                return 'Enter a valid positive amount';
              }
              return null;
            },
          ),
          SizedBoxtiny,
          TextFormField(
            controller: _paymentNotesController,
            decoration: InputDecoration(
              labelText: 'Payment Notes (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            maxLines: 2,
          ),
          SizedBoxtiny,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon:
                  _isOfficeProposingPayment
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(
                        Icons.send_and_archive_outlined,
                        size: 18,
                      ), // تغيير الأيقونة
              label: Text(
                _isOfficeProposingPayment
                    ? 'Sending...'
                    : 'Send Payment Proposal to User',
              ),
              onPressed:
                  _isOfficeProposingPayment ? null : _handleProposePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOfficeProgressSection(ProjectModel project) {
    // ... (نفس الكود من الرد السابق مع تعديل label الـ slider)
    final bool canUpdateProgress = [
      'In Progress',
      'Details Submitted - Pending Office Review',
      'Awaiting User Payment',
      'Payment Proposal Sent',
    ].contains(project.status);
    if (!canUpdateProgress &&
        project.status != 'Completed' &&
        project.status != 'Pending Office Approval' &&
        project.status != 'Office Approved - Awaiting Details') {
      // لا تعرض إذا لم يبدأ العمل الفعلي
      return const SizedBox.shrink();
    }

    int currentStage = project.progressStage ?? 0;
    if (currentStage < 0) currentStage = 0;
    if (currentStage >= _progressStageLabels.length) {
      currentStage = _progressStageLabels.length - 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Project Progress (Office Update)'),
        if (project.status == 'Completed')
          Center(
            child: Chip(
              label: Text(
                "Project Marked as Completed",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              avatar: Icon(Icons.verified_user_outlined, color: Colors.white),
            ),
          )
        else if (project.status == 'Pending Office Approval' ||
            project.status == 'Office Approved - Awaiting Details')
          Center(
            child: Chip(
              label: Text(
                "Waiting for project details submission or payment to start progress.",
                style: TextStyle(color: AppColors.textSecondary),
              ),
              backgroundColor: Colors.grey.shade300,
              avatar: Icon(
                Icons.hourglass_empty_rounded,
                color: AppColors.textSecondary,
              ),
            ),
          )
        else ...[
          Text(
            "Current Stage: ${_progressStageLabels[currentStage]} (${((currentStage / (_progressStageLabels.length - 1)) * 100).toStringAsFixed(0)}%)",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          Slider(
            value: currentStage.toDouble(),
            min: 0,
            max: (_progressStageLabels.length - 1).toDouble(),
            divisions: _progressStageLabels.length - 1,
            label:
                _progressStageLabels[currentStage], // الـ label يظهر عند السحب
            activeColor: AppColors.accent,
            inactiveColor: AppColors.primary.withOpacity(0.3),
            onChanged:
                _isOfficeUpdatingProgress
                    ? null
                    : (double value) {
                      // لا نحدث مباشرة هنا، بل بعد انتهاء السحب
                    },
            onChangeEnd: (double value) {
              _handleUpdateProgress(value.toInt());
            },
          ),
          if (_isOfficeUpdatingProgress)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(child: LinearProgressIndicator(minHeight: 2)),
            ),
        ],
      ],
    );
  }

  Widget _buildUserPaymentActionSection(ProjectModel project) {
    // ... (نفس الكود)
    final bool canMakePayment =
        (project.status == 'Payment Proposal Sent' ||
            project.status == 'Awaiting User Payment') &&
        project.proposedPaymentAmount != null &&
        project.proposedPaymentAmount! > 0;
    final bool isPaid =
        project.paymentStatus?.toLowerCase() == 'paid' ||
        project.status == 'In Progress' ||
        project.status == 'Completed';

    if (!canMakePayment && !isPaid) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Payment Information'),
          _buildInfoRow(
            'Proposed Amount:',
            project.proposedPaymentAmount != null
                ? currencyFormat.format(project.proposedPaymentAmount!)
                : 'N/A',
            icon: Icons.monetization_on_outlined,
          ),
          if (project.paymentNotes != null && project.paymentNotes!.isNotEmpty)
            _buildInfoRow(
              'Office Notes on Payment:',
              project.paymentNotes,
              icon: Icons.sticky_note_2_outlined,
            ),
          _buildInfoRow(
            'Payment Status:',
            project.paymentStatus ?? 'Pending',
            icon: Icons.credit_score_outlined,
          ),
          const SizedBox(height: 12),
          if (canMakePayment &&
              !isPaid) //  فقط إذا كان الدفع مطلوباً ولم يتم بعد
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment_rounded, size: 20),
                label: const Text(
                  'Proceed to Payment',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: _handleMakePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            )
          else if (isPaid)
            Center(
              child: Chip(
                label: Text(
                  "Payment Confirmed",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
                avatar: Icon(Icons.price_check_rounded, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUser3DViewSection(ProjectModel project) {
    //  يعرض فقط إذا كان المستخدم هو المالك وهناك ملف 3D
    //  أو إذا كان المكتب هو الذي يشاهد وهناك ملف 3D
    if (project.document3D == null || project.document3D!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(
            Icons.view_in_ar_rounded,
            size: 20,
          ), // تغيير الأيقونة
          label: const Text(
            'View 3D Model (Launch External)',
            style: TextStyle(fontSize: 15),
          ),
          onPressed: _handleView3DViaPlanner5D, //  تغيير اسم الدالة
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: AppColors.accent.withOpacity(0.7),
            ), // تعديل اللون
            foregroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentItem(
    String label,
    String? filePath,
    String documentKey, {
    bool canUserUpload = false,
  }) {
    bool isOfficeViewing =
        _sessionUserType?.toLowerCase() == 'office' &&
        _project?.officeId == _currentUser?.id;
    //  تحديد إذا كان المكتب يمكنه رفع هذا النوع من الملفات
    bool canOfficeUploadThisDocType = false;
    if (isOfficeViewing) {
      final officeUploadableDocs = [
        'document_1',
        'document_2',
        'document_3',
        'document_4',
        'document_2d',
        'document_3d',
        'license_file',
        'agreement_file',
      ]; //  المكتب يمكنه رفع كل شيء تقريباً
      canOfficeUploadThisDocType = officeUploadableDocs.contains(documentKey);
    }
    //  تحديد اسم حقل النموذج لـ multer
    String formFieldName = documentKey; //  افتراضياً
    if (documentKey == 'document_1') {
      formFieldName = 'document1File';
    } else if (documentKey == 'document_2')
      formFieldName = 'document2File';
    else if (documentKey == 'document_3')
      formFieldName = 'document3File';
    else if (documentKey == 'document_4')
      formFieldName = 'document4File';
    else if (documentKey == 'document_2d')
      formFieldName = 'final2dFile'; //  لـ 2D النهائي
    else if (documentKey == 'document_3d')
      formFieldName = 'optional3dFile'; //  لـ 3D الاختياري
    else if (documentKey == 'license_file')
      formFieldName = 'licenseFile';
    else if (documentKey == 'agreement_file')
      formFieldName = 'agreementFile';

    if (filePath == null || filePath.isEmpty) {
      if ((canUserUpload && _currentUser?.id == _project?.userId) ||
          (canOfficeUploadThisDocType && isOfficeViewing)) {
        final bool canUploadNow = [
          'Office Approved - Awaiting Details',
          'In Progress',
          'Details Submitted - Pending Office Review',
        ].contains(_project?.status ?? '');
        if (canUploadNow) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Icon(
                  Icons.attach_file_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 10),
                Text(
                  '$label:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    fontSize: 13.5,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed:
                      _isOfficeUploadingDoc
                          ? null
                          : () => _handleUploadProgressDocument(
                            documentKey,
                            formFieldName,
                          ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(60, 20),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Upload',
                    style: TextStyle(fontSize: 12, color: AppColors.accent),
                  ),
                ),
              ],
            ),
          );
        }
      }
      return _buildInfoRow(
        label,
        'Not yet uploaded',
        icon: Icons.insert_drive_file_outlined,
        onLinkTap: null,
      );
    }
    return _buildInfoRow(
      label,
      filePath.split('/').last, // عرض اسم الملف فقط
      icon: Icons.insert_drive_file_outlined,
      isLink: true,
      onLinkTap: () {
        String fullUrl =
            filePath.startsWith('http')
                ? filePath
                : '${Constants.baseUrl}/$filePath';
        logger.i("Attempting to open document: $fullUrl");
        // TODO: await launchUrl(Uri.parse(fullUrl));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Open: $fullUrl (Link tap not fully implemented)"),
          ),
        );
      },
    );
  }
}
