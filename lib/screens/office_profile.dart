// screens/office_profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/office.dart';
import '../services/api_service.dart';

class OfficeProfilePage extends StatefulWidget {
  final Office office;

  const OfficeProfilePage({Key? key, required this.office}) : super(key: key);

  @override
  _OfficeProfilePageState createState() => _OfficeProfilePageState();
}

class _OfficeProfilePageState extends State<OfficeProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController locationController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.office.name);
    emailController = TextEditingController(text: widget.office.email);
    phoneController = TextEditingController(text: widget.office.phone);
    locationController = TextEditingController(text: widget.office.location);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    ); // or ImageSource.camera

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    // Update the office object with new values
    widget.office.name = nameController.text;
    widget.office.email = emailController.text;
    widget.office.phone = phoneController.text;
    widget.office.location = locationController.text;

    // Call API to update office profile
    await ApiService.updateOfficeProfile(widget.office, _imageFile);
    // Handle response and show confirmation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Office Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    _imageFile != null
                        ? FileImage(_imageFile!)
                        : (widget.office.profileImage != null
                                ? NetworkImage(widget.office.profileImage!)
                                : AssetImage('assets/default_profile.png'))
                            as ImageProvider,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Office Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
