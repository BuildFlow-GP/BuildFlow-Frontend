import 'package:buildflow_frontend/themes/app_colors.dart';
import 'package:flutter/material.dart';

class ProjectDescriptionScreen extends StatefulWidget {
  const ProjectDescriptionScreen({super.key, required int projectId});

  @override
  State<ProjectDescriptionScreen> createState() =>
      _ProjectDescriptionScreenState();
}

class _ProjectDescriptionScreenState extends State<ProjectDescriptionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form state variables
  int? floorCount;
  final TextEditingController bedroomsController = TextEditingController();
  final TextEditingController bathroomsController = TextEditingController();
  final TextEditingController kitchensController = TextEditingController();
  final TextEditingController balconiesController = TextEditingController();

  final List<String> specialRooms = ['Salon', 'Guest Room', 'Dining Room'];
  final Set<String> selectedSpecialRooms = {};

  final List<Map<String, String>> directionalRooms = [];
  final TextEditingController roomNameController = TextEditingController();
  String? selectedDirection;

  String? kitchenType = 'Open';
  bool masterHasBathroom = false;

  final TextEditingController generalDescriptionController =
      TextEditingController();
  final TextEditingController interiorDesignController =
      TextEditingController();
  final TextEditingController roomDistributionController =
      TextEditingController();

  final List<String> directions = ['North', 'South', 'East', 'West'];

  @override
  void dispose() {
    bedroomsController.dispose();
    bathroomsController.dispose();
    kitchensController.dispose();
    balconiesController.dispose();
    roomNameController.dispose();
    generalDescriptionController.dispose();
    interiorDesignController.dispose();
    roomDistributionController.dispose();
    super.dispose();
  }

  void addDirectionalRoom() {
    if (roomNameController.text.isNotEmpty && selectedDirection != null) {
      setState(() {
        directionalRooms.add({
          'room': roomNameController.text,
          'direction': selectedDirection!,
        });
        roomNameController.clear();
        selectedDirection = null;
      });
    }
  }

  void removeDirectionalRoom(int index) {
    setState(() {
      directionalRooms.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            const SizedBox(height: 16),
            Expanded(child: _buildFormContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
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
              "Project Details",
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

  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppColors.card,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFloorCountField(),
                const SizedBox(height: 24),
                _buildRoomsCountSection(),
                const SizedBox(height: 24),
                _buildSpecialRoomsSection(),
                const SizedBox(height: 24),
                _buildDirectionalRoomsSection(),
                const SizedBox(height: 24),
                _buildKitchenTypeField(),
                const SizedBox(height: 24),
                _buildMasterBathroomSwitch(),
                const SizedBox(height: 24),
                _buildDescriptionFields(),
                const SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloorCountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of Floors',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonFormField<int>(
            value: floorCount,
            dropdownColor: Colors.white,
            icon: Icon(Icons.arrow_drop_down, color: AppColors.accent),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            style: TextStyle(color: AppColors.textPrimary),
            items:
                [1, 2, 3]
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                    .toList(),
            onChanged: (val) => setState(() => floorCount = val),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomsCountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rooms Count',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4), // تقليل المسافة هنا
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.2, // جعل العناصر أقل ارتفاعاً
          crossAxisSpacing: 12,
          mainAxisSpacing: 4, // تقليل المسافة بين الصفوف
          children: [
            _buildNumberField('Bedrooms', bedroomsController),
            _buildNumberField('Bathrooms', bathroomsController),
            _buildNumberField('Kitchens', kitchensController),
            _buildNumberField('Balconies', balconiesController),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecialRoomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Special Rooms',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...specialRooms.map(
          (room) => Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: CheckboxListTile(
              title: Text(room, style: TextStyle(color: AppColors.textPrimary)),
              value: selectedSpecialRooms.contains(room),
              activeColor: AppColors.accent,
              checkColor: Colors.white,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    selectedSpecialRooms.add(room);
                  } else {
                    selectedSpecialRooms.remove(room);
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionalRoomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Room Direction Preferences',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: roomNameController,
                decoration: InputDecoration(
                  labelText: 'Room Name',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedDirection,
                  dropdownColor: Colors.white,
                  icon: Icon(Icons.arrow_drop_down, color: AppColors.accent),
                  decoration: InputDecoration(
                    labelText: 'Direction',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  style: TextStyle(color: AppColors.textPrimary),
                  items:
                      directions
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => selectedDirection = val),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: addDirectionalRoom,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...directionalRooms.asMap().entries.map((entry) {
          int i = entry.key;
          var room = entry.value;
          return Card(
            margin: const EdgeInsets.only(top: 8),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: ListTile(
              title: Text(
                '${room['room']} - ${room['direction']}',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: AppColors.error),
                onPressed: () => removeDirectionalRoom(i),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildKitchenTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kitchen Type',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonFormField<String>(
            value: kitchenType,
            dropdownColor: Colors.white,
            icon: Icon(Icons.arrow_drop_down, color: AppColors.accent),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            style: TextStyle(color: AppColors.textPrimary),
            items:
                ['Open', 'Closed']
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
            onChanged: (val) => setState(() => kitchenType = val),
          ),
        ),
      ],
    );
  }

  Widget _buildMasterBathroomSwitch() {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: SwitchListTile(
        title: Text(
          'Does Master Bedroom have a Bathroom?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        value: masterHasBathroom,
        activeColor: AppColors.accent,
        onChanged: (val) => setState(() => masterHasBathroom = val),
      ),
    );
  }

  Widget _buildDescriptionFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descriptions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'General Design Description',
          generalDescriptionController,
          lines: 3,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Interior Design Description',
          interiorDesignController,
          lines: 3,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          'Room Distribution Across Floors',
          roomDistributionController,
          lines: 3,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Project details submitted!'),
                backgroundColor: AppColors.accent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        child: const Text(
          'Submit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8, // تقليل الحشو الداخلي
          ),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return 'Enter number';
          if (int.tryParse(val) == null) return 'Enter valid number';
          return null;
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int lines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: lines,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
