import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:logger/logger.dart';

class DesignAgreementScreen extends StatefulWidget {
  const DesignAgreementScreen({super.key});

  @override
  State<DesignAgreementScreen> createState() => _DesignAgreementScreenState();
}


final Logger logger = Logger();

class _DesignAgreementScreenState extends State<DesignAgreementScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _plotNumberController = TextEditingController();
  final TextEditingController _basinNumberController = TextEditingController();
  final TextEditingController _areaNameController = TextEditingController();

  String? _pdfFilePath;

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _bankAccountController.dispose();
    _areaController.dispose();
    _plotNumberController.dispose();
    _basinNumberController.dispose();
    _areaNameController.dispose();
    super.dispose();
  }

  void _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _pdfFilePath = result.files.single.path;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF Uploaded: ${result.files.single.name}')),
        );
      }
    }
  }

  void _submit() {
    String name = _nameController.text;
    String id = _idController.text;
    String address = _addressController.text;
    String phone = _phoneController.text;
    String bankAccount = _bankAccountController.text;
    String area = _areaController.text;
    String plotNumber = _plotNumberController.text;
    String basinNumber = _basinNumberController.text;
    String areaName = _areaNameController.text;


    logger.i("Name: $name");
    logger.i("Identifier: $id");
    logger.i("Address: $address");
    logger.i("Phone: $phone");
    logger.i("Bank Account: $bankAccount");
    logger.i("Area (sqm): $area");
    logger.i("Plot Number: $plotNumber");
    logger.i("Basin Number: $basinNumber");
    logger.i("Area Name: $areaName");
    logger.i("PDF File Path: $_pdfFilePath");


    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Information Submitted!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design Agreement')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Information Section
              const Text(
                'User Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Identifier Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _bankAccountController,
                decoration: const InputDecoration(
                  labelText: 'Bank Account Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Land Information Section
              const Text(
                'Land Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Area (sqm)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _plotNumberController,
                decoration: const InputDecoration(
                  labelText: 'Plot Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _basinNumberController,
                decoration: const InputDecoration(
                  labelText: 'Basin Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _areaNameController,
                decoration: const InputDecoration(
                  labelText: 'Area Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Supporting Documents Section
              const Text(
                'Supporting Documents',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickPDF,
                icon: const Icon(Icons.attach_file),
                label: const Text('Upload PDF'),
              ),
              const SizedBox(height: 10),
              if (_pdfFilePath != null)
                Text(
                  'Selected PDF: $_pdfFilePath',
                  style: const TextStyle(color: Colors.grey),
                ),
              const SizedBox(height: 20),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: DesignAgreementScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
