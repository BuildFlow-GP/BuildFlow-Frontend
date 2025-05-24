/*import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class NoPermitScreen extends StatefulWidget {
  const NoPermitScreen({super.key});

  @override
  State<NoPermitScreen> createState() => _NoPermitScreenState();
}

class _NoPermitScreenState extends State<NoPermitScreen> {
  int _selectedIndex = 0;

  // Step checkboxes
  bool step1 = false;
  bool step2 = false;
  bool step3 = false;
  bool step4 = false;

  // // Pages for each navigation item
  // final List<Widget> _pages = [
  //   const Center(child: Text('Home Screen')),
  //   const Center(child: Text('Search Screen')),
  //   const Center(child: Text('Likes Screen')),
  //   const Center(child: Text('Notifications Screen')),
  //   const Center(child: Text('Profile Screen')),
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Responsive Header with Logo Space
              Container(
                color: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                child:
                    constraints.maxWidth > 600
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // Logo Image
                                Container(
                                  width: 50,
                                  height: 50,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Image.asset(
                                    'assets/logoo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const Text(
                                  'BuildFlow',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Home',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'About',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Contact',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                        : AppBar(
                          title: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                color: Colors.white,
                                margin: const EdgeInsets.only(right: 8),
                                child: const Center(
                                  child: Text(
                                    'Logo',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                              const Text('BuildFlow'),
                            ],
                          ),
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder:
                                      (context) => Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: const Icon(Icons.home),
                                              title: const Text('Home'),
                                              onTap: () {},
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.info),
                                              title: const Text('About'),
                                              onTap: () {},
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                Icons.contact_page,
                                              ),
                                              title: const Text('Contact'),
                                              onTap: () {},
                                            ),
                                          ],
                                        ),
                                      ),
                                );
                              },
                            ),
                          ],
                        ),
              ),
              const SizedBox(height: 20),

              // Main Body Content Centered
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Text(
                          "Submit land ownership documents",
                          style: TextStyle(
                            decoration:
                                step1
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                          ),
                        ),
                        subtitle: const Text(
                          "Visit the local land registry office, provide property information, pay the required fees, and obtain your ownership documents.",
                        ),
                        value: step1,
                        onChanged: (val) => setState(() => step1 = val!),
                        secondary: const Icon(Icons.description),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text(
                          "Get a land survey report",
                          style: TextStyle(
                            decoration:
                                step2
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                          ),
                        ),
                        subtitle: const Text(
                          "Hire a licensed surveyor to measure and map your property, then submit the survey data to the local land authority for validation.",
                        ),
                        value: step2,
                        onChanged: (val) => setState(() => step2 = val!),
                        secondary: const Icon(Icons.map),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text(
                          "Obtain municipal approval",
                          style: TextStyle(
                            decoration:
                                step3
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                          ),
                        ),
                        subtitle: const Text(
                          "Submit your building plans to the municipal office and receive official approval.",
                        ),
                        value: step3,
                        onChanged: (val) => setState(() => step3 = val!),
                        secondary: const Icon(Icons.account_balance),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text(
                          "Obtain archaeological authority approval",
                          style: TextStyle(
                            decoration:
                                step4
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                          ),
                        ),
                        subtitle: const Text(
                          "Coordinate with the Department of Antiquities to ensure the construction site is clear.",
                        ),
                        value: step4,
                        onChanged: (val) => setState(() => step4 = val!),
                        secondary: const Icon(Icons.account_balance_outlined),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed:
                            (step1 && step2 && step3 && step4)
                                ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('All steps completed!'),
                                    ),
                                  );
                                }
                                : null,
                        child: const Text('Submit Documents'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),

      // Animated Navigation Bar
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.blue,
        color: Colors.white,
        buttonBackgroundColor: Colors.blue,
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        index: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          Icon(Icons.home, size: 30, color: Colors.black),
          Icon(Icons.search, size: 30, color: Colors.black),
          Icon(Icons.favorite, size: 30, color: Colors.black),
          Icon(Icons.notifications, size: 30, color: Colors.black),
          Icon(Icons.person, size: 30, color: Colors.black),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: NoPermitScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}
*/
/*
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

void main() {
  runApp(
    const MaterialApp(
      home: NoPermitScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class NoPermitScreen extends StatefulWidget {
  const NoPermitScreen({super.key});

  @override
  State<NoPermitScreen> createState() => _NoPermitScreenState();
}

class _NoPermitScreenState extends State<NoPermitScreen> {
  int _selectedIndex = 0;

  // Step checkboxes
  bool step1 = false;
  bool step2 = false;
  bool step3 = false;
  bool step4 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // == Navbar ==
              Container(color: Colors.blueGrey[900], child: const Navbar()),

              const SizedBox(height: 20),

              // == Main Body Content ==
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Text(
                          "Submit land ownership documents",
                          style: TextStyle(
                            decoration:
                                step1
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                          ),
                        ),
                        subtitle: const Text(
                          "Visit the local land registry office, provide property information, pay the required fees, and obtain your ownership documents.",
                        ),
                        value: step1,
                        onChanged: (val) => setState(() => step1 = val!),
                        secondary: const Icon(Icons.description),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text(
                          "Get a land survey report",
                          style: TextStyle(
                            decoration:
                                step2
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                          ),
                        ),
                        subtitle: const Text(
                          "Hire a licensed surveyor to measure and map your property, then submit the survey data to the local land authority for validation.",
                        ),
                        value: step2,
                        onChanged: (val) => setState(() => step2 = val!),
                        secondary: const Icon(Icons.map),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text(
                          "Obtain municipal approval",
                          style: TextStyle(
                            decoration:
                                step3
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                          ),
                        ),
                        subtitle: const Text(
                          "Submit your building plans to the municipal office and receive official approval.",
                        ),
                        value: step3,
                        onChanged: (val) => setState(() => step3 = val!),
                        secondary: const Icon(Icons.account_balance),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text(
                          "Obtain archaeological authority approval",
                          style: TextStyle(
                            decoration:
                                step4
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                          ),
                        ),
                        subtitle: const Text(
                          "Coordinate with the Department of Antiquities to ensure the construction site is clear.",
                        ),
                        value: step4,
                        onChanged: (val) => setState(() => step4 = val!),
                        secondary: const Icon(Icons.account_balance_outlined),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed:
                            (step1 && step2 && step3 && step4)
                                ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('All steps completed!'),
                                    ),
                                  );
                                }
                                : null,
                        child: const Text('Submit Documents'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      /*
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: const Color(0xFFA0C1BF),
        buttonBackgroundColor: Colors.white,
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        index: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          Icon(Icons.home, size: 30, color: const Color(0xFF1F6B61)),
          Icon(Icons.search, size: 30, color: Colors.black),
          Icon(Icons.apartment, size: 30, color: Colors.black),
          Icon(Icons.notifications, size: 30, color: Colors.black),
          Icon(Icons.person, size: 30, color: Colors.black),
        ],
      ),
    );
  }
}
*/
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: const Color(0xFFA0C1BF),
        buttonBackgroundColor: Colors.white,
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        index: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          // Home Icon with Tooltip
          _buildBottomNavItem(Icons.home, 'Home', 0),
          _buildBottomNavItem(Icons.search, 'Search', 1),
          _buildBottomNavItem(Icons.apartment, 'Project', 2),
          _buildBottomNavItem(Icons.notifications, 'Notifications', 3),
          _buildBottomNavItem(Icons.person, 'Profile', 4),
        ],
      ),
    );
  }

  /// بناء عنصر في شريط التنقل السفلي مع دعم:
  /// - التمرير فوقه بالماوس (Hover) لإظهار Tooltip (في الويب)
  /// - الضغط الطويل (Long Press) لإظهار SnackBar (في الجوال)
  ///
  /// [icon] = الأيقونة المراد عرضها
  /// [label] = النص الذي يظهر عند Hover أو Long Press
  /// [index] = رقم الموقع في الـ Bottom Navigation
  ///
  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onLongPress: () {
          _showTooltip(context, label);
        },
        child: Tooltip(
          message: label,
          child: Icon(
            icon,
            size: 30,
            color: isSelected ? const Color(0xFF1F6B61) : Colors.black,
          ),
        ),
      ),
    );
  }

  /// إظهار SnackBar كـ "Tooltip" عند الضغط الطويل على أيقونة التنقل
  ///
  /// [context] = سياق الواجهة الحالية (BuildContext)
  /// [message] = الرسالة التي تظهر للمستخدم

  void _showTooltip(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }
}
// ========================
// == Navbar Widget ==
// ========================

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  static Widget _navItem(String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: const Color(0xFFA0C1BF),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo and App Name
          Flexible(
            flex: 1,
            child: Row(
              children: [
                Image.asset(
                  'assets/logoo.png',
                  width: 70,
                  height: 70,
                  //color: Colors.white, // لو تحب تعطي اللون يدويًا
                ),
                const SizedBox(width: 10),
                const Text(
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _navItem("About Us", () {}),
                  _navItem("Contact Us", () {}),
                  _navItem("Categories", () {}),
                  _navItem("Logout", () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:buildflow_frontend/widgets/navbar.dart';
import 'package:buildflow_frontend/widgets/bottom_nav_item.dart';
import 'package:buildflow_frontend/themes/app_colors.dart';
import 'package:buildflow_frontend/utils/responsive.dart';

class NoPermitScreen extends StatefulWidget {
  const NoPermitScreen({super.key});

  @override
  State<NoPermitScreen> createState() => _NoPermitScreenState();
}

class _NoPermitScreenState extends State<NoPermitScreen> {
  int _selectedIndex = 0;

  bool step1 = false;
  bool step2 = false;
  bool step3 = false;
  bool step4 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              //  const Navbar(),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Text(
                          "Submit land ownership documents",
                          style: TextStyle(
                            decoration:
                                step1
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                          ),
                        ),
                        subtitle: const Text(
                          "Visit the local land registry office, provide property information, pay the required fees, and obtain your ownership documents.",
                        ),
                        value: step1,
                        onChanged: (val) => setState(() => step1 = val!),
                        secondary: const Icon(Icons.description),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text(
                          "Get a land survey report",
                          style: TextStyle(
                            decoration:
                                step2
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                          ),
                        ),
                        subtitle: const Text(
                          "Hire a licensed surveyor to measure and map your property, then submit the survey data to the local land authority for validation.",
                        ),
                        value: step2,
                        onChanged: (val) => setState(() => step2 = val!),
                        secondary: const Icon(Icons.map),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text(
                          "Obtain municipal approval",
                          style: TextStyle(
                            decoration:
                                step3
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                          ),
                        ),
                        subtitle: const Text(
                          "Submit your building plans to the municipal office and receive official approval.",
                        ),
                        value: step3,
                        onChanged: (val) => setState(() => step3 = val!),
                        secondary: const Icon(Icons.account_balance),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: Text(
                          "Obtain archaeological authority approval",
                          style: TextStyle(
                            decoration:
                                step4
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                          ),
                        ),
                        subtitle: const Text(
                          "Coordinate with the Department of Antiquities to ensure the construction site is clear.",
                        ),
                        value: step4,
                        onChanged: (val) => setState(() => step4 = val!),
                        secondary: const Icon(Icons.account_balance_outlined),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed:
                            (step1 && step2 && step3 && step4)
                                ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('All steps completed!'),
                                    ),
                                  );
                                }
                                : null,
                        child: const Text('Submit Documents'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: AppColors.primary,
        buttonBackgroundColor: Colors.white,
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        index: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavItem(
            icon: Icons.home,
            label: 'Home',
            index: 0,
            selectedIndex: _selectedIndex,
            onTap: (i) {},
          ),
          BottomNavItem(
            icon: Icons.search,
            label: 'Search',
            index: 1,
            selectedIndex: _selectedIndex,
            onTap: (i) {},
          ),
          BottomNavItem(
            icon: Icons.apartment,
            label: 'Project',
            index: 2,
            selectedIndex: _selectedIndex,
            onTap: (i) {},
          ),
          BottomNavItem(
            icon: Icons.notifications,
            label: 'Notifications',
            index: 3,
            selectedIndex: _selectedIndex,
            onTap: (i) {},
          ),
          BottomNavItem(
            icon: Icons.person,
            label: 'Profile',
            index: 4,
            selectedIndex: _selectedIndex,
            onTap: (i) {},
          ),
        ],
      ),
    );
  }
}
