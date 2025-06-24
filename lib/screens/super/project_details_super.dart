// screens/supervision/project_supervision_details_screen.dart (اسم مقترح)
import 'dart:io';
import 'package:buildflow_frontend/models/Basic/project_model.dart';
import 'package:buildflow_frontend/models/Basic/user_model.dart';
import 'package:buildflow_frontend/models/create/project_design_model.dart';
import 'package:buildflow_frontend/services/create/project_service.dart';
import 'package:buildflow_frontend/services/create/project_design_service.dart';
import 'package:buildflow_frontend/services/create/user_update_service.dart';
import 'package:buildflow_frontend/themes/app_colors.dart';
import 'package:buildflow_frontend/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// شاشات للانتقال إليها (إذا لزم الأمر)
// import '../Design/project_description.dart'; // إذا كان مسموحاً بتعديل التصميم
// import '../Design/payment_screen.dart'; // إذا كان هناك دفع للإشراف
import '../../services/session.dart';
import '../Profiles/office_profile.dart';
import '../ReadonlyProfiles/office_readonly_profile.dart';

final Logger logger = Logger(
  printer: PrettyPrinter(methodCount: 1, errorMethodCount: 5),
);

class ProjectSupervisionDetailsScreen extends StatefulWidget {
  final int projectId;
  const ProjectSupervisionDetailsScreen({super.key, required this.projectId});

  @override
  State<ProjectSupervisionDetailsScreen> createState() =>
      _ProjectSupervisionDetailsScreenState();
}

class _ProjectSupervisionDetailsScreenState
    extends State<ProjectSupervisionDetailsScreen> {
  final ProjectService _projectService = ProjectService();
  final ProjectDesignService _projectDesignService = ProjectDesignService();
  final UserService _userService = UserService();

  ProjectModel? _project;
  ProjectDesignModel? _projectDesign;
  UserModel? _currentUser;
  String? _sessionUserType;

  bool _isLoading = true;
  String? _error;

  // حالات UI للمكتب
  bool _isOfficeSettingTarget = false;
  bool _isOfficeUploadingReport = false;
  // bool _isOfficeProposingSupervisionPayment = false; //  إذا كان هناك دفع للإشراف

  late TextEditingController
  _projectNameController; // اسم المشروع إذا كان المكتب سيعدله
  final TextEditingController _supervisionWeeksTargetController =
      TextEditingController();
  // final TextEditingController _supervisionPaymentAmountController = TextEditingController(); // لدفع الإشراف
  // final TextEditingController _supervisionPaymentNotesController = TextEditingController(); // لدفع الإشراف

  @override
  void initState() {
    super.initState();
    _projectNameController = TextEditingController();
    _loadInitialData();
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _supervisionWeeksTargetController.dispose();
    // _supervisionPaymentAmountController.dispose();
    // _supervisionPaymentNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData({bool showLoadingIndicator = true}) async {
    if (!mounted) return;
    if (showLoadingIndicator) setState(() => _isLoading = true);
    _error = null;
    try {
      final results = await Future.wait([
        _projectService.getProjectDetailscreate(
          widget.projectId,
        ), //  استخدام الدالة الموحدة
        _userService.getCurrentUserDetails(),
        Session.getUserType(),
        _projectDesignService.getProjectDesignDetails(widget.projectId),
      ]);
      if (mounted) {
        setState(() {
          _project = results[0] as ProjectModel?;
          _currentUser = results[1] as UserModel?;
          _sessionUserType = results[2] as String?;
          _projectDesign = results[3] as ProjectDesignModel?;

          if (_project != null) {
            _projectNameController.text = _project!.name;
            if (_project!.supervisionWeeksTarget != null) {
              _supervisionWeeksTargetController.text =
                  _project!.supervisionWeeksTarget.toString();
            }
            //  تعبئة حقول دفع الإشراف إذا كانت موجودة ومستخدمة
            // if (_project!.supervisionPaymentAmount != null) {
            //   _supervisionPaymentAmountController.text = _project!.supervisionPaymentAmount!.toStringAsFixed(2);
            // }
            // _supervisionPaymentNotesController.text = _project!.supervisionPaymentNotes ?? '';
          } else {
            _error = "Project data could not be loaded from server.";
          }
          _isLoading = false;
        });
      }
    } catch (e, s) {
      logger.e(
        "Error loading supervision project data",
        error: e,
        stackTrace: s,
      );
      if (mounted) {
        setState(() {
          _error = "Failed to load data: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  // === دوال الأفعال للمكتب ===
  Future<void> _handleSetSupervisionTarget() async {
    if (_isOfficeSettingTarget || _project == null) return;
    final weeks = int.tryParse(_supervisionWeeksTargetController.text);
    if (weeks == null || weeks <= 0 || weeks > 52) {
      // حد أقصى لعدد الأسابيع
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter a valid number of weeks (1-52)."),
          ),
        );
      }
      return;
    }
    setState(() => _isOfficeSettingTarget = true);
    try {
      //  استدعاء دالة السيرفس التي أنشأناها (أو التي ستنشئينها)
      final updatedProject = await _projectService.setSupervisionTarget(
        widget.projectId,
        weeks,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Supervision target weeks set!"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _project = updatedProject);
      }
    } catch (e) {
      logger.e("Error setting supervision target", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to set target: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isOfficeSettingTarget = false);
    }
  }

  Future<void> _handleUploadSupervisionReport(int weekNumber) async {
    if (_isOfficeUploadingReport || _project == null) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'zip', 'rar'],
      withData: kIsWeb,
    );

    if (result != null) {
      PlatformFile file = result.files.single;
      if (file.size > 10 * 1024 * 1024) {
        // 10MB
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
      } else if (file.path != null) {
        fileBytes = await File(file.path!).readAsBytes();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to read file data.")),
          );
        }
        return;
      }
      if (fileBytes != null) {
        setState(() => _isOfficeUploadingReport = true);
        try {
          //  دالة السيرفس هذه ستقوم بتحديث agreement_file و supervision_weeks_completed
          final updatedProject = await _projectService.uploadSupervisionReport(
            widget.projectId,
            weekNumber,
            fileBytes,
            file.name,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Report for week $weekNumber uploaded!"),
                backgroundColor: Colors.green,
              ),
            );
            setState(() => _project = updatedProject);
          }
        } catch (e) {
          logger.e(
            "Error uploading supervision report for week $weekNumber",
            error: e,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to upload report: ${e.toString()}"),
              ),
            );
          }
        } finally {
          if (mounted) setState(() => _isOfficeUploadingReport = false);
        }
      }
    }
  }

  // Future<void> _handleUpdateProjectName() async { /* ... إذا كان المكتب يمكنه تعديل اسم مشروع الإشراف ... */ }
  // void _handleUserEditDesignDetails() { /* ...  عادة لا يعدل المستخدم التصميم أثناء الإشراف ... */ }
  // void _handleMakeSupervisionPayment() { /* ...  للدفع الخاص بالإشراف ... */ }

  final dateFormat = DateFormat('dd MMM, yyyy');
  // final currencyFormat = NumberFormat.currency(locale: 'ar_JO', symbol: 'د.أ', name: 'JOD'); //  إذا كان هناك دفع للإشراف

  Widget _buildInfoRow(
    String label,
    String? value, {
    IconData? icon,
    bool isLink = false,
    VoidCallback? onLinkTap,
  }) {
    if (value == null || value.isEmpty || value.toLowerCase() == 'n/a') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child:
                icon != null
                    ? Icon(
                      icon,
                      size: 16,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    )
                    : null,
          ),
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
                          () async {
                            String fullUrl =
                                value.startsWith('http')
                                    ? value
                                    : '${Constants.baseUrl}/$value';
                            logger.i("Tapped link: $fullUrl");
                            await launchUrl(Uri.parse(fullUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Open: $fullUrl")),
                            );
                          },
                      child: Text(
                        value.split('/').last,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                          fontSize: 13.5,
                          overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.only(
        top: 20.0,
        bottom: 8.0,
        left: 4.0,
        right: 4.0,
      ), //  إضافة padding أفقي بسيط
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
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
        break;
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      labelPadding: const EdgeInsets.only(left: 3, right: 5),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildEntityCard({
    required String name,
    String? imageUrl,
    String? typeLabel,
    IconData defaultIcon = Icons.person,
    VoidCallback? onTap,
  }) {
    // ... (الكود كما هو)
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
        ),
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
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _project?.name ?? 'Supervision Details',
          style: const TextStyle(fontSize: 18),
        ),
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
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
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _loadInitialData,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              )
              : _project == null
              ? const Center(child: Text('Project data could not be loaded.'))
              : _buildSupervisionProjectContentView(),
    );
  }

  Widget _buildSupervisionProjectContentView() {
    if (_project == null || _currentUser == null || _sessionUserType == null) {
      return const Center(child: Text("Required data missing."));
    }

    final project = _project!;
    final design = _projectDesign; //  تفاصيل التصميم للقراءة
    final isUserOwner =
        _currentUser!.id == project.userId &&
        _sessionUserType!.toLowerCase() == 'individual';
    final isAssignedSupervisingOffice =
        _currentUser!.id == project.supervisingOfficeId &&
        _sessionUserType!.toLowerCase() == 'office';

    return RefreshIndicator(
      onRefresh: () => _loadInitialData(showLoadingIndicator: false),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === معلومات المشروع الأساسية (للقراءة) ===
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            project.name,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(project.status),
                      ],
                    ),
                    if (project.description!.isNotEmpty) ...[
                      const SizedBox(height: 8.0),
                      Text(
                        project.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const Divider(height: 20, thickness: 0.5),
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
                  ],
                ),
              ),
            ),

            // === عرض تفاصيل التصميم (للقراءة فقط) ===
            if (design != null)
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(
                        'Original Design Specifications (View Only)',
                      ),
                      _buildInfoRow(
                        'Floors:',
                        design.floorCount?.toString() ?? 'N/A',
                      ),
                      _buildInfoRow(
                        'Bedrooms:',
                        design.bedrooms?.toString() ?? 'N/A',
                      ),
                      _buildInfoRow(
                        'General Desc:',
                        design.generalDescription,
                        icon: Icons.notes_outlined,
                      ),
                      // ... يمكنكِ إضافة المزيد من حقول design هنا إذا أردتِ
                    ],
                  ),
                ),
              ),

            // === معلومات المكتب المشرف والمالك ===
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (project.supervisingOffice != null) ...[
                      _buildSectionTitle('Supervising Office'),
                      _buildEntityCard(
                        name: project.supervisingOffice!.name,
                        imageUrl: project.supervisingOffice!.profileImage,
                        typeLabel: project.supervisingOffice!.location,
                        defaultIcon: Icons.maps_home_work_outlined,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                if (Session.getUserType().toString() ==
                                    'office') {
                                  return OfficeProfileScreen(
                                    officeId: project.supervisingOffice!.id,
                                    isOwner: true,
                                  );
                                } else {
                                  return OfficerProfileScreen(
                                    officeId: project.supervisingOffice!.id,
                                    isOwner: false,
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ), //  افترض أن isOwner ستكون false للمكتب المشرف من هنا
                    ],
                  ],
                ),
              ),
            ),

            // === ✅✅✅ قسم الإشراف للمكتب ("الطريقة الهبلة") ✅✅✅ ===
            if (isAssignedSupervisingOffice) ...[
              _buildOfficeSupervisionReportSection(project),
            ],

            // === ✅✅✅ قسم عرض التقدم للمستخدم ("الطريقة الهبلة") ✅✅✅ ===
            if (isUserOwner) ...[
              _buildUserSupervisionProgressViewHabela(project),
              //  TODO: إضافة قسم لدفع الإشراف إذا كان هناك
              //  _buildUserSupervisionPaymentActionSection(project),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ✅ FOCUS: قسم الإشراف للمكتب ("الطريقة الهبلة")
  Widget _buildOfficeSupervisionReportSection(ProjectModel project) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Supervision Weekly Reports (Office)'),
            // 1. حقل لتحديد/عرض supervision_weeks_target
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _supervisionWeeksTargetController,
                    decoration: InputDecoration(
                      labelText: 'Total Supervision Weeks',
                      hintText: 'e.g., 10',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    readOnly:
                        _isOfficeSettingTarget ||
                        (project.supervisionWeeksTarget ?? 0) >
                            0, //  اجعليه للقراءة فقط إذا تم تحديده سابقاً
                    validator:
                        (val) =>
                            (val == null ||
                                    val.isEmpty ||
                                    int.tryParse(val) == null ||
                                    int.parse(val) <= 0 ||
                                    int.parse(val) > 52)
                                ? 'Enter valid weeks (1-52)'
                                : null,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      (_isOfficeSettingTarget ||
                              (project.supervisionWeeksTarget ?? 0) >
                                  0) //  عطلي الزر إذا تم التحديد أو جاري الحفظ
                          ? null
                          : _handleSetSupervisionTarget,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  child:
                      _isOfficeSettingTarget
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            "Set Target",
                            style: TextStyle(fontSize: 13),
                          ),
                ),
              ],
            ),
            if ((project.supervisionWeeksTarget ?? 0) > 0) ...[
              const Divider(height: 24),
              Text(
                "Upload Weekly Reports:",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                //  أو Column إذا كان العدد قليلاً
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: project.supervisionWeeksTarget!,
                itemBuilder: (context, index) {
                  int weekNum = index + 1;
                  bool reportConsideredSubmittedForThisWeek =
                      (project.supervisionWeeksCompleted ?? 0) >= weekNum;
                  //  المكتب يمكنه رفع تقرير الأسبوع التالي لآخر أسبوع تم "إكماله"
                  //  أو إعادة رفع تقرير أسبوع مكتمل (الكتابة فوقه)
                  bool canUploadNowForThisWeek =
                      (project.supervisionWeeksCompleted ?? 0) ==
                          (weekNum - 1) ||
                      reportConsideredSubmittedForThisWeek;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              reportConsideredSubmittedForThisWeek
                                  ? Icons.check_box_rounded
                                  : canUploadNowForThisWeek
                                  ? Icons.edit_document
                                  : Icons.hourglass_empty_rounded,
                              color:
                                  reportConsideredSubmittedForThisWeek
                                      ? Colors.green
                                      : canUploadNowForThisWeek
                                      ? AppColors.accent
                                      : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Week $weekNum Report",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (reportConsideredSubmittedForThisWeek &&
                            (project.agreementFile != null &&
                                project
                                    .agreementFile!
                                    .isNotEmpty)) //  إذا تم "إكمال" الأسبوع وهناك ملف
                          TextButton.icon(
                            icon: Icon(
                              Icons.visibility_outlined,
                              size: 16,
                              color: AppColors.accent.withOpacity(0.8),
                            ),
                            label: Text(
                              "View Last",
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.accent.withOpacity(0.8),
                              ),
                            ),
                            onPressed: () async {
                              /* ... نفس منطق فتح الملف ... */
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(60, 20),
                            ),
                          )
                        else if (canUploadNowForThisWeek)
                          ElevatedButton(
                            onPressed:
                                _isOfficeUploadingReport
                                    ? null
                                    : () =>
                                        _handleUploadSupervisionReport(weekNum),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  reportConsideredSubmittedForThisWeek
                                      ? Colors.orange.shade700
                                      : AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              textStyle: const TextStyle(fontSize: 11),
                            ),
                            child:
                                _isOfficeUploadingReport &&
                                        (project.supervisionWeeksCompleted ??
                                                0) ==
                                            (weekNum - 1)
                                    ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Text(
                                      reportConsideredSubmittedForThisWeek
                                          ? "Re-upload"
                                          : "Upload",
                                    ),
                          )
                        else
                          Text(
                            "(Upcoming)",
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "Set supervision target weeks to enable report uploads.",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ FOCUS: ويدجت عرض التقدم للمستخدم ("الطريقة الهبلة")
  Widget _buildUserSupervisionProgressViewHabela(ProjectModel project) {
    if (project.supervisionWeeksTarget == null ||
        project.supervisionWeeksTarget! <= 0) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Supervision Progress'),
              Center(
                child: Text(
                  "Supervision target not set by office yet.",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    int targetWeeks = project.supervisionWeeksTarget!;
    int completedWeeks = project.supervisionWeeksCompleted ?? 0;
    if (completedWeeks > targetWeeks) completedWeeks = targetWeeks;
    double progressValue =
        (targetWeeks > 0) ? (completedWeeks / targetWeeks) : 0.0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Supervision Progress'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: AppColors.primary.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.accent,
                        ),
                        minHeight: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "${(progressValue * 100).toStringAsFixed(0)}% ($completedWeeks/$targetWeeks weeks)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Weekly Reports (View Last Uploaded by Office):",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            if (completedWeeks == 0 &&
                (project.agreementFile == null ||
                    project
                        .agreementFile!
                        .isEmpty)) //  إذا لم يتم رفع أي تقرير بعد
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "No supervision reports submitted by office yet.",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              )
            else //  اعرض زر View Last Report دائماً إذا كان هناك agreementFile (آخر تقرير)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    completedWeeks > 0
                        ? completedWeeks
                        : (project.agreementFile != null &&
                                project.agreementFile!.isNotEmpty
                            ? 1
                            : 0), // اعرض سطراً واحداً إذا كان هناك ملف ولكن completedWeeks صفر
                itemBuilder: (context, index) {
                  int weekNum = index + 1;
                  //  للمستخدم، دائماً نعرض "View Report" إذا كان الملف موجوداً
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Report for Week $weekNum ${weekNum > completedWeeks ? '(Latest)' : ''}",
                              style: TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (project.agreementFile != null &&
                            project.agreementFile!.isNotEmpty)
                          TextButton.icon(
                            icon: Icon(
                              Icons.visibility_outlined,
                              size: 16,
                              color: AppColors.accent.withOpacity(0.8),
                            ),
                            label: Text(
                              "View Report",
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.accent.withOpacity(0.8),
                              ),
                            ),
                            onPressed: () async {
                              String fullUrl =
                                  project.agreementFile!.startsWith('http')
                                      ? project.agreementFile!
                                      : '${Constants.baseUrl}/${project.agreementFile!}';
                              if (await canLaunchUrl(Uri.parse(fullUrl))) {
                                await launchUrl(
                                  Uri.parse(fullUrl),
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(60, 20),
                            ),
                          )
                        else
                          Text(
                            "(File Missing)",
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: Colors.red.shade400,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ... (باقي الويدجتس الفرعية الأخرى: _buildUser3DViewSection, _buildDocumentItem إذا احتجت لها)
}
