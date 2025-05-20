import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../services/chosen_office_service.dart';
import 'project_description.dart'; // Import the project description screen

final logger = Logger();

class ChooseOfficeScreen extends StatefulWidget {
  const ChooseOfficeScreen({super.key});

  @override
  State<ChooseOfficeScreen> createState() => _ChooseOfficeScreenState();
}

class _ChooseOfficeScreenState extends State<ChooseOfficeScreen> {
  List<Office> _offices = [];
  List<Office> _filteredOffices = [];
  bool _isLoading = true;
  String _searchQuery = '';
  Office? _selectedOffice;

  @override
  void initState() {
    super.initState();
    _loadOffices();
  }

  Future<void> _loadOffices() async {
    final offices = await OfficeService.fetchSuggestedOffices();
    setState(() {
      _offices = offices;
      _filteredOffices = offices;
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredOffices =
          _offices.where((office) {
            return office.name.toLowerCase().contains(_searchQuery) ||
                office.location.toLowerCase().contains(_searchQuery);
          }).toList();
      // Reset selection if filtered list does not contain the selected office
      if (_selectedOffice != null &&
          !_filteredOffices.contains(_selectedOffice)) {
        _selectedOffice = null;
      }
    });
  }

  void _onOfficeTapped(Office office) {
    setState(() {
      _selectedOffice = office;
    });
    logger.i('Tapped office: ${office.name}');
  }

  void _onNextPressed() {
    if (_selectedOffice != null) {
      logger.i('Selected office confirmed: ${_selectedOffice!.name}');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProjectDetailsScreen()),
      );
    }
  }

  Widget _buildOfficeCard(Office office, double cardWidth) {
    final bool isSelected = _selectedOffice == office;
    return GestureDetector(
      onTap: () => _onOfficeTapped(office),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: cardWidth,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? Colors.blue.shade100 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                office.imageUrl.isNotEmpty
                    ? office.imageUrl
                    : 'https://via.placeholder.com/80',
                width: cardWidth * 0.2,
                height: cardWidth * 0.2,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    office.name,
                    style: TextStyle(
                      fontSize: cardWidth > 400 ? 18 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    office.location,
                    style: TextStyle(fontSize: cardWidth > 400 ? 14 : 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        office.rating.toString(),
                        style: TextStyle(fontSize: cardWidth > 400 ? 14 : 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Adjust card width based on screen size (responsive)
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth > 600 ? 600 : screenWidth * 0.9;

    return Scaffold(
      appBar: AppBar(title: const Text("Choose an Office")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    TextField(
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        labelText: 'Search Office',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
                          _filteredOffices.isEmpty
                              ? const Center(
                                child: Text('No matching offices found.'),
                              )
                              : ListView.builder(
                                itemCount: _filteredOffices.length,
                                itemBuilder: (context, index) {
                                  final office = _filteredOffices[index];
                                  return Center(
                                    child: _buildOfficeCard(office, cardWidth),
                                  );
                                },
                              ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed:
                          _selectedOffice == null ? null : _onNextPressed,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(cardWidth, 48),
                      ),
                      child: Text(
                        _selectedOffice == null
                            ? 'Select an office to continue'
                            : 'Next',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
