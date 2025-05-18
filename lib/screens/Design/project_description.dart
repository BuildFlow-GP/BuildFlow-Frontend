import 'package:flutter/material.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({super.key});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

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

  final TextEditingController generalDescriptionController = TextEditingController();
  final TextEditingController interiorDesignController = TextEditingController();
  final TextEditingController roomDistributionController = TextEditingController();

  List<String> directions = ['North', 'South', 'East', 'West'];

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
      appBar: AppBar(
        title: const Text('Project Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Number of Floors', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<int>(
              value: floorCount,
              items: [1, 2, 3].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
              onChanged: (val) => setState(() => floorCount = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            const Text('Rooms Count', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildNumberField('Bedrooms', bedroomsController),
            _buildNumberField('Bathrooms', bathroomsController),
            _buildNumberField('Kitchens', kitchensController),
            _buildNumberField('Balconies', balconiesController),

            const SizedBox(height: 16),
            const Text('Special Rooms', style: TextStyle(fontWeight: FontWeight.bold)),
            ...specialRooms.map((room) => CheckboxListTile(
              title: Text(room),
              value: selectedSpecialRooms.contains(room),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    selectedSpecialRooms.add(room);
                  } else {
                    selectedSpecialRooms.remove(room);
                  }
                });
              },
            )),

            const SizedBox(height: 16),
            const Text('Room Direction Preferences', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: roomNameController,
                    decoration: const InputDecoration(labelText: 'Room Name'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: selectedDirection,
                    items: directions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) => setState(() => selectedDirection = val),
                    decoration: const InputDecoration(labelText: 'Direction'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addDirectionalRoom,
                ),
              ],
            ),
            ...directionalRooms.asMap().entries.map((entry) {
              int i = entry.key;
              var room = entry.value;
              return ListTile(
                title: Text('${room['room']} - ${room['direction']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => removeDirectionalRoom(i),
                ),
              );
            }),

            const SizedBox(height: 16),
            const Text('Kitchen Type', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: kitchenType,
              items: ['Open', 'Closed'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (val) => setState(() => kitchenType = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Does Master Bedroom have a Bathroom?'),
              value: masterHasBathroom,
              onChanged: (val) => setState(() => masterHasBathroom = val),
            ),

            const SizedBox(height: 16),
            _buildTextField('General Design Description', generalDescriptionController, lines: 3),
            _buildTextField('Interior Design Description', interiorDesignController, lines: 3),
            _buildTextField('Room Distribution Across Floors', roomDistributionController, lines: 3),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Handle form submission
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Project details submitted!')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return 'Enter number';
          if (int.tryParse(val) == null) return 'Enter valid number';
          return null;
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
