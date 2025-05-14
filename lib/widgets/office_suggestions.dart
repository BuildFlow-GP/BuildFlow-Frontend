// widgets/office_suggestions.dart
import 'package:flutter/material.dart';
import '../models/office.dart';
import '../screens/office_profile.dart';

class OfficeSuggestions extends StatelessWidget {
  final List<Office> offices;

  const OfficeSuggestions({Key? key, required this.offices}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested Offices',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: offices.length,
            itemBuilder: (context, index) {
              final office = offices[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OfficeProfilePage(office: office),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  width: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(office.profileImage ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.black54,
                      child: Text(
                        office.name,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
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
