import 'package:flutter/material.dart';
import '../screens/profiles/user_profile.dart';
import '../screens/profiles/company_profile.dart';
import '../screens/profiles/office_profile.dart';

class Navbar extends StatelessWidget {
  final String userType; // "individual", "company", or "office"
  final int userId; // Logged-in user ID
  final VoidCallback onLogoutTap;

  const Navbar({
    required this.userType,
    required this.userId,
    required this.onLogoutTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.blueGrey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and App Name
          Flexible(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'BuildFlow',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Icon(Icons.person),
                SizedBox(width: 10),
              ],
            ),
          ),

          // Menu Items
          Flexible(
            flex: 2,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _navItem("About Us", () {}),
                  _navItem("Contact Us", () {}),
                  _navItem("Categories", () {}),
                  _navItem("Profile", () => _navigateToProfile(context)),
                  _navItem("Logout", onLogoutTap),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _navItem(String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  void _navigateToProfile(BuildContext context) {
    switch (userType.toLowerCase()) {
      case 'individual':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => UserProfileScreen(
                  isOwner: true, // required parameter
                ),
          ),
        );
        break;
      case 'company':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CompanyProfileScreen(
                  isOwner: true, // required parameter
                ),
          ),
        );
        break;
      case 'office':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => OfficeProfileScreen(
                  isOwner: true, // required parameter
                ),
          ),
        );
        break;
      default:
        debugPrint("Unknown userType: $userType");
    }
  }
}
