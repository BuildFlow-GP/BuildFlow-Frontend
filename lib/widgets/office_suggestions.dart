import 'package:flutter/material.dart';
import '../models/office.dart';

class OfficeSuggestions extends StatelessWidget {
  final List<Office> offices;

  const OfficeSuggestions({super.key, required this.offices});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Suggested Offices",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: offices.length,
            itemBuilder: (context, index) {
              final office = offices[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/office-profile',
                    arguments: office,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            office.profileImage != null &&
                                    office.profileImage!.isNotEmpty
                                ? NetworkImage(office.profileImage!)
                                : const AssetImage('assets/default_profile.png')
                                    as ImageProvider,
                        backgroundColor: Colors.grey[200],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        office.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        office.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
