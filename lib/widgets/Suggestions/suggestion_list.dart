import 'package:flutter/material.dart';
import 'suggestion_card.dart';

class ProfileSuggestionList extends StatelessWidget {
  final String title; // العنوان مثل: "مكاتب مقترحة"
  final List<Map<String, dynamic>> items; // البيانات
  final String type; // 'office' أو 'company'

  const ProfileSuggestionList({
    super.key,
    required this.title,
    required this.items,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 130, // ارتفاع الكرت مع الصورة
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ProfileSuggestionCard(
                name: item['name'],
                imageUrl: item['profile_image'] ?? '',
                id: item['id'],
                type: type,
                rating: item['rating']?.toDouble(),
              );
            },
          ),
        ),
      ],
    );
  }
}
