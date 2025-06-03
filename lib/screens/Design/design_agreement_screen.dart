import 'package:buildflow_frontend/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'app_strings.dart';
import 'project_description.dart'; // فرضًا لديك نصوص هنا

final Logger logger = Logger();

class DesignAgreementScreen extends StatefulWidget {
  const DesignAgreementScreen({super.key});

  @override
  State<DesignAgreementScreen> createState() => _DesignAgreementScreenState();
}

class _DesignAgreementScreenState extends State<DesignAgreementScreen> {
  final Map<String, TextEditingController> _controllers = {};
  String? _pdfFilePath;
  bool _isSubmitting = false;
  bool _isUploading = false;

  int _currentStep = 0; // لتعقب الخطوة الحالية

  @override
  void initState() {
    super.initState();
    _initControllers();
    for (var controller in _controllers.values) {
      controller.addListener(() {
        setState(() {}); // تحديث الحالة لتغيير لون الزر بناءً على الإدخال
      });
    }
  }

  void _initControllers() {
    _controllers['name'] = TextEditingController();
    _controllers['idNumber'] = TextEditingController();
    _controllers['address'] = TextEditingController();
    _controllers['phone'] = TextEditingController();
    _controllers['bankAccount'] = TextEditingController();
    _controllers['area'] = TextEditingController();
    _controllers['plotNumber'] = TextEditingController();
    _controllers['basinNumber'] = TextEditingController();
    _controllers['areaName'] = TextEditingController();
  }

  bool get _isFormValid {
    // تحقق من صلاحية الحقول بحسب الخطوة
    switch (_currentStep) {
      case 0:
        return _controllers['name']!.text.isNotEmpty &&
            _controllers['idNumber']!.text.isNotEmpty &&
            _controllers['address']!.text.isNotEmpty &&
            _controllers['phone']!.text.isNotEmpty &&
            _controllers['bankAccount']!.text.isNotEmpty;
      case 1:
        return _controllers['area']!.text.isNotEmpty &&
            _controllers['plotNumber']!.text.isNotEmpty &&
            _controllers['basinNumber']!.text.isNotEmpty &&
            _controllers['areaName']!.text.isNotEmpty;
      case 2:
        return _pdfFilePath != null;
      default:
        return false;
    }
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        if (result.files.single.size > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File size should be less than 5MB')),
          );
          return;
        }

        setState(() {
          _isUploading = true;
        });
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _isUploading = false;
          _pdfFilePath = result.files.single.path;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF Uploaded: ${result.files.single.name}')),
        );
      }
    } catch (e) {
      logger.e("Error picking file: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to pick file')));
    }
  }

  Future<void> _submitForm() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and upload PDF')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      logger.i("Submitting form...");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProjectDetailsScreen()),
      );
    });

    try {
      // محاكاة طلب الشبكة
      await Future.delayed(const Duration(seconds: 2));

      logger.i(
        "Form submitted: ${_controllers.map((key, value) => MapEntry(key, value.text))}",
      );
      logger.i("PDF File Path: $_pdfFilePath");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Information Submitted!')));
    } catch (e) {
      logger.e("Submission error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission failed, please try again')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _nextStep() {
    if (_isFormValid) {
      if (_currentStep < 2) {
        setState(() {
          _currentStep++;
        });
      } else {
        _submitForm();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _buildStepProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isActive = index == _currentStep;
        bool isCompleted = index < _currentStep;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            height: 8,
            decoration: BoxDecoration(
              color:
                  isCompleted
                      ? AppColors.accent
                      : isActive
                      ? AppColors.primary
                      : AppColors.card,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildUserInfoSection();
      case 1:
        return _buildLandInfoSection();
      case 2:
        return _buildSupportingDocsSection();
      default:
        return Container();
    }
  }

  Widget _buildUserInfoSection() {
    return _buildSectionCard(
      title: AppStrings.userInfo,
      color: AppColors.accent,
      children: [
        _buildResponsiveRow([
          _buildField(_controllers['name']!, AppStrings.name),
          _buildField(_controllers['idNumber']!, AppStrings.idNumber),
        ]),
        const SizedBox(height: 12),
        _buildResponsiveRow([
          _buildField(_controllers['address']!, AppStrings.address),
          _buildField(_controllers['phone']!, AppStrings.phone),
        ]),
        const SizedBox(height: 12),
        _buildResponsiveRow([
          _buildField(_controllers['bankAccount']!, AppStrings.bankAccount),
        ]),
      ],
    );
  }

  Widget _buildLandInfoSection() {
    return _buildSectionCard(
      title: AppStrings.landInfo,
      color: AppColors.accent,
      children: [
        _buildField(
          _controllers['area']!,
          AppStrings.area,
          keyboardType: TextInputType.number,
        ),
        Row(
          children: [
            Expanded(
              child: _buildField(
                _controllers['plotNumber']!,
                AppStrings.plotNumber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildField(
                _controllers['basinNumber']!,
                AppStrings.basinNumber,
              ),
            ),
          ],
        ),
        _buildField(_controllers['areaName']!, AppStrings.areaName),
      ],
    );
  }

  Widget _buildSupportingDocsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      shadowColor: Colors.grey.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppStrings.supportingDocs,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent, // لون مخصص للزر
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black45,
                ),
                onPressed: _isUploading || _isSubmitting ? null : _pickPDF,
                icon:
                    _isUploading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(
                          Icons.attach_file,
                          color: Colors.white,
                          size: 22,
                        ),
                label: Text(
                  _isUploading ? 'Uploading...' : AppStrings.uploadPdf,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Text(
                'Please upload a PDF file no larger than 5MB. Make sure the file is clear and legible.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            if (_pdfFilePath != null) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Uploaded file: ${_pdfFilePath!.split('/').last}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.redAccent,
                    ),
                    tooltip: 'Cancel',
                    onPressed:
                        _isSubmitting || _isUploading
                            ? null
                            : () {
                              setState(() {
                                _pdfFilePath = null;
                              });
                            },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            const _CustomAppBar(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildStepProgressIndicator(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildStepContent(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(120, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        _currentStep > 0 && !_isSubmitting
                            ? _previousStep
                            : null,
                    child: const Text('Back'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          (_isFormValid)
                              ? AppColors.accent
                              : AppColors.primary.withOpacity(0.5),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(120, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _nextStep,
                    child:
                        _isSubmitting
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                            : Text(_currentStep == 2 ? 'Submit' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      color: AppColors.card,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: AppColors.shadow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: AppColors.background,
        ),
      ),
    );
  }

  Widget _buildResponsiveRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Row(
            children:
                children
                    .map(
                      (child) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: child,
                        ),
                      ),
                    )
                    .toList(),
          );
        } else {
          return Column(children: children);
        }
      },
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  const _CustomAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 28),
            color: AppColors.accent,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              "Pre-Submission Requirements",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
