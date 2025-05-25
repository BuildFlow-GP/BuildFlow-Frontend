import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
//import 'package:buildflow_frontend/widgets/navbar.dart';
import 'package:buildflow_frontend/widgets/bottom_nav_item.dart';
import 'package:buildflow_frontend/themes/app_colors.dart';

import 'package:buildflow_frontend/utils/responsive.dart';
import 'package:buildflow_frontend/widgets/app_drawer.dart';
import 'package:buildflow_frontend/widgets/custom_bottom_nav.dart';

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
      //  drawer: const AppDrawer(),
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
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
