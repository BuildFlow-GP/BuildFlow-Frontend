import 'package:flutter/material.dart';
import '../../models/project_model.dart'; // أو ProjectSuggestionModel

class ProjectSuggestionCard extends StatefulWidget {
  final ProjectModel project; // أو ProjectSuggestionModel
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
  bool _isHovered = false; // لتتبع حالة التمرير

  @override
  Widget build(BuildContext context) {
    // القيم التي ستتغير عند التمرير
    final double scale = _isHovered ? 1.03 : 1.0;
    final double elevation = _isHovered ? 8.0 : 2.0;
    final Offset offset = _isHovered ? const Offset(0, -5) : Offset.zero;
    final Duration animationDuration = const Duration(milliseconds: 200);

    // التعامل مع القيم التي قد تكون null (إذا كنتِ على الطريقة الأولى)
    final String projectName = widget.project.name;
    final String projectStatus = widget.project.status;
    final String? officeName = widget.project.office?.name;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: animationDuration,
        transformAlignment: Alignment.center,
        transform:
            Matrix4.identity()
              ..translate(offset.dx, offset.dy)
              ..scale(scale),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Theme.of(context).cardColor, // استخدام لون الكرت من الثيم
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                _isHovered ? 0.12 : 0.07,
              ), // ظل أخف قليلاً للمشاريع
              blurRadius: elevation * 1.5,
              spreadRadius: 0.3,
              offset: Offset(0, elevation / 2.5),
            ),
          ],
        ),
        // نضع الـ InkWell هنا
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            // استخدام Container بدلاً من Card مباشرة للتحكم الكامل بالـ padding والديكور
            width: 250, // يمكن تعديل العرض حسب الحاجة
            margin: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 4.0,
            ), // الهامش الخارجي للكرت
            padding: const EdgeInsets.all(12.0), // الهامش الداخلي لمحتوى الكرت
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projectName,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0), // زيادة المسافة قليلاً
                    Row(
                      children: [
                        Icon(
                          Icons.label_outline,
                          size: 16,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'Status: $projectStatus',
                          style: TextStyle(
                            fontSize: 13.0,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6.0), // زيادة المسافة قليلاً
                    if (officeName != null && officeName.isNotEmpty)
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
                              'Office: $officeName',
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
                    child: Material(
                      // لإضافة تأثير ضغط أفضل على الأيقونة
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                          if (widget.onFavoriteToggle != null) {
                            widget.onFavoriteToggle!();
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            4.0,
                          ), // padding حول الأيقونة
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                _isFavorite
                                    ? Colors.redAccent
                                    : Colors
                                        .grey[600], // لون مختلف قليلاً للقلب هنا
                            size: 26,
                            shadows:
                                _isHovered ||
                                        !_isFavorite // ظل خفيف للأيقونة
                                    ? [
                                      const Shadow(
                                        blurRadius: 2.0,
                                        color: Colors.black38,
                                        offset: Offset(0, 0.5),
                                      ),
                                    ]
                                    : null,
                          ),
                        ),
                      ),
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
