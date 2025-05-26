// screens/profiles/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // لتنسيق التاريخ
import '../../models/user_model.dart';
import '../../services/ReadonlyProfiles/user_readonly.dart';

class UserrProfileScreen extends StatefulWidget {
  final int userId; // ID المستخدم الذي نريد عرض بروفايله

  const UserrProfileScreen({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _UserrProfileScreenState createState() => _UserrProfileScreenState();
}

class _UserrProfileScreenState extends State<UserrProfileScreen> {
  final UserProfileService _profileService = UserProfileService();
  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final userData = await _profileService.getUserDetails(widget.userId);
      if (mounted) {
        setState(() {
          _user = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
      print("Error fetching user details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_user?.name ?? 'User Profile')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              : _user == null
              ? const Center(child: Text('User data not available.'))
              : RefreshIndicator(
                // للسماح بالسحب للتحديث
                onRefresh: _fetchUserDetails,
                child: ListView(
                  // استخدام ListView بدلاً من SingleChildScrollView
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildUserInfoSection(),
                    const SizedBox(height: 24),
                    // يمكنكِ إضافة أقسام أخرى هنا في المستقبل إذا أردتِ
                    // مثلاً: _buildUserProjectsSection()
                  ],
                ),
              ),
    );
  }

  Widget _buildUserInfoSection() {
    if (_user == null) return const SizedBox.shrink();

    // تحديد تاريخ الانضمام وتنسيقه
    String memberSince = 'N/A';
    if (_user!.createdAt.isNotEmpty) {
      try {
        // إذا كان createdAt هو ISO 8601 string
        final DateTime joinedDate = DateTime.parse(_user!.createdAt);
        memberSince = DateFormat.yMMMd().format(joinedDate);
      } catch (e) {
        // إذا لم يكن بتنسيق ISO، اعرضه كما هو (أو قيمة افتراضية)
        memberSince = _user!.createdAt;
        print("Could not parse user createdAt date: ${_user!.createdAt}");
      }
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  (_user!.profileImage != null &&
                          _user!.profileImage!.isNotEmpty)
                      ? NetworkImage(_user!.profileImage!)
                      : null,
              onBackgroundImageError: (exception, stackTrace) {
                print('Error loading user profile image: $exception');
              },
              child:
                  (_user!.profileImage == null || _user!.profileImage!.isEmpty)
                      ? const Icon(Icons.person, size: 50)
                      : null,
            ),
            const SizedBox(height: 16),
            Text(
              _user!.name, // UserModel يضمن أنها لن تكون null (بسبب `?? ''`)
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Member since: $memberSince',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Divider(),
            // عرض المعلومات العامة فقط (تجنب الإيميل والهاتف والمعلومات البنكية هنا)
            if (_user!.location != null && _user!.location!.isNotEmpty)
              _buildInfoRow(
                Icons.location_on_outlined,
                'Location',
                _user!.location!,
              ),
            // يمكنك إضافة حقل "نبذة" (bio/description) إذا كان موجوداً في UserModel
            // if (_user!.bio != null && _user!.bio!.isNotEmpty)
            //   _buildInfoRow(Icons.info_outline, 'About', _user!.bio!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
