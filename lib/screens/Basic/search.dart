import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../models/Basic/user_model.dart';
import '../../models/Basic/office_model.dart';
import '../../models/Basic/company_model.dart';
import '../../services/Basic/search_service.dart';
import '../ReadonlyProfiles/company_readonly_profile.dart';
import '../ReadonlyProfiles/office_readonly_profile.dart';
import '../ReadonlyProfiles/user_readonly_profile.dart';

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
  Timer? _debounce;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      performSearch();
    });
  }

  Future<void> performSearch() async {
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
        // مثال على الانتقال
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserrProfileScreen(userId: user.id),
          ),
        );
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      OfficerProfileScreen(officeId: office.id, isOwner: false),
            ),
          );

          print('Tapped on Office: ${office.name} (ID: ${office.id})');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigate to profile of ${office.name}')),
          );
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CompanyrProfileScreen(
                    companyId: company.id,
                    isOwner: false,
                  ),
            ),
          );

          logger.i('Navigate to Company ID: ${company.id}');
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue.shade100,
        ),
        labelColor: Colors.blue[800],
        unselectedLabelColor: Colors.grey[600],
        tabs: const [
          Tab(text: 'Users'),
          Tab(text: 'Offices'),
          Tab(text: 'Companies'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _ = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or location...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildTabBar(),
            const SizedBox(height: 10),
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
                          (context, index) =>
                              buildCompanyCard(companies[index]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
