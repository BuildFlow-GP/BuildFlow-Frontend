import 'package:flutter/material.dart';
import '../../models/project_model.dart'; // تأكدي من المسار الصحيح

class ProjectSuggestionCard extends StatefulWidget {
  final ProjectModel project;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const ProjectSuggestionCard({
    super.key,
    required this.project,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  State<ProjectSuggestionCard> createState() => _ProjectSuggestionCardState();
}

class _ProjectSuggestionCardState extends State<ProjectSuggestionCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: SizedBox(
          width: 250, // يمكن تعديل العرض حسب الحاجة
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // لتوزيع المساحة
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.project.name,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2, // السماح بسطرين لاسم المشروع
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6.0),
                    Row(
                      children: [
                        Icon(
                          Icons.label_outline,
                          size: 16,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'Status: ${widget.project.status}',
                          style: TextStyle(
                            fontSize: 13.0,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    if (widget.project.office != null)
                      Row(
                        children: [
                          Icon(
                            Icons.business_center_outlined,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 4.0),
                          Expanded(
                            child: Text(
                              'Office: ${widget.project.office!.name}',
                              style: TextStyle(
                                fontSize: 13.0,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (widget.onFavoriteToggle != null)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.grey[700],
                        size: 26,
                      ),
                      onPressed: () {
                        setState(() {
                          _isFavorite = !_isFavorite;
                        });
                        widget.onFavoriteToggle!();
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
