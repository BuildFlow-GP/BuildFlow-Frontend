// // screens/project_details_view_screen.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../services/create/project_service.dart';
// // import '../../services/create/user_update_service.dart'; //  للحصول على معلومات المستخدم الحالي
// import '../../services/session.dart';      //  للحصول على UserType و UserId
// import '../../models/Basic/project_model.dart';
// // import '../../models/create/project_design_model.dart';
// import '../../models/Basic/user_model.dart'; //  موديل المستخدم
// import '../../themes/app_colors.dart';
// // import '../../utils/constants.dart';

// // استيراد الشاشات التي سيتم الانتقال إليها
// import 'project_description.dart'; //  شاشة تعديل وصف التصميم
// // import 'payment_screen.dart'; //  شاشة الدفع (ستنشئينها لاحقاً)
// // import 'planner_5d_viewer_screen.dart'; // شاشة عرض 3D (لاحقاً)

// class ProjectDetailsViewScreen extends StatefulWidget {
//   final int projectId;
//   const ProjectDetailsViewScreen({super.key, required this.projectId});

//   @override
//   State<ProjectDetailsViewScreen> createState() => _ProjectDetailsViewScreenState();
// }

// class _ProjectDetailsViewScreenState extends State<ProjectDetailsViewScreen> {
//   final ProjectService _projectService = ProjectService();
//   // final UserService _userService = UserService(); //  قد لا نحتاجه إذا كان ProjectModel.user كافياً
//   ProjectModel? _project;
//   UserModel? _currentUser; //  المستخدم الحالي المسجل
//   String? _currentUserType;
//   int? _currentUserId;

//   bool _isLoading = true;
//   String? _error;

//   // لحقل اقتراح السعر من المكتب
//   final TextEditingController _paymentAmountController = TextEditingController();
//   final TextEditingController _paymentNotesController = TextEditingController();
//   bool _isProposingPayment = false;

//   // لحقل تحديث مرحلة التقدم من المكتب
//   int? _selectedProgressStage; //  (0-4 لـ 5 مراحل)
//   bool _isUpdatingProgress = false;
//   final List<String> _progressStageLabels = [ // مثال لـ 5 مراحل
//       "1. Initial Design Phase",
//       "2. Client Revisions",
//       "3. Finalizing 2D Plans",
//       "4. 3D Modeling",
//       "5. Delivery & Final Review"
//   ];


//   final dateFormat = DateFormat('dd MMM, yyyy');
//   final currencyFormatJOD = NumberFormat.currency(locale: 'ar_JO', symbol: 'د.أ', name: 'JOD');

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     if (!mounted) return;
//     setState(() => _isLoading = true);
//     try {
//       // جلب معلومات المستخدم الحالي أولاً لتحديد دوره
//       final sessionUserType = await Session.getUserType();
//       final sessionUserId = await Session.getUserId();
      
//       // يمكنكِ جلب تفاصيل المستخدم الكاملة إذا احتجتِ لأكثر من ID و Type
//       // _currentUser = await _userService.getCurrentUserDetails(); 
      
//       final projectData = await _projectService.getProjectDetails(widget.projectId);
//       if (mounted) {
//         setState(() {
//           _project = projectData as ProjectModel?;
//           _currentUserType = sessionUserType?.toLowerCase();
//           _currentUserId = sessionUserId;
//           if (_project?.proposedPaymentAmount != null) {
//               _paymentAmountController.text = _project!.proposedPaymentAmount!.toStringAsFixed(2);
//           }
//           _paymentNotesController.text = _project?.paymentNotes ?? '';
//           _selectedProgressStage = _project?.progressStage; //  تعبئة المرحلة الحالية
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() { _error = e.toString(); _isLoading = false; });
//       }
//       print("Error loading project details for view: $e");
//     }
//   }

//   // ... (دوال _buildInfoRow, _buildSectionTitle, _buildStatusChip, _buildEntityCard كما هي) ...
//   Widget _buildInfoRow(String label, String? value, {IconData? icon, bool isLink = false}) { /* ... */ }
//   Widget _buildSectionTitle(String title) { /* ... */ }
//   Widget _buildStatusChip(String? status) { /* ... */ }
//   Widget _buildEntityCard({ required String name, String? imageUrl, String? typeLabel, IconData defaultIcon = Icons.person, VoidCallback? onTap}) { /* ... */ }


//   // ================== دوال الإجراءات ==================
//   void _editDesignDetails() {
//     if (_project == null) return;
//     // الانتقال إلى شاشة تعديل وصف المشروع
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => ProjectDescriptionScreen(projectId: _project!.id)),
//     ).then((value) {
//       // بعد العودة من شاشة التعديل، قومي بتحديث البيانات إذا تم أي تغيير
//       if (value == true) { //  افترض أن شاشة التعديل ترجع true عند الحفظ
//         _loadProjectDetails();
//       }
//     });
//   }

//   void _navigateToPayment() {
//     if (_project == null || _project!.proposedPaymentAmount == null) return;
//     // TODO: انتقل إلى شاشة الدفع مع تمرير projectId و paymentAmount
//     print("Navigate to Payment Screen for project ${_project!.id}, amount: ${_project!.proposedPaymentAmount}");
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment screen integration pending.")));
//   }

//   void _view3DModel() {
//     // TODO: Implement navigation to Planner 5D or 3D viewer
//     print("View 3D Model for project ${_project!.id}");
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("3D viewer integration pending.")));
//   }

//   Future<void> _proposePayment() async {
//     if (_project == null || _isProposingPayment) return;
//     final amount = double.tryParse(_paymentAmountController.text);
//     if (amount == null || amount <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid payment amount.')));
//       return;
//     }
//     setState(() => _isProposingPayment = true);
//     try {
//       //  ✅✅✅ افترض أن لديك دالة في ProjectService:
//       //  Future<ProjectModel> proposePayment(int projectId, double amount, String? notes);
//       //  والتي تستدعي PUT /api/projects/:projectId/propose-payment
//       await _projectService.proposePayment(
//           _project!.id, 
//           amount, 
//           _paymentNotesController.text.trim().isEmpty ? null : _paymentNotesController.text.trim()
//       );
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment proposal submitted successfully!'), backgroundColor: Colors.green));
//         _loadProjectDetails(); // تحديث البيانات لإظهار المبلغ المقترح وحالة الدفع الجديدة
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit payment proposal: ${e.toString()}')));
//       }
//     } finally {
//       if (mounted) setState(() => _isProposingPayment = false);
//     }
//   }

//   Future<void> _uploadDocument(String documentType) async { // documentType: '2d', '3d'
//     if (_project == null) return;
//     //  TODO: Implement file picking logic (similar to DesignAgreementScreen)
//     //  FilePickerResult? result = await FilePicker.platform.pickFiles(...);
//     //  if (result != null) {
//     //    Uint8List fileBytes = ...;
//     //    String fileName = ...;
//     //    try {
//     //      setState(() => _isLoading = true); // أو متغير تحميل خاص بالرفع
//     //      //  ✅✅✅ افترض أن لديك دالة في ProjectService:
//     //      //  Future<String?> uploadProjectDocument(int projectId, Uint8List fileBytes, String fileName, String documentFieldKey);
//     //      //  documentFieldKey يمكن أن يكون 'document_2d' أو 'document_3d'
//     //      await _projectService.uploadProjectDocument(_project!.id, fileBytes, fileName, 'document_$documentType');
//     //      if (mounted) {
//     //        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$documentType document uploaded!')));
//     //        _loadProjectDetails(); // تحديث البيانات
//     //      }
//     //    } catch (e) { /* ... */ }
//     //    finally { setState(() => _isLoading = false); }
//     //  }
//     print("Upload $documentType Document for project ${_project!.id}");
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$documentType document upload pending implementation.")));
//   }

//   Future<void> _updateProgressStage(int newStage) async {
//     if (_project == null || _isUpdatingProgress) return;
//     setState(() => _isUpdatingProgress = true);
//     try {
//         //  ✅✅✅ افترض أن لديك دالة في ProjectService:
//         //  Future<ProjectModel> updateProjectProgress(int projectId, int stage);
//         //  والتي تستدعي PUT /api/projects/:projectId/progress
//         await _projectService.updateProjectProgress(_project!.id, newStage);
//          if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project progress updated!'), backgroundColor: Colors.green));
//             _loadProjectDetails(); // تحديث البيانات
//         }
//     } catch (e) {
//         if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update progress: ${e.toString()}')));
//         }
//     } finally {
//         if (mounted) setState(() => _isUpdatingProgress = false);
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_project?.name ?? (_isLoading ? 'Loading...' : 'Project Details')),
//         elevation: 1,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _error != null
//               ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: $_error', style: const TextStyle(color: Colors.red))))
//               : _project == null
//                   ? const Center(child: Text('Project data not found.'))
//                   : _buildProjectContentView(),
//     );
//   }

//   Widget _buildProjectContentView() {
//     final project = _project!;
//     final design = project.projectDesign;
    
//     // تحديد إذا كان المستخدم الحالي هو مالك المشروع أو المكتب المنفذ
//     final bool isUserOwner = _currentUserId == project.userId && _currentUserType == 'individual'; // أو 'user'
//     final bool isAssignedOffice = _currentUserId == project.officeId && _currentUserType == 'office';

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // === عرض حالة المشروع واسمه ===
//           Row( /* ... (نفس كود عرض الاسم والحالة من الرد السابق) ... */),
//           if (project.description.isNotEmpty) /* ... (نفس كود عرض الوصف) ... */ else const SizedBox(height: 16),

//           // ======================== أزرار الإجراءات لليوزر ========================
//           if (isUserOwner) ...[
//             _buildSectionTitle('My Actions'),
//             // زر تعديل وصف المشروع (ينتقل لـ ProjectDescriptionScreen)
//             //  يجب أن يكون متاحاً فقط إذا كانت حالة المشروع تسمح بذلك
//             if (project.status == 'Office Approved - Awaiting Details' || 
//                 project.status == 'Details Submitted - Pending Office Review' /* أو حالات أخرى تسمح بالتعديل */ ) 
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4.0),
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.edit_note_outlined),
//                   label: const Text('Edit Design Details'),
//                   onPressed: _editDesignDetails,
//                   style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
//                 ),
//               ),
            
//             // زر الدفع (يظهر فقط إذا كان هناك مبلغ مقترح وحالة الدفع Pending)
//             if (project.proposedPaymentAmount != null && project.proposedPaymentAmount! > 0 &&
//                 (project.paymentStatus == 'Pending' || project.paymentStatus == null /* أو حالة أولية */) )
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4.0),
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.payment_outlined),
//                   label: Text('Pay Now (${currencyFormatJOD.format(project.proposedPaymentAmount)})'),
//                   onPressed: _navigateToPayment,
//                   style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 40)),
//                 ),
//               ),

//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 4.0),
//               child: OutlinedButton.icon(
//                 icon: const Icon(Icons.threed_rotation_outlined),
//                 label: const Text('View 3D Model (Soon)'),
//                 onPressed: _view3DModel,
//                 style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
//               ),
//             ),
//             const Divider(height: 24),
//           ],

//           // ======================== أقسام وإجراءات المكتب ========================
//           if (isAssignedOffice) ...[
//             _buildSectionTitle('Office Actions'),
//             // قسم اقتراح السعر (يظهر إذا لم يتم اقتراح سعر بعد أو إذا كانت الحالة تسمح)
//             if (project.status == 'Details Submitted - Pending Office Review' || 
//                 project.status == 'Awaiting Payment Proposal by Office' /* أو ما شابه */) 
//               _buildProposePaymentSection(),
            
//             // قسم رفع ملفات 2D/3D (يظهر في حالات معينة)
//             if (project.status == 'In Progress' /* أو حالات أخرى مناسبة */) ...[
//                  Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4.0),
//                     child: OutlinedButton.icon(
//                         icon: const Icon(Icons.upload_file_outlined),
//                         label: const Text('Upload 2D Documents'),
//                         onPressed: () => _uploadDocument('2d'),
//                         style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
//                     ),
//                  ),
//                  Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4.0),
//                     child: OutlinedButton.icon(
//                         icon: const Icon(Icons.threed_rotation_sharp),
//                         label: const Text('Upload 3D Model/Renders'),
//                         onPressed: () => _uploadDocument('3d'),
//                         style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
//                     ),
//                  ),
//             ],
//             const Divider(height: 24),
//           ],

//           // ======================== عرض تقدم المشروع (لليوزر والمكتب) ========================
//           _buildSectionTitle('Project Progress'),
//           _buildProgressTracker(project.progressStage ?? 0, isAssignedOffice),
//           const Divider(height: 30, thickness: 1),


//           // ======================== باقي تفاصيل المشروع (عامة) ========================
//           _buildSectionTitle('Key Information'),
//           // ... (نفس كود عرض _buildInfoRow لمعلومات المشروع الأساسية وتفاصيل الأرض من الرد السابق)
//           // ... (مع التأكد من استخدام project.fieldName)
//            _buildInfoRow('Budget (User Estimate):', project.budget != null ? currencyFormatJOD.format(project.budget) : 'N/A', icon: Icons.request_quote_outlined),
//            _buildInfoRow('Start Date:', project.startDate != null ? dateFormat.format(project.startDate!) : 'N/A', icon: Icons.calendar_today_outlined),
//            _buildInfoRow('Expected End Date:', project.endDate != null ? dateFormat.format(project.endDate!) : 'N/A', icon: Icons.event_available_outlined),
//            _buildInfoRow('Location:', project.location.isNotEmpty ? project.location : 'N/A', icon: Icons.location_on_outlined),
//            _buildInfoRow('Created On:', dateFormat.format(project.createdAt.toLocal()), icon: Icons.history_toggle_off_outlined),

//           if (project.landArea != null || project.plotNumber.isNotEmpty) ...[
//             _buildSectionTitle('Land Details'),
//             _buildInfoRow('Land Area:', project.landArea != null ? '${project.landArea} m²' : 'N/A', icon: Icons.square_foot_outlined),
//             _buildInfoRow('Plot Number:', project.plotNumber.isNotEmpty ? project.plotNumber : 'N/A', icon: Icons.map_outlined),
//             _buildInfoRow('Basin Number:', project.basinNumber.isNotEmpty ? project.basinNumber : 'N/A', icon: Icons.confirmation_number_outlined),
//             _buildInfoRow('Land Location Detail:', project.landLocation.isNotEmpty ? project.landLocation : 'N/A', icon: Icons.pin_drop_outlined),
//           ],


//           if (design != null) ...[
//             _buildSectionTitle('Design Specifications'),
//             // ... (نفس كود عرض تفاصيل التصميم من الرد السابق)
//             // ... (مع التأكد من استخدام design.fieldName)
//              _buildInfoRow('Floors:', design.floorCount?.toString() ?? 'N/A', icon: Icons.layers_outlined),
//             _buildInfoRow('Bedrooms:', design.bedrooms?.toString() ?? 'N/A', icon: Icons.king_bed_outlined),
//             // ... (باقي حقول التصميم)
//              if (design.budgetMin != null || design.budgetMax != null) ...[
//                 _buildSectionTitle('User Estimated Design Budget'), // تم تغيير العنوان
//                 _buildInfoRow('Min Budget:', design.budgetMin != null ? currencyFormatJOD.format(design.budgetMin) : 'N/A', icon: Icons.money_off_csred_outlined),
//                 _buildInfoRow('Max Budget:', design.budgetMax != null ? currencyFormatJOD.format(design.budgetMax) : 'N/A', icon: Icons.monetization_on_outlined),
//             ],
//             _buildSectionTitle('Design Descriptions'),
//             if (design.generalDescription != null && design.generalDescription!.isNotEmpty) _buildInfoRow('General:', design.generalDescription, icon: Icons.description_outlined),
//             // ... (باقي الأوصاف)
//           ],
//           if(design == null && (project.status == 'Office Approved - Awaiting Details' || project.status == 'Pending Office Approval') )
//             Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 20.0),
//                 child: Center(child: Text("Design details have not been submitted by the user yet.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700]))),
//             ),
          
//           // === معلومات المكتب والشركة والمالك (كما هي من الرد السابق) ===
//           if (project.office != null) /* ... */,
//           if (project.company != null) /* ... */,
//           if (project.user != null) /* ... */,

//           // === روابط المستندات (كما هي من الرد السابق) ===
//           _buildSectionTitle('Project Documents'),
//           _buildInfoRow('Agreement:', project.agreementFile, icon: Icons.insert_drive_file_outlined, isLink: true),
//           // ... (باقي المستندات)

//           const SizedBox(height: 30),
//         ],
//       ),
//     );
//   }


//   // ======== ودجتس خاصة بإجراءات المكتب ========
//   Widget _buildProposePaymentSection() {
//     return Card(
//       elevation: 2, margin: const EdgeInsets.symmetric(vertical: 8),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Propose Payment Amount", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accent)),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _paymentAmountController,
//               keyboardType: const TextInputType.numberWithOptions(decimal: true),
//               decoration: InputDecoration(
//                 labelText: 'Amount (د.أ)', // الدينار الأردني
//                 prefixText: 'د.أ ',
//                 border: const OutlineInputBorder(),
//               ),
//               validator: (value) {
//                 if (value == null || value.isEmpty) return 'Amount is required';
//                 if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Enter a valid amount';
//                 return null;
//               },
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _paymentNotesController,
//               decoration: const InputDecoration(
//                 labelText: 'Payment Notes (Optional)',
//                 border: OutlineInputBorder(),
//                 alignLabelWithHint: true,
//               ),
//               maxLines: 2,
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isProposingPayment ? null : _proposePayment,
//                 child: _isProposingPayment ? const SizedBox(height:20, width:20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,)) : const Text('Submit Proposal'),
//                 style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProgressTracker(int currentStage, bool canUpdate) {
//     // currentStage هو 0-indexed (0 لـ المرحلة 1، 1 للمرحلة 2، إلخ.)
//     // إذا كان progressStage من DB هو 1-indexed، اطرحي 1 هنا.
//     // لنفترض أن currentStage هو 0 لعدم البدء، 1 للمرحلة الأولى، وهكذا حتى 5 للانتهاء.
//     // لذا، النسبة ستكون (currentStage / 5) * 100
//     // إذا كانت المراحل 0-4، ستكون (currentStage / 4) أو ((currentStage+1)/5) إذا currentStage يبدأ من 0
//     // سأفترض أن progressStage من DB هو 0 إذا لم يبدأ، و 1 للمرحلة الأولى، وهكذا.
//     // إذا كان currentStage = 0 (لم يبدأ بعد أو لا يوجد)
//     // إذا كان _project!.progressStage هو null، نعتبره 0

//     final int stageForDisplay = currentStage; // إذا كان 0 يعني لم يبدأ، 1 للمرحلة الأولى، إلخ.
//     final double progressValue = stageForDisplay <= 0 ? 0.0 : (stageForDisplay / _progressStageLabels.length.toDouble());
//     final String progressPercentage = "${(progressValue * 100).toStringAsFixed(0)}%";

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Row(
//             children: [
//               Expanded(
//                 child: LinearProgressIndicator(
//                   value: progressValue,
//                   backgroundColor: Colors.grey[300],
//                   valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
//                   minHeight: 10, //  جعل الشريط أسمك قليلاً
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(progressPercentage, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//             ],
//           ),
//         ),
//         if (stageForDisplay > 0 && stageForDisplay <= _progressStageLabels.length)
//           Text(
//             "Current Stage: ${_progressStageLabels[stageForDisplay - 1]}", //  -1 لأن القائمة 0-indexed
//              style: TextStyle(fontSize: 13, color: Colors.grey[700], fontStyle: FontStyle.italic),
//           )
//         else if (stageForDisplay == 0)
//              Text(
//                 "Project progress has not started yet.",
//                  style: TextStyle(fontSize: 13, color: Colors.grey[700], fontStyle: FontStyle.italic),
//             ),

//         if (canUpdate) ...[ //  أزرار للمكتب لتحديث التقدم
//           const SizedBox(height: 12),
//           Wrap( //  لعرض الأزرار بشكل جيد
//             spacing: 8.0,
//             runSpacing: 4.0,
//             children: List.generate(_progressStageLabels.length, (index) {
//               final stageNumber = index + 1; //  المراحل من 1 إلى 5
//               return ElevatedButton(
//                 onPressed: (_isUpdatingProgress || stageForDisplay == stageNumber) ? null : () => _updateProgressStage(stageNumber),
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: stageForDisplay == stageNumber ? AppColors.accent : Colors.grey.shade200,
//                     foregroundColor: stageForDisplay == stageNumber ? Colors.white : AppColors.textPrimary,
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                     textStyle: const TextStyle(fontSize: 12)
//                 ),
//                 child: Text(_progressStageLabels[index].split('.').last.trim()), //  عرض اسم المرحلة فقط
//               );
//             }),
//           ),
//           if (_isUpdatingProgress) const Padding(padding: EdgeInsets.only(top:8), child: Center(child: SizedBox(width:16, height:16, child: CircularProgressIndicator(strokeWidth: 2)))),
//         ]
//       ],
//     );
//   }

// } // نهاية الكلاس

// // دوال بناء الحقول و _CustomAppBar تبقى كما هي من الردود السابقة
// // تأكدي من أن AppStrings تحتوي على 'currencySymbol' إذا استخدمتيه في _buildBudgetRangeFields