import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/user_service.dart';

class UserProfileScreen extends StatefulWidget {
  final bool isOwner;
  const UserProfileScreen({required this.isOwner, super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isEditMode = false;
  File? _profileImage;
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> formData = {};
  String? _password;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await UserService.getUserProfile();
    if (data != null) {
      setState(() => formData = data);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  void _toggleEdit() async {
    if (isEditMode && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // أضف كلمة المرور إذا تم ملؤها
      if (_password != null && _password!.trim().isNotEmpty) {
        formData['password'] = _password;
      }

      final success = await UserService.updateUserProfile(formData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Profile updated successfully"
                : "Failed to update profile",
          ),
        ),
      );
    }

    setState(() {
      isEditMode = !isEditMode;
      if (!isEditMode) _password = null;
    });
  }

  Widget _buildField(String label, String fieldName, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          isEditMode && !readOnly
              ? TextFormField(
                initialValue: formData[fieldName]?.toString(),
                onSaved: (val) => formData[fieldName] = val,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              )
              : Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  formData[fieldName]?.toString() ?? "-",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Password",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter new password",
            ),
            onSaved: (val) => _password = val,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body:
          formData.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: isEditMode ? _pickImage : null,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : const AssetImage('assets/user.png')
                                          as ImageProvider,
                            ),
                          ),
                          const SizedBox(height: 20),

                          _buildField("Name", "name"),
                          _buildField("Email", "email", readOnly: true),
                          _buildField("Phone", "phone"),
                          _buildField("ID Number", "id_number"),
                          _buildField("Bank Account", "bank_account"),
                          _buildField("Location", "location"),

                          if (isEditMode) _buildPasswordField(),

                          const SizedBox(height: 20),
                          if (widget.isOwner)
                            ElevatedButton.icon(
                              onPressed: _toggleEdit,
                              icon: Icon(isEditMode ? Icons.save : Icons.edit),
                              label: Text(
                                isEditMode ? "Save Changes" : "Edit Profile",
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
