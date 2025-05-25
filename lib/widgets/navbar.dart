// import 'dart:convert';

import 'package:buildflow_frontend/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:buildflow_frontend/widgets/drawer_wrapper.dart';
// import '../screens/profiles/user_profile.dart';
// import '../screens/profiles/company_profile.dart';
// import '../screens/profiles/office_profile.dart';
// import '../services/session.dart'; // تأكد من مسار ملف السيشن

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  // Common navigation items data
  static const List<Map<String, dynamic>> navItems = [
    {'label': 'About Us', 'icon': Icons.info},
    {'label': 'Contact Us', 'icon': Icons.contact_page},
    {'label': 'Categories', 'icon': Icons.category},
    {'label': 'Logout', 'icon': Icons.logout},
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return isMobile ? _buildMobileNavbar(context) : _buildDesktopNavbar();
  }

  Widget _buildDesktopNavbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and App Name with navigation
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: _navigateToHome,
              child: Row(
                children: [
                  Image.asset('assets/logoo.png', width: 70, height: 70),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),

          // Menu Items
          Flexible(
            flex: 2,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ...navItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _navItem(
                        item['label'],
                        () => _handleNavTap(item['label']),
                        isMobile: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  /*

void _navigateToProfile() async {
    final token = await Session.getToken();

    if (token == null) {
      debugPrint("No token found");
      return;
    }

    try {
      // Parse JWT payload
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint("Invalid token format");
        return;
      }

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = json.decode(payload);

      final userType =
          data['userType']?.toString(); // ✅ استخدم اسم الحقل الصحيح من الباك
      final int id = data['id'];

      // تحقق إذا الويجت مازال mounted قبل استخدام context
      if (!mounted) return;

      if (userType == null) {
        debugPrint('Token data is incomplete: type or id is null');
        return;
      }

      switch (userType.toLowerCase()) {
        case 'individual':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserProfileScreen(isOwner: true),
            ),
          );
          break;
        case 'company':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CompanyProfileScreen(isOwner: true),
            ),
          );
          break;
        case 'office':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => OfficeProfileScreen(isOwner: true, officeId: id),
            ),
          );
          break;
        default:
          debugPrint("Unknown userType: $userType");
      }
    } catch (e) {
      debugPrint("Error parsing token: $e");
    }
  }
=======
}
*/

  Widget _buildMobileNavbar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 4,
      title: GestureDetector(
        onTap: _navigateToHome,
        child: Row(
          children: [
            Image.asset('assets/logoo.png', width: 40, height: 40),
            const SizedBox(width: 10),
            const Text(
              'BuildFlow',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          onPressed: () {
            DrawerWrapper.openDrawer(context); // ✅ يعمل الآن!
          },
        ),
      ],
    );
  }

  Widget _navItem(String label, VoidCallback onTap, {bool isMobile = false}) {
    final item = navItems.firstWhere((item) => item['label'] == label);

    return isMobile
        ? ListTile(
          leading: Icon(item['icon'] as IconData, color: Colors.white),
          title: Text(label, style: const TextStyle(color: Colors.white)),
          onTap: onTap,
        )
        : TextButton(
          onPressed: onTap,
          child: Text(label, style: const TextStyle(color: Colors.white)),
        );
  }

  // Navigation handlers
  void _navigateToHome() {
    // Implement home navigation
    print('Navigating to home');
  }

  void _handleNavTap(String label) {
    // Implement navigation based on label
    switch (label) {
      case 'About Us':
        print('Navigating to About Us');
        break;
      case 'Contact Us':
        print('Navigating to Contact Us');
        break;
      case 'Categories':
        print('Navigating to Categories');
        break;
      case 'Logout':
        print('Logging out');
        break;
    }
  }
}

// To be used in your Scaffold
class NavDrawer extends StatelessWidget {
  final Function(String) onItemTap;

  const NavDrawer({super.key, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primary,
      width: MediaQuery.of(context).size.width * 0.7,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.zero),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primary.withOpacity(0.8),
              child: Row(
                children: [
                  Image.asset('assets/logoo.png', width: 50, height: 50),
                  const SizedBox(width: 10),
                  const Text(
                    'BuildFlow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...Navbar.navItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ListTile(
                        leading: Icon(
                          item['icon'] as IconData,
                          color: Colors.white,
                        ),
                        title: Text(
                          item['label'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          onItemTap(item['label']);
                        },
                      ),
                    ),
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
//  ???????????????????????????????????????????????????????????????????????????????????????????????????????
// import 'package:buildflow_frontend/themes/app_colors.dart';
// import 'package:flutter/material.dart';

// class Navbar extends StatelessWidget {
//   const Navbar({super.key});

//   static Widget _navItem(String label, VoidCallback onTap) {
//     return TextButton(
//       onPressed: onTap,
//       child: Text(label, style: const TextStyle(color: Colors.white)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       color: AppColors.primary,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Logo and App Name
//           Flexible(
//             flex: 1,
//             child: Row(
//               children: [
//                 Image.asset('assets/logoo.png', width: 70, height: 70),
//                 const SizedBox(width: 10),
//                 const Text(
//                   'BuildFlow',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ],
//             ),
//           ),

//           // Menu Items
//           Flexible(
//             flex: 2,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   _navItem("About Us", () {}),
//                   _navItem("Contact Us", () {}),
//                   _navItem("Categories", () {}),
//                   _navItem("Logout", () {}),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
