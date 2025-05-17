import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class OfficeProfileScreen extends StatefulWidget {
  final bool isOwner;
  const OfficeProfileScreen({required this.isOwner, super.key});

  @override
  State<OfficeProfileScreen> createState() => _OfficeProfileScreenState();
}

class _OfficeProfileScreenState extends State<OfficeProfileScreen> {
  bool isEditMode = false;
  File? _profileImage;
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final Map<String, dynamic> formData = {
    "name": "Office One",
    "email": "office@example.com",
    "phone": "01012345678",
    "location": "Cairo",
    "capacity": "50",
    "rating": "4.5",
    "is_available": true,
    "points": "100",
    "bank_account": "123-456-789",
    "staff_count": "15",
    "active_projects_count": "3",
    "branches": "Giza, Alexandria",
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
      appBar: AppBar(title: const Text("Office Profile")),
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
                          : const AssetImage("assets/office.png")
                              as ImageProvider,
                ),
              ),
              const SizedBox(height: 16),
              _buildField("Name", "name"),
              _buildField("Email", "email"),
              _buildField("Phone", "phone"),
              _buildField("Location", "location"),
              _buildField("Capacity", "capacity"),
              _buildField("Rating", "rating"),
              _buildField("Points", "points"),
              _buildField("Bank Account", "bank_account"),
              _buildField("Staff Count", "staff_count"),
              _buildField("Active Projects", "active_projects_count"),
              _buildField("Branches", "branches"),
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
