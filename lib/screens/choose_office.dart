import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/choose_office_api.dart';

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
    });
  }

  void _onOfficeSelected(Office office) {
    logger.i('Selected office: ${office.name}');
    Navigator.pop(context, office); // Return selected office
  }

  Widget _buildOfficeCard(Office office) {
    logger.i("Loading image from: ${office.imageUrl}"); // 🔍 Add this line
    return GestureDetector(
      onTap: () => _onOfficeSelected(office),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
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
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    office.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(office.location),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(office.rating.toString()),
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
                                  return _buildOfficeCard(office);
                                },
                              ),
                    ),
                  ],
                ),
      ),
    );
  }
}
