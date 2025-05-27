import 'package:flutter/material.dart';
import '../../models/office_model.dart'; // تأكدي من المسار الصحيح

class OfficeSuggestionCard extends StatelessWidget {
  // تم تحويله إلى StatelessWidget مبدئياً
  final OfficeModel office;
  final bool isFavorite; // مطلوب
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const OfficeSuggestionCard({
    super.key,
    required this.office,
    required this.isFavorite, // أصبح مطلوباً
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // للاحتفاظ بتأثيرات الـ hover، سنستخدم نفس النمط الذي اتبعناه مع CompanySuggestionCard
    return _OfficeSuggestionCardContent(
      office: office,
      isFavorite: isFavorite,
      onFavoriteToggle: onFavoriteToggle,
      onTap: onTap,
    );
  }
}

class _OfficeSuggestionCardContent extends StatefulWidget {
  final OfficeModel office;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const _OfficeSuggestionCardContent({
    required this.office,
    required this.isFavorite,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  State<_OfficeSuggestionCardContent> createState() =>
      _OfficeSuggestionCardContentState();
}

class _OfficeSuggestionCardContentState
    extends State<_OfficeSuggestionCardContent> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _isHovered ? 1.03 : 1.0;
    final double elevation = _isHovered ? 8.0 : 2.0;
    final Offset offset = _isHovered ? const Offset(0, -5) : Offset.zero;
    final Duration animationDuration = const Duration(milliseconds: 200);

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
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(
                255,
                84,
                83,
                83,
              ).withOpacity(_isHovered ? 0.15 : 0.08),
              blurRadius: elevation * 2,
              spreadRadius: 0.5,
              offset: Offset(0, elevation / 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                        ),
                        child:
                            widget.office.profileImage != null &&
                                    widget.office.profileImage!.isNotEmpty
                                ? Image.network(
                                  widget
                                      .office
                                      .profileImage!, // افترض أن هذا URL كامل
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        height: 120,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(
                                            Icons.business,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                  loadingBuilder: (
                                    BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(
                                      height: 120,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                        ),
                                      ),
                                    );
                                  },
                                )
                                : Container(
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.business,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                      ),
                      if (widget.onFavoriteToggle != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap:
                                  widget
                                      .onFavoriteToggle, // استدعاء الدالة الممررة مباشرة
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Icon(
                                  widget.isFavorite
                                      ? Icons.favorite
                                      : Icons
                                          .favorite_border, // استخدام widget.isFavorite
                                  color:
                                      widget.isFavorite
                                          ? Colors.redAccent
                                          : Colors.white,
                                  size: 26,
                                  shadows:
                                      _isHovered || !widget.isFavorite
                                          ? [
                                            const Shadow(
                                              blurRadius: 3.0,
                                              color: Colors.black54,
                                              offset: Offset(0, 1),
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
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.office.name,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        if (widget.office.location != null &&
                            widget.office.location!.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(width: 4.0),
                              Expanded(
                                child: Text(
                                  widget.office.location ?? '',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4.0),
                        if (widget.office.rating != null)
                          Row(
                            children: <Widget>[
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16.0,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                widget.office.rating!.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 12.0),
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
        ),
      ),
    );
  }
}
