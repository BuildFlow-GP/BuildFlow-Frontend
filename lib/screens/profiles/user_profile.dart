import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/Profiles/user_profile_service.dart';
import '../../themes/app_colors.dart';
import '../../widgets/navbar.dart';

class UserProfileScreen extends StatefulWidget {
  final bool isOwner;
  const UserProfileScreen({required this.isOwner, super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  bool isEditMode = false;
  bool isLoading = false;
  bool isSaving = false;
  File? _profileImage;
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> formData = {};
  Map<String, dynamic> _originalData = {}; // لحفظ البيانات الأصلية
  File? _originalImage; // لحفظ الصورة الأصلية
  String? _password;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  static const double _breakpoint = 600.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);

    try {
      final data = await UserService.getUserProfile();
      if (data != null) {
        setState(() {
          formData = data;
          _originalData = Map.from(data); // حفظ نسخة من البيانات الأصلية
          isLoading = false;
        });
        _fadeController.forward();
        _scaleController.forward();
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar('Failed to load profile data');
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        await _showImagePreview(imageFile);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _showImagePreview(File imageFile) async {
    await showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 4,
                          child: Image.file(
                            imageFile,
                            fit: BoxFit.contain,
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.6,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _profileImage = imageFile);
                        Navigator.pop(context);
                        _showSuccessSnackBar('Profile image updated');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _toggleEdit() {
    if (!isEditMode) {
      // عند الدخول في وضع التعديل، حفظ نسخة من البيانات الحالية
      _originalData = Map.from(formData);
      _originalImage = _profileImage;
    }
    setState(() => isEditMode = !isEditMode);
  }

  void _cancelEdits() {
    setState(() {
      formData = Map.from(_originalData); // استعادة البيانات الأصلية
      _profileImage = _originalImage; // استعادة الصورة الأصلية
      _password = null; // مسح كلمة المرور
      isEditMode = false; // الخروج من وضع التعديل
    });
    _showSuccessSnackBar('Changes discarded');
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSaving = true);
      _formKey.currentState!.save();

      // أضف كلمة المرور إذا تم ملؤها
      if (_password != null && _password!.trim().isNotEmpty) {
        formData['password'] = _password;
      }

      try {
        final success = await UserService.updateUserProfile(formData);

        if (success) {
          // عند الحفظ الناجح، تحديث البيانات الأصلية
          _originalData = Map.from(formData);
          _originalImage = _profileImage;
          _showSuccessSnackBar("Profile updated successfully");
        } else {
          _showErrorSnackBar("Failed to update profile");
        }
      } catch (e) {
        _showErrorSnackBar("An error occurred while updating profile");
      } finally {
        setState(() {
          isSaving = false;
          isEditMode = false;
          _password = null;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundImage:
                            _profileImage != null
                                ? FileImage(_profileImage!)
                                : const AssetImage('assets/user.png')
                                    as ImageProvider,
                      ),
                    ),
                  ),
                  if (isEditMode)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                formData['name']?.toString() ?? 'User Name',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  formData['email']?.toString() ?? 'user@email.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String fieldName, {
    bool readOnly = false,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required double itemWidth,
  }) {
    return Container(
      width: itemWidth,
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          isEditMode && !readOnly
              ? TextFormField(
                initialValue: formData[fieldName]?.toString(),
                onSaved: (val) => formData[fieldName] = val,
                keyboardType: keyboardType,
                validator: validator,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              )
              : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  formData[fieldName]?.toString() ?? "-",
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({required double itemWidth}) {
    return Container(
      width: itemWidth,
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.accent, size: 20),
              SizedBox(width: 8),
              Text(
                "New Password",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.background,
              hintText: "Enter new password (optional)",
              hintStyle: TextStyle(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.accent, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            onSaved: (val) => _password = val,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double width) {
    if (!widget.isOwner) return const SizedBox.shrink();

    return SizedBox(
      width: width,
      child: Row(
        children: [
          if (isEditMode) ...[
            // زر الإلغاء
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isSaving ? null : _cancelEdits,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text("Cancel"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: AppColors.error),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          // زر الحفظ/التعديل
          // يجب أن يكون ElevatedButton.icon نفسه هو الذي يمتلك خاصية style
          // وليس الـ Text widget بداخله.
          Expanded(
            child: ElevatedButton.icon(
              onPressed:
                  isSaving
                      ? null
                      : _toggleEdit, // يمكنك تبسيط هذا لـ _toggleEdit إذا كانت هي التي تعالج الحفظ والتعديل
              icon:
                  isSaving
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Icon(isEditMode ? Icons.save : Icons.edit),
              label: Text(
                isSaving
                    ? "Saving..."
                    : (isEditMode ? "Save Changes" : "Edit Profile"),
                // هنا تضع فقط style الخاص بالنص (مثل الحجم والوزن)
                // اللون الأمامي للنص سيتم تحديده من خلال foregroundColor في ElevatedButton.styleFrom
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // هنا تضع style الخاص بالزر بالكامل
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isEditMode ? AppColors.success : AppColors.accent,
                foregroundColor:
                    Colors.white, // هذا سيتحكم في لون الأيقونة والنص داخل الزر
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                shadowColor: (isEditMode ? AppColors.success : AppColors.accent)
                    .withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const Navbar(),
          Expanded(
            child:
                isLoading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading profile...',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildProfileHeader(),
                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 700,
                                ),
                                margin: const EdgeInsets.all(20),
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadow.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final bool isWideScreen =
                                          constraints.maxWidth > _breakpoint;
                                      final double spacing = 20.0;
                                      final double itemWidth =
                                          isWideScreen
                                              ? (constraints.maxWidth -
                                                      spacing) /
                                                  2
                                              : constraints.maxWidth;

                                      return Wrap(
                                        spacing: spacing,
                                        runSpacing: 20.0,
                                        alignment: WrapAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: constraints.maxWidth,
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                bottom: 20,
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.person,
                                                      color: AppColors.accent,
                                                      size: 24,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  const Text(
                                                    "Personal Information",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          _buildField(
                                            "Full Name",
                                            "name",
                                            itemWidth: itemWidth,
                                            icon: Icons.person_outline,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return 'Name is required';
                                              }
                                              return null;
                                            },
                                          ),
                                          _buildField(
                                            "Email Address",
                                            "email",
                                            readOnly: true,
                                            itemWidth: itemWidth,
                                            icon: Icons.email_outlined,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                          ),
                                          _buildField(
                                            "Phone Number",
                                            "phone",
                                            itemWidth: itemWidth,
                                            icon: Icons.phone_outlined,
                                            keyboardType: TextInputType.phone,
                                            validator: (value) {
                                              if (value != null &&
                                                  value.isNotEmpty) {
                                                if (value.length < 10) {
                                                  return 'Please enter a valid phone number';
                                                }
                                              }
                                              return null;
                                            },
                                          ),
                                          _buildField(
                                            "ID Number",
                                            "id_number",
                                            itemWidth: itemWidth,
                                            icon: Icons.badge_outlined,
                                            keyboardType: TextInputType.number,
                                          ),
                                          _buildField(
                                            "Bank Account",
                                            "bank_account",
                                            itemWidth: itemWidth,
                                            icon:
                                                Icons.account_balance_outlined,
                                          ),
                                          _buildField(
                                            "Location",
                                            "location",
                                            itemWidth: itemWidth,
                                            icon: Icons.location_on_outlined,
                                          ),
                                          if (isEditMode)
                                            _buildPasswordField(
                                              itemWidth: itemWidth,
                                            ),
                                          SizedBox(
                                            width: constraints.maxWidth,
                                            child: _buildActionButtons(
                                              constraints.maxWidth,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
