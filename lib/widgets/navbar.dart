import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;

  const Navbar({
    required this.onProfileTap,
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
          Row(
            children: [
              Icon(Icons.business, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                "BuildFlow",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),

          // Menu Items
          Row(
            children: [
              _navItem("About Us", () {}),
              _navItem("Contact Us", () {}),
              _navItem("Categories", () {}),
              _navItem("Profile", onProfileTap),
              _navItem("Logout", onLogoutTap),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
