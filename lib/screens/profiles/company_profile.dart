import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CompanyProfileScreen extends StatefulWidget {
  final bool isOwner;
  const CompanyProfileScreen({required this.isOwner, super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  bool isEditMode = false;
  File? _profileImage;
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final Map<String, dynamic> formData = {
    "name": "BuildTech Ltd.",
    "email": "info@buildtech.com",
    "phone": "01234567890",
    "description": "We build the future.",
    "rating": "4.8",
    "company_type": "Construction",
    "location": "Dubai",
    "bank_account": "9876543210",
    "staff_count": "120",
  };

  void _toggleEdit() {
    if (isEditMode && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // TODO: Send PUT/PATCH request to backend
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
              initialValue: formData[field].toString(),
              onSaved: (val) => formData[field] = val,
            )
            : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(formData[field].toString()),
            ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Company Profile")),
      body: SingleChildScrollView(
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
