import 'package:flutter/material.dart';
import '../../models/office_model.dart'; // تأكدي من المسار الصحيح (أو OfficeSuggestionModel)

class OfficeSuggestionCard extends StatefulWidget {
  final OfficeModel office; // أو OfficeSuggestionModel
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const OfficeSuggestionCard({
    super.key,
    required this.office,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  State<OfficeSuggestionCard> createState() => _OfficeSuggestionCardState();
}

class _OfficeSuggestionCardState extends State<OfficeSuggestionCard> {
  bool _isFavorite = false;
  bool _isHovered = false; // لتتبع حالة التمرير

  @override
  Widget build(BuildContext context) {
    // القيم التي ستتغير عند التمرير
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
            elevation: 0, // الظل يُدار بواسطة AnimatedContainer
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
                                  widget.office.profileImage!,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 120,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(
                                          Icons
                                              .business, // أيقونة مناسبة للمكتب
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
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
                              onTap: () {
                                setState(() {
                                  _isFavorite = !_isFavorite;
                                });
                                if (widget.onFavoriteToggle != null) {
                                  widget.onFavoriteToggle!();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Icon(
                                  _isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      _isFavorite
                                          ? Colors.redAccent
                                          : Colors.white,
                                  size: 26,
                                  shadows:
                                      _isHovered || !_isFavorite
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
                        // التعامل مع الموقع إذا كان null
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
                                  widget.office.location!,
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
                              Icon(Icons.star, color: Colors.amber, size: 16.0),
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
