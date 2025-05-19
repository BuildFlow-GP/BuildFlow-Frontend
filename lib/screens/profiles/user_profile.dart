import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfileScreen extends StatefulWidget {
  final bool isOwner; // true if this is the logged-in user's profile

  const UserProfileScreen({required this.isOwner, super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isEditMode = false;

  File? _profileImage;
  final _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "123456789",
    "id_number": "12345678",
    "bank_account": "123-456",
    "location": "Cairo, Egypt",
  };

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  void _toggleEdit() {
    if (isEditMode && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // TODO: send PUT/PATCH request here
    }
    setState(() => isEditMode = !isEditMode);
  }

  Widget _buildField(String label, String fieldName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        isEditMode
            ? TextFormField(
              initialValue: formData[fieldName],
              onSaved: (val) => formData[fieldName] = val,
            )
            : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(formData[fieldName] ?? "-"),
            ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
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
                          : const AssetImage('assets/user.png')
                              as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              _buildField("Name", "name"),
              _buildField("Email", "email"),
              _buildField("Phone", "phone"),
              _buildField("ID Number", "id_number"),
              _buildField("Bank Account", "bank_account"),
              _buildField("Location", "location"),
              const SizedBox(height: 20),
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
