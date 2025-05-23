import 'package:flutter/material.dart';
import 'dart:convert';

import '../screens/profiles/user_profile.dart';
import '../screens/profiles/company_profile.dart';
import '../screens/profiles/office_profile.dart';
import '../services/session.dart'; // تأكد من مسار ملف السيشن

class Navbar extends StatefulWidget {
  final VoidCallback onLogoutTap;

  const Navbar({required this.onLogoutTap, super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
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
              children: const [
                Icon(Icons.house, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'BuildFlow',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
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
                  _navItem("Profile", () => _navigateToProfile()),
                  _navItem("Logout", widget.onLogoutTap),
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
