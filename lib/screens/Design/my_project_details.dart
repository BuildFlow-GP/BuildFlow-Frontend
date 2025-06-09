// screens/project_details_view_screen.dart
import 'package:buildflow_frontend/models/Basic/user_model.dart';
import 'package:buildflow_frontend/services/create/user_update_service.dart'; //  للحصول على المستخدم الحالي
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart'; //  لرفع الملفات
import 'dart:typed_data'; //  لـ Uint8List
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io'; //  لـ File على الموبايل

import '../../services/create/project_service.dart';
import '../../services/create/project_design_service.dart';
import '../../services/session.dart'; //  للحصول على المستخدم الحالي
import '../../models/Basic/project_model.dart';

import '../../themes/app_colors.dart'; //  لتنسيق الألوان
import '../../utils/constants.dart'; //  لـ BASE_URL إذا احتجتِ لصور المشروع مباشرة

//  شاشات للانتقال إليها
import 'project_description.dart'; //  لتعديل وصف التصميم
// import 'payment_screen.dart'; //  شاشة الدفع (ستحتاجين لإنشائها)
import '../ReadonlyProfiles/office_readonly_profile.dart'; // لعرض بروفايل المكتب

//  للتوضيح، سأضع Logger هنا، يمكنكِ استخدام logger instance الخاص بكِ
import 'package:logger/logger.dart';

final logger = Logger();

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
  final ProjectDesignService _projectDesignService =
      ProjectDesignService(); //  للتعديل المحتمل
  final UserService _userService = UserService(); //  للحصول على المستخدم الحالي
  ProjectModel? _project;
  UserModel? _currentUser; //  لتحديد دور المستخدم الحالي

  bool _isLoading = true;
  String? _error;

  //  حالات للـ UI الخاص بالمكتب
  bool _isOfficeProposingPayment = false;
  bool _isOfficeUpdatingProgress = false;
  bool _isOfficeUploadingDoc = false;
  bool _isOfficeEditingName = false;

  final TextEditingController _paymentAmountController =
      TextEditingController();
  final TextEditingController _paymentNotesController = TextEditingController();
  final TextEditingController _projectNameController =
      TextEditingController(); //  لتعديل اسم المشروع

  //  لتقدم المشروع (مثال مبسط، يمكنكِ جعله أكثر تفصيلاً)
  final List<String> _progressStageLabels = [
    "Initial Request", // Stage 0
    "Design Phase", // Stage 1
    "2D Drafting", // Stage 2
    "3D Modeling", // Stage 3
    "Revisions", // Stage 4
    "Final Delivery", // Stage 5
  ];
  // int _currentProgressStage = 0; // سيتم أخذه من _project.progressStage
  String? _sessionUserType;

  @override
  void initState() {
    super.initState();
    _loadAllProjectData();
    _loadSessionUserType();
  }

  @override
  void dispose() {
    _paymentAmountController.dispose();
    _paymentNotesController.dispose();
    _projectNameController.dispose();
    super.dispose();
  }

  Future<void> _loadSessionUserType() async {
    _sessionUserType =
        await Session.getUserType(); //  افترض أن Session.getUserType() موجودة
    if (mounted) setState(() {});
  }

  Future<void> _loadAllProjectData({bool showLoading = true}) async {
    if (!mounted) return;
    if (showLoading) {
      setState(() => _isLoading = true);
    }
    _error = null;

    try {
      final results = await Future.wait([
        _projectService.getProjectDetailscreate(
          widget.projectId,
        ), //  يفترض أن هذه ترجع ProjectModel كامل
        _userService
            .getCurrentUserDetails(), //  للحصول على المستخدم الحالي وتحديد دوره
      ]);

      if (mounted) {
        setState(() {
          _project = results[0] as ProjectModel;
          _currentUser = results[1] as UserModel;
          if (_project != null) {
            _projectNameController.text = _project!.name;
            // _currentProgressStage = _project!.progressStage ?? 0;
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
        "Error loading project details for view",
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

  // === دوال خاصة بالمكتب ===
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
      await _projectService.proposePayment(
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
        _loadAllProjectData(
          showLoading: false,
        ); //  تحديث البيانات بدون إظهار شاشة تحميل كاملة
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

  Future<void> _handleUploadDocument(String documentType) async {
    // documentType: 'document_2d' or 'document_3d'
    if (_isOfficeUploadingDoc || _project == null) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      //  يمكنكِ تحديد allowedExtensions بشكل أكثر دقة لكل نوع
      allowedExtensions:
          documentType == 'document_2d'
              ? ['pdf', 'dwg', 'zip']
              : ['jpg', 'png', 'skp', 'max', 'obj', 'fbx', 'zip'],
      withData: kIsWeb,
    );

    if (result != null) {
      PlatformFile file = result.files.single;
      //  يمكنكِ إضافة تحقق من حجم الملف هنا إذا أردتِ
      if (file.size > 15 * 1024 * 1024) {
        // مثال: 15MB
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("File is too large (max 15MB).")),
          );
        }
        return;
      }

      Uint8List? fileBytes;
      if (kIsWeb) {
        fileBytes = file.bytes;
      } else {
        if (file.path != null) fileBytes = await File(file.path!).readAsBytes();
      }

      if (fileBytes != null) {
        setState(() => _isOfficeUploadingDoc = true);
        try {
          //  uploadProjectDocument يجب أن تقبل documentType
          await _projectService.uploadProjectDocument2D(
            widget.projectId,
            fileBytes,
            file.name,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$documentType uploaded successfully!"),
                backgroundColor: Colors.green,
              ),
            );
            _loadAllProjectData(showLoading: false);
          }
        } catch (e) {
          logger.e("Error uploading $documentType", error: e);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Failed to upload $documentType: ${e.toString()}",
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
    //  يمكنكِ إضافة تحقق هنا لمنع الرجوع للخلف في المراحل إذا أردتِ
    // if (newStage < (_project!.progressStage ?? 0) ) {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cannot revert to a previous stage.")));
    //   return;
    // }
    setState(() => _isOfficeUpdatingProgress = true);
    try {
      await _projectService.updateProjectProgress(widget.projectId, newStage);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Project progress updated!"),
            backgroundColor: Colors.green,
          ),
        );
        _loadAllProjectData(showLoading: false);
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
      // لم يتغير الاسم
      if (mounted) {
        setState(
          () => _isOfficeEditingName = false,
        ); //  فقط لإخفاء مؤشر التحميل إذا كان هناك واحد
      }
      return;
    }

    setState(() => _isOfficeEditingName = true);
    try {
      // استخدام updateProjectDetails لتحديث الاسم فقط
      await _projectService.updateProjectDetails(widget.projectId, {
        'name': _projectNameController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Project name updated!"),
            backgroundColor: Colors.green,
          ),
        );
        _loadAllProjectData(showLoading: false); // تحديث البيانات
      }
    } catch (e) {
      logger.e("Error updating project name", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update project name: ${e.toString()}"),
          ),
        );
        _projectNameController.text =
            _project?.name ?? ''; //  إعادة الاسم القديم عند الفشل
      }
    } finally {
      if (mounted) setState(() => _isOfficeEditingName = false);
    }
  }

  // === دوال خاصة بالمستخدم ===
  void _handleEditDesignDetails() {
    if (_project == null) return;
    //  تحديد الحالات التي يمكن فيها للمستخدم تعديل تفاصيل التصميم
    const editableStates = [
      'Office Approved - Awaiting Details' /*, 'Revision Requested by Office' */,
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
        //  بعد العودة من شاشة تعديل التصميم، قومي بتحديث البيانات
        if (value == true || value == null) {
          //  إذا تم أي تغيير أو تم الإغلاق
          _loadAllProjectData();
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
    //  الانتقال لصفحة الدفع فقط إذا كان هناك اقتراح دفع والمستخدم لم يدفع بعد
    const paymentRequiredStates = [
      'Payment Proposal Sent',
      'Awaiting User Payment',
    ];
    if (paymentRequiredStates.contains(_project!.status) &&
        _project!.proposedPaymentAmount != null) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => PaymentScreen(projectId: widget.projectId, amount: _project!.proposedPaymentAmount!)),
      // );
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

  void _handleView3D() {
    logger.i("TODO: Implement 3D Viewer (e.g., Planner 5D integration)");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("3D Viewer (Not Implemented Yet)")),
    );
  }

  // === ويدجتس البناء ===
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
    // ... (نفس الكود من الرد السابق، مع تعديل بسيط لـ onLinkTap)
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                fontSize: 14,
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
                            logger.i(
                              "Tapped link: $value",
                            ); /* TODO: Implement open link */
                          },
                      child: Text(
                        value.split('/').last,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    )
                    : Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Widget? trailing}) {
    // ... (نفس الكود من الرد السابق)
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    // ... (نفس الكود)
    if (status == null || status.isEmpty) return const SizedBox.shrink();
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.hourglass_empty_rounded;
    switch (status.toLowerCase().replaceAll(' ', '').replaceAll('-', '')) {
      // توحيد الحالة
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
        statusColor = Colors.cyan.shade700;
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
      default:
        statusIcon = Icons.info_outline_rounded;
    }
    return Chip(
      avatar: Icon(statusIcon, color: Colors.white, size: 16),
      label: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: statusColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      labelPadding: const EdgeInsets.only(
        left: 4,
        right: 6,
      ), // تعديل الحشو ليكون متناسقاً
    );
  }

  Widget _buildEntityCard({
    required String name,
    String? imageUrl,
    String? typeLabel,
    IconData defaultIcon = Icons.person,
    VoidCallback? onTap,
  }) {
    // ... (نفس الكود، تأكدي أن imageUrl هو URL كامل)
    ImageProvider? imageProv;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      imageProv = NetworkImage(imageUrl);
    }
    return Card(
      elevation: 1.5,
      shadowColor: AppColors.shadow.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundImage: imageProv,
          onBackgroundImageError: imageProv != null ? (_, __) {} : null,
          backgroundColor: AppColors.background, // لون خلفية مناسب
          child:
              imageProv == null
                  ? Icon(defaultIcon, size: 18, color: AppColors.textSecondary)
                  : null,
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
        ),
        subtitle:
            typeLabel != null
                ? Text(
                  typeLabel,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                )
                : null,
        onTap: onTap,
        trailing:
            onTap != null
                ? Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.accent,
                )
                : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ), // تعديل الحشو
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (نفس build)
    return Scaffold(
      appBar: AppBar(
        title: Text(_project?.name ?? 'Project Details'),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Project Data',
            onPressed: _isLoading ? null : () => _loadAllProjectData(),
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
                  child: Text(
                    'Error: $_error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
              : _project == null
              ? const Center(
                child: Text('Project data not found or could not be loaded.'),
              )
              : _buildProjectContentView(),
    );
  }

  Widget _buildProjectContentView() {
    if (_project == null) {
      return const Center(child: Text("No project data.")); //  تحقق إضافي
    }

    final project = _project!;
    final design = project.projectDesign;
    final bool isUserOwner =
        _currentUser?.id == project.userId &&
        _sessionUserType?.toLowerCase() == 'individual';
    final bool isAssignedOffice =
        _currentUser?.id == project.officeId &&
        _sessionUserType?.toLowerCase() == 'office';

    return RefreshIndicator(
      // لإضافة السحب للتحديث
      onRefresh:
          () => _loadAllProjectData(
            showLoading: false,
          ), //  لا تظهري مؤشر التحميل الدائري هنا
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), //  لتمكين السحب دائماً
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          70,
        ), //  إضافة padding سفلي للزر العائم
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === معلومات المشروع الأساسية ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:
                      isAssignedOffice &&
                              project.status ==
                                  'Pending Office Approval' //  السماح للمكتب بتعديل الاسم في هذه الحالة فقط
                          ? Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _projectNameController,
                                  decoration: const InputDecoration(
                                    labelText: "Project Name",
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  onSubmitted:
                                      (value) =>
                                          _handleUpdateProjectName(), //  حفظ عند الضغط على enter
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.save_outlined,
                                  color: AppColors.accent,
                                  size: 20,
                                ),
                                onPressed:
                                    _isOfficeEditingName
                                        ? null
                                        : _handleUpdateProjectName,
                              ),
                            ],
                          )
                          : Text(
                            project.name,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
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
              const SizedBox(height: 12.0),
              Text(
                project.description ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
            ],

            _buildSectionTitle('Key Information'),
            _buildInfoRow(
              'Budget:',
              project.budget != null
                  ? currencyFormat.format(project.budget)
                  : 'N/A',
              icon: Icons.attach_money_outlined,
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
              icon: Icons.event_available_outlined,
            ),
            _buildInfoRow(
              'Location:',
              project.location!.isNotEmpty ? project.location : 'N/A',
              icon: Icons.location_on_outlined,
            ),
            _buildInfoRow(
              'Created:',
              dateFormat.format(project.createdAt.toLocal()),
              icon: Icons.history_rounded,
            ),

            if (project.landArea != null || project.plotNumber!.isNotEmpty) ...[
              _buildSectionTitle('Land Details'),
              _buildInfoRow(
                'Land Area:',
                project.landArea != null
                    ? '${project.landArea!.toStringAsFixed(2)} m²'
                    : 'N/A',
                icon: Icons.square_foot_outlined,
              ),
              _buildInfoRow(
                'Plot Number:',
                project.plotNumber!.isNotEmpty ? project.plotNumber : 'N/A',
                icon: Icons.map_outlined,
              ),
              _buildInfoRow(
                'Basin Number:',
                project.basinNumber!.isNotEmpty ? project.basinNumber : 'N/A',
                icon: Icons.confirmation_number_outlined,
              ),
              _buildInfoRow(
                'Land Location Detail:',
                project.landLocation!.isNotEmpty ? project.landLocation : 'N/A',
                icon: Icons.pin_drop_outlined,
              ),
            ],

            _buildSectionTitle(
              'Design Specifications',
              trailing:
                  (isUserOwner &&
                          (project.status ==
                              'Office Approved - Awaiting Details' /* || حالة طلب التعديل */ ))
                      ? IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: AppColors.accent,
                          size: 20,
                        ),
                        onPressed: _handleEditDesignDetails,
                        tooltip: "Edit Design Details",
                      )
                      : null,
            ),
            if (design != null) ...[
              _buildInfoRow(
                'Floors:',
                design.floorCount?.toString() ?? 'N/A',
                icon: Icons.layers_outlined,
              ),
              _buildInfoRow(
                'Bedrooms:',
                design.bedrooms?.toString() ?? 'N/A',
                icon: Icons.king_bed_outlined,
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
                icon: Icons.countertops_outlined,
              ),
              _buildInfoRow(
                'Master Has Bathroom:',
                design.masterHasBathroom == true
                    ? 'Yes'
                    : (design.masterHasBathroom == false ? 'No' : 'N/A'),
                icon: Icons.wc_outlined,
              ),
              if (design.specialRooms != null &&
                  design.specialRooms!.isNotEmpty)
                _buildInfoRow(
                  'Special Rooms:',
                  design.specialRooms!.join(', '),
                  icon: Icons.star_border_purple500_outlined,
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
                            Icons.explore_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Directional Rooms:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 28, top: 4),
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
                                    fontSize: 14,
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
                _buildSectionTitle('User\'s Estimated Design Budget'),
                _buildInfoRow(
                  'Min Budget:',
                  design.budgetMin != null
                      ? currencyFormat.format(design.budgetMin)
                      : 'N/A',
                  icon: Icons.money_off_csred_outlined,
                ),
                _buildInfoRow(
                  'Max Budget:',
                  design.budgetMax != null
                      ? currencyFormat.format(design.budgetMax)
                      : 'N/A',
                  icon: Icons.monetization_on_outlined,
                ),
              ],
              _buildSectionTitle('Design Descriptions (User Input)'),
              if (design.generalDescription != null &&
                  design.generalDescription!.isNotEmpty)
                _buildInfoRow(
                  'General:',
                  design.generalDescription,
                  icon: Icons.description_outlined,
                ),
              if (design.interiorDesign != null &&
                  design.interiorDesign!.isNotEmpty)
                _buildInfoRow(
                  'Interior:',
                  design.interiorDesign,
                  icon: Icons.chair_outlined,
                ),
              if (design.roomDistribution != null &&
                  design.roomDistribution!.isNotEmpty)
                _buildInfoRow(
                  'Distribution:',
                  design.roomDistribution,
                  icon: Icons.grid_view_outlined,
                ),
            ] else if (project.status == 'Office Approved - Awaiting Details' &&
                isUserOwner)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        "Design details have not been submitted yet.",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text("Add Design Details"),
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: Text(
                    "No design details available for this project yet.",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),

            if (project.office != null) ...[
              _buildSectionTitle('Implementing Office'),
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
                          (context) => OfficerProfileScreen(
                            officeId: project.office!.id,
                          ),
                    ),
                  );
                },
              ),
            ],
            if (project.user != null) ...[
              _buildSectionTitle('Project Owner'),
              _buildEntityCard(
                name: project.user!.name,
                imageUrl: project.user!.profileImage,
                typeLabel: project.user!.email,
                defaultIcon: Icons.person_outline,
              ),
            ],

            _buildSectionTitle('Project Documents'),
            _buildDocumentItem(
              'Agreement:',
              project.agreementFile,
              'agreement_file',
            ),
            _buildDocumentItem(
              'License:',
              project.licenseFile,
              'license_file',
            ), // إذا كان المستخدم يرفعه
            _buildDocumentItem(
              '2D Documents:',
              project.document2D,
              'document_2d',
            ),
            _buildDocumentItem(
              '3D Model/Renders:',
              project.document3D,
              'document_3d',
            ),

            // === أقسام خاصة بالمكتب ===
            if (isAssignedOffice) ...[
              _buildOfficePaymentSection(project),
              _buildOfficeProgressSection(project),
              _buildOfficeDocumentUploadSection(project),
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
      // FloatingActionButton يمكن إضافته هنا لأفعال سريعة
    );
  }

  // === ويدجتس فرعية للأقسام الخاصة بالمكتب ===
  Widget _buildOfficePaymentSection(ProjectModel project) {
    const SizedBoxtiny = SizedBox(height: 8);
    //  يعرض فقط إذا كانت الحالة تسمح بذلك (مثلاً، بعد أن يرسل المستخدم التفاصيل)
    final bool canProposePayment =
        project.status == 'Details Submitted - Pending Office Review' ||
        project.status == 'Awaiting Payment Proposal by Office';
    final bool paymentAlreadyProposed =
        project.proposedPaymentAmount != null &&
        (project.status == 'Payment Proposal Sent' ||
            project.status == 'Awaiting User Payment');

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
              'Payment Notes:',
              project.paymentNotes,
              icon: Icons.notes_rounded,
            ),
          _buildInfoRow(
            'Payment Status:',
            project.paymentStatus ?? 'Pending User Action',
            icon: Icons.credit_card_outlined,
          ),
          const SizedBox(height: 10),
          Text(
            "Payment proposal has been sent to the user.",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.green.shade700,
            ),
          ),
        ] else if (canProposePayment) ...[
          TextFormField(
            controller: _paymentAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Proposed Payment Amount (JOD)',
              prefixText: '${currencyFormat.currencySymbol} ',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Amount is required';
              if (double.tryParse(value) == null || double.parse(value) <= 0) {
                return 'Enter a valid positive amount';
              }
              return null;
            },
          ),
          SizedBoxtiny,
          TextFormField(
            controller: _paymentNotesController,
            decoration: const InputDecoration(
              labelText: 'Payment Notes (Optional)',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
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
                      : const Icon(Icons.send_outlined, size: 18),
              label: Text(
                _isOfficeProposingPayment
                    ? 'Sending...'
                    : 'Send Payment Proposal',
              ),
              onPressed:
                  _isOfficeProposingPayment ? null : _handleProposePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOfficeProgressSection(ProjectModel project) {
    //  يعرض فقط إذا كان المشروع في مراحل معينة (مثلاً، بعد الدفع وبدء العمل)
    final bool canUpdateProgress = [
      'In Progress',
      'Details Submitted - Pending Office Review',
      'Awaiting User Payment',
      'Payment Proposal Sent',
    ].contains(project.status);
    if (!canUpdateProgress && project.status != 'Completed')
      return const SizedBox.shrink();

    int currentStage = project.progressStage ?? 0;
    // التأكد من أن currentStage ضمن الحدود
    if (currentStage < 0) currentStage = 0;
    if (currentStage >= _progressStageLabels.length)
      currentStage = _progressStageLabels.length - 1;

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
              avatar: Icon(Icons.check_circle, color: Colors.white),
            ),
          )
        else ...[
          Slider(
            value: currentStage.toDouble(),
            min: 0,
            max: (_progressStageLabels.length - 1).toDouble(),
            divisions: _progressStageLabels.length - 1,
            label: _progressStageLabels[currentStage],
            activeColor: AppColors.accent,
            inactiveColor: AppColors.primary.withOpacity(0.3),
            onChanged:
                _isOfficeUpdatingProgress
                    ? null
                    : (double value) {
                      // لا نحدث الـ state هنا مباشرة، بل عند الضغط على زر
                    },
            onChangeEnd: (double value) {
              //  يُستدعى عند انتهاء المستخدم من السحب
              _handleUpdateProgress(value.toInt());
            },
          ),
          Center(
            child: Text(
              'Current Stage: ${_progressStageLabels[currentStage]} (${((currentStage / (_progressStageLabels.length - 1)) * 100).toStringAsFixed(0)}%)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          if (_isOfficeUpdatingProgress)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: LinearProgressIndicator()),
            ),
        ],
      ],
    );
  }

  Widget _buildOfficeDocumentUploadSection(ProjectModel project) {
    //  يسمح بالرفع إذا كان المكتب هو المنفذ والمشروع في حالة مناسبة
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
        _buildSectionTitle('Upload Design Documents (Office)'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.file_upload_outlined, size: 18),
              label: const Text('Upload 2D'),
              onPressed:
                  _isOfficeUploadingDoc
                      ? null
                      : () => _handleUploadDocument('document_2d'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.file_upload_outlined, size: 18),
              label: const Text('Upload 3D'),
              onPressed:
                  _isOfficeUploadingDoc
                      ? null
                      : () => _handleUploadDocument('document_3d'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        if (_isOfficeUploadingDoc)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: LinearProgressIndicator()),
          ),
      ],
    );
  }

  // === ويدجتس فرعية للأقسام الخاصة بالمستخدم ===
  Widget _buildUserPaymentActionSection(ProjectModel project) {
    //  يعرض فقط إذا كان المستخدم هو المالك وحالة المشروع تتطلب الدفع
    final bool canMakePayment =
        (project.status == 'Payment Proposal Sent' ||
            project.status == 'Awaiting User Payment') &&
        project.proposedPaymentAmount != null;
    if (!canMakePayment) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Payment Required'),
          _buildInfoRow(
            'Amount Due:',
            currencyFormat.format(project.proposedPaymentAmount!),
            icon: Icons.payment_rounded,
          ),
          if (project.paymentNotes != null && project.paymentNotes!.isNotEmpty)
            _buildInfoRow(
              'Office Notes:',
              project.paymentNotes,
              icon: Icons.speaker_notes_outlined,
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.credit_card_rounded, size: 20),
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
          ),
        ],
      ),
    );
  }

  Widget _buildUser3DViewSection(ProjectModel project) {
    //  يعرض فقط إذا كان المستخدم هو المالك وهناك ملف 3D
    if (project.document3D == null || project.document3D!.isEmpty)
      return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.threed_rotation_rounded, size: 20),
          label: const Text(
            'View 3D Model (External)',
            style: TextStyle(fontSize: 15),
          ),
          onPressed: _handleView3D,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.accent),
            foregroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // لعرض روابط المستندات
  Widget _buildDocumentItem(
    String label,
    String? filePath,
    String documentKey,
  ) {
    if (filePath == null || filePath.isEmpty) {
      //  إذا كان المكتب هو الذي يشاهد، يمكنه رفع الملف إذا لم يكن موجوداً
      if (_sessionUserType?.toLowerCase() == 'office' &&
          _project?.officeId == _currentUser?.id) {
        final bool canUploadDoc = [
          'In Progress',
          'Details Submitted - Pending Office Review',
          'Awaiting User Payment',
          'Payment Proposal Sent',
        ].contains(_project?.status ?? '');
        if (canUploadDoc &&
            (documentKey == 'document_2d' ||
                documentKey == 'document_3d' ||
                documentKey ==
                    'license_file' /* أو agreement_file إذا المكتب يرفعه*/ )) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Icon(
                  Icons.attach_file_outlined,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 10),
                Text(
                  '$label:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed:
                      _isOfficeUploadingDoc
                          ? null
                          : () => _handleUploadDocument(documentKey),
                  child: Text(
                    'Upload $label',
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
        'Not available',
        icon: Icons.file_present_outlined,
      );
    }
    return _buildInfoRow(
      label,
      filePath,
      icon: Icons.insert_drive_file_outlined,
      isLink: true,
      onLinkTap: () {
        // TODO: Implement actual file opening/downloading logic
        //  مؤقتاً، يمكن طباعة الـ URL الكامل إذا كان filePath هو مسار نسبي
        String fullUrl =
            filePath.startsWith('http')
                ? filePath
                : '${Constants.baseUrl}/$filePath';
        logger.i("Attempting to open document: $fullUrl");
        // await launchUrl(Uri.parse(fullUrl)); // يتطلب url_launcher package
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Link to: $fullUrl (Open link not implemented)"),
          ),
        );
      },
    );
  }
}
