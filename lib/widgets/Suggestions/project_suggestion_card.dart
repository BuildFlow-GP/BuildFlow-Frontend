import 'package:flutter/material.dart';
import '../../models/project_model.dart'; // أو ProjectSuggestionModel

class ProjectSuggestionCard extends StatelessWidget {
  // تم تحويله إلى StatelessWidget مبدئياً
  final ProjectModel project;
  final bool isFavorite; // مطلوب
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const ProjectSuggestionCard({
    super.key,
    required this.project,
    required this.isFavorite, // أصبح مطلوباً
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _ProjectSuggestionCardContent(
      project: project,
      isFavorite: isFavorite,
      onTap: onTap,
      onFavoriteToggle: onFavoriteToggle,
    );
  }
}

class _ProjectSuggestionCardContent extends StatefulWidget {
  final ProjectModel project;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const _ProjectSuggestionCardContent({
    required this.project,
    required this.isFavorite,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  State<_ProjectSuggestionCardContent> createState() =>
      _ProjectSuggestionCardContentState();
}

class _ProjectSuggestionCardContentState
    extends State<_ProjectSuggestionCardContent> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _isHovered ? 1.03 : 1.0;
    final double elevation = _isHovered ? 8.0 : 2.0;
    final Offset offset = _isHovered ? const Offset(0, -5) : Offset.zero;
    final Duration animationDuration = const Duration(milliseconds: 200);

    final String projectName = widget.project.name;
    final String? projectStatus =
        widget.project.status; // افترض أنه دائماً موجود
    final String? officeName =
        widget.project.office?.name; // office قد يكون null

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
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(
                255,
                198,
                196,
                196,
              ).withOpacity(_isHovered ? 0.12 : 0.07),
              blurRadius: elevation * 1.5,
              spreadRadius: 0.3,
              offset: Offset(0, elevation / 2.5),
            ),
          ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            width: 250,
            height: 190, // تحديد ارتفاع ثابت للكرت ليتناسب مع التصميم
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  // لجعل المحتوى النصي يأخذ المساحة المتاحة ويتمدد
                  child: Column(
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
                      const SizedBox(height: 8.0),
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
                      const SizedBox(height: 6.0),
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
                ),
                if (widget.onFavoriteToggle != null)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap:
                            widget
                                .onFavoriteToggle, // استدعاء الدالة الممررة مباشرة
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            widget.isFavorite
                                ? Icons.favorite
                                : Icons
                                    .favorite_border, // استخدام widget.isFavorite
                            color:
                                widget.isFavorite
                                    ? Colors.redAccent
                                    : Colors.grey[600],
                            size: 26,
                            shadows:
                                _isHovered || !widget.isFavorite
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
