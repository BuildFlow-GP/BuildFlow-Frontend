import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../models/user_model.dart';
import '../../models/office_model.dart';
import '../../models/company_model.dart';
import '../services/search_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final logger = Logger();

  List<UserModel> users = [];
  List<OfficeModel> offices = [];
  List<CompanyModel> companies = [];

  late TabController _tabController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => isLoading = true);

    try {
      users = await SearchService.searchUsers(query);
      offices = await SearchService.searchOffices(query);
      companies = await SearchService.searchCompanies(query);
    } catch (e) {
      logger.e('Search error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildUserCard(UserModel user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.profileImage ?? ''),
        backgroundColor: Colors.grey[200],
      ),
      title: Text(user.name),
      onTap: () {
        // Navigate to User Profile
        logger.i('Navigate to User ID: ${user.id}');
      },
    );
  }

  Widget buildOfficeCard(OfficeModel office) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(office.profileImage ?? ''),
          backgroundColor: Colors.grey[200],
        ),
        title: Text(office.name),
        subtitle: Text(
          'Rating: ${office.rating?.toStringAsFixed(1) ?? 'N/A'} | ${office.location}',
        ),
        onTap: () {
          // Navigate to Office Profile
          logger.i('Navigate to Office ID: ${office.id}');
        },
      ),
    );
  }

  Widget buildCompanyCard(CompanyModel company) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(company.profileImage ?? ''),
          backgroundColor: Colors.grey[200],
        ),
        title: Text(company.name),
        subtitle: Text(
          'Rating: ${company.rating?.toStringAsFixed(1) ?? 'N/A'} | ${company.location}',
        ),
        onTap: () {
          // Navigate to Company Profile
          logger.i('Navigate to Company ID: ${company.id}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Offices'),
            Tab(text: 'Companies'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or location...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: performSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => performSearch(),
            ),
          ),
          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Users
                  ListView.builder(
                    itemCount: users.length,
                    itemBuilder:
                        (context, index) => buildUserCard(users[index]),
                  ),
                  // Offices
                  ListView.builder(
                    itemCount: offices.length,
                    itemBuilder:
                        (context, index) => buildOfficeCard(offices[index]),
                  ),
                  // Companies
                  ListView.builder(
                    itemCount: companies.length,
                    itemBuilder:
                        (context, index) => buildCompanyCard(companies[index]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
