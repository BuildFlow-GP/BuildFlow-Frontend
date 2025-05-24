import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../screens/profiles/office_profile.dart';
import '../../screens/profiles/company_profile.dart';

class ProfileSuggestionCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final int id;
  final String type; // 'office' or 'company'
  final double? rating;

  const ProfileSuggestionCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.id,
    required this.type,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Logger().i('Opening profile of $type with ID $id');
        if (type == 'office') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => OfficeProfileScreen(officeId: id, isOwner: true),
            ),
          );
        } else if (type == 'company') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyProfileScreen(isOwner: true),
            ),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type == 'office' ? 'Office' : 'Company',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    if (rating != null)
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[700], size: 18),
                          const SizedBox(width: 4),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
