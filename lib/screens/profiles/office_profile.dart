import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:logger/logger.dart';
import '../../services/office_service.dart';
import '../../services/review_service.dart';
import '../../services/session.dart';

class OfficeProfileScreen extends StatefulWidget {
  final bool isOwner;
  final int officeId;

  const OfficeProfileScreen({
    required this.isOwner,
    required this.officeId,
    super.key,
  });

  @override
  State<OfficeProfileScreen> createState() => _OfficeProfileScreenState();
}

class _OfficeProfileScreenState extends State<OfficeProfileScreen> {
  bool isEditMode = false;
  File? _profileImage;
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final Logger logger = Logger();

  Map<String, dynamic> formData = {};
  List<Map<String, dynamic>> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOfficeData();
    fetchReviews();
  }

  Future<void> fetchOfficeData() async {
    try {
      final token = await Session.getToken();
      final data = await OfficeService.getOffice(widget.officeId, token);
      setState(() {
        formData = data;
        isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading office data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchReviews() async {
    try {
      final token = await Session.getToken();
      final data = await ReviewService.getOfficeReviews(widget.officeId, token);
      setState(() {
        reviews = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      logger.e('Error loading reviews: $e');
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final token = await Session.getToken();
    try {
      await OfficeService.updateOffice(widget.officeId, formData, token);

      if (_profileImage != null) {
        await OfficeService.uploadOfficeImage(
          widget.officeId,
          _profileImage!,
          token,
        );
      }

      setState(() => isEditMode = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Office updated successfully')),
        );
      }
    } catch (e) {
      logger.e('Error updating office: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update office')),
        );
      }
    }
  }

  Widget _buildField(String label, String field, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        isEditMode
            ? TextFormField(
              initialValue: formData[field]?.toString() ?? '',
              keyboardType:
                  isNumber ? TextInputType.number : TextInputType.text,
              validator:
                  (val) => (val == null || val.isEmpty) ? 'Required' : null,
              onSaved: (val) => formData[field] = val,
            )
            : Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(formData[field]?.toString() ?? '-'),
            ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Office Rating',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Row(
          children: [
            Text(
              formData['rating']?.toStringAsFixed(1) ?? '-',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.star, color: Colors.amber, size: 32),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Reviews',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        if (reviews.isEmpty)
          const Text('No reviews yet.')
        else
          ...reviews.map((r) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                subtitle: Text(r['comment'] ?? ''),
                trailing: Text('By: ${r['user']?['name'] ?? 'Unknown'}'),
              ),
            );
          }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    if (isLoading) return const Center(child: CircularProgressIndicator());

    final profileImage =
        _profileImage != null
            ? FileImage(_profileImage!)
            : (formData['profile_image'] != null &&
                        formData['profile_image'] != ''
                    ? NetworkImage(formData['profile_image'])
                    : const AssetImage("assets/office.png"))
                as ImageProvider;

    return Scaffold(
      appBar: AppBar(title: const Text("Office Profile")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child:
              isWeb
                  ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap:
                                  widget.isOwner && isEditMode
                                      ? _pickImage
                                      : null,
                              child: CircleAvatar(
                                radius: 80,
                                backgroundImage: profileImage,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (widget.isOwner)
                              ElevatedButton(
                                onPressed:
                                    isEditMode
                                        ? _saveChanges
                                        : () =>
                                            setState(() => isEditMode = true),
                                child: Text(isEditMode ? "Save" : "Edit"),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildField("Name", "name"),
                            _buildField("Email", "email"),
                            _buildField("Phone", "phone"),
                            _buildField("Location", "location"),
                            _buildField("Capacity", "capacity", isNumber: true),
                            _buildField("Points", "points", isNumber: true),
                            _buildField("Bank Account", "bank_account"),
                            _buildField(
                              "Staff Count",
                              "staff_count",
                              isNumber: true,
                            ),
                            _buildField(
                              "Active Projects",
                              "active_projects_count",
                              isNumber: true,
                            ),
                            _buildField("Branches", "branches"),
                            _buildReviews(),
                          ],
                        ),
                      ),
                    ],
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: widget.isOwner && isEditMode ? _pickImage : null,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: profileImage,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildField("Name", "name"),
                      _buildField("Email", "email"),
                      _buildField("Phone", "phone"),
                      _buildField("Location", "location"),
                      _buildField("Capacity", "capacity", isNumber: true),
                      _buildField("Points", "points", isNumber: true),
                      _buildField("Bank Account", "bank_account"),
                      _buildField("Staff Count", "staff_count", isNumber: true),
                      _buildField(
                        "Active Projects",
                        "active_projects_count",
                        isNumber: true,
                      ),
                      _buildField("Branches", "branches"),
                      if (widget.isOwner)
                        ElevatedButton(
                          onPressed:
                              isEditMode
                                  ? _saveChanges
                                  : () => setState(() => isEditMode = true),
                          child: Text(isEditMode ? "Save" : "Edit"),
                        ),
                      _buildReviews(),
                    ],
                  ),
        ),
      ),
    );
  }
}
