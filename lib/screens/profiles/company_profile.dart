import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/Profiles/company_profile_service.dart';

class CompanyProfileScreen extends StatefulWidget {
  final bool isOwner;
  const CompanyProfileScreen({
    required this.isOwner,
    super.key,
    required int companyId,
  });

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  bool isEditMode = false;
  File? _profileImage;
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  Map<String, dynamic> formData = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await CompanyService.fetchProfile();
    if (data != null) setState(() => formData = data);
  }

  void _toggleEdit() async {
    if (isEditMode && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      bool success = await CompanyService.updateProfile(formData);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
    setState(() => isEditMode = !isEditMode);
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _profileImage = File(picked.path));
  }

  Widget _buildField(String label, String field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        isEditMode
            ? TextFormField(
              initialValue: formData[field]?.toString() ?? '',
              onSaved: (val) => formData[field] = val,
            )
            : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(formData[field]?.toString() ?? ''),
            ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Company Profile")),
      body:
          formData.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: isEditMode ? _pickImage : null,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : const AssetImage("assets/company.png")
                                      as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildField("Name", "name"),
                      _buildField("Email", "email"),
                      _buildField("Phone", "phone"),
                      _buildField("Description", "description"),
                      _buildField("Rating", "rating"),
                      _buildField("Company Type", "company_type"),
                      _buildField("Location", "location"),
                      _buildField("Bank Account", "bank_account"),
                      _buildField("Staff Count", "staff_count"),
                      const SizedBox(height: 10),
                      if (widget.isOwner)
                        ElevatedButton(
                          onPressed: _toggleEdit,
                          child: Text(isEditMode ? "Save" : "Edit"),
                        ),
                    ],
                  ),
                ),
              ),
    );
  }
}
