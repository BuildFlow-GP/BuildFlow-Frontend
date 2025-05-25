import 'package:flutter/material.dart';
import '../../models/company_model.dart'; // تأكدي من المسار الصحيح (أو CompanySuggestionModel إذا كنتِ تستخدمينه)

class CompanySuggestionCard extends StatefulWidget {
  final CompanyModel company; // أو CompanySuggestionModel
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const CompanySuggestionCard({
    super.key,
    required this.company,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  State<CompanySuggestionCard> createState() => _CompanySuggestionCardState();
}

class _CompanySuggestionCardState extends State<CompanySuggestionCard> {
  bool _isFavorite = false;
  bool _isHovered = false; // لتتبع حالة التمرير

  @override
  Widget build(BuildContext context) {
    // القيم التي ستتغير عند التمرير
    final double scale = _isHovered ? 1.03 : 1.0; // تكبير 3% عند التمرير
    final double elevation = _isHovered ? 8.0 : 2.0; // زيادة الظل
    final Offset offset =
        _isHovered ? const Offset(0, -5) : Offset.zero; // تحريك 5 بكسل للأعلى
    final Duration animationDuration = const Duration(
      milliseconds: 200,
    ); // سرعة الأنيميشن

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click, // تغيير شكل المؤشر عند التمرير
      child: AnimatedContainer(
        duration: animationDuration,
        transformAlignment: Alignment.center, // لتوسيط التحويل (scale)
        transform:
            Matrix4.identity()
              ..translate(offset.dx, offset.dy) // تطبيق الإزاحة
              ..scale(scale), // تطبيق التكبير/التصغير
        decoration: BoxDecoration(
          // لإضافة ظل متحرك بشكل صحيح مع التحويلات
          borderRadius: BorderRadius.circular(
            12.0,
          ), // نفس الـ borderRadius للـ Card
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 115, 115, 115).withOpacity(
                _isHovered ? 0.15 : 0.08,
              ), // ظل أغمق قليلاً عند التمرير
              blurRadius: elevation * 2, // زيادة انتشار الظل مع الـ elevation
              spreadRadius: 0.5,
              offset: Offset(0, elevation / 2),
            ),
          ],
        ),
        // نضع الـ InkWell هنا لضمان أن منطقة الضغط تتأثر بالتحويلات
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12.0), // مهم لتأثير الـ ripple
          child: Card(
            elevation:
                0, // الـ Card الأصلي بدون ظل، الظل الآن يُدار بواسطة AnimatedContainer
            // أو يمكنكِ الاحتفاظ بـ elevation طفيف هنا إذا أردتِ ظلاً أساسياً دائماً
            // elevation: 1.0,
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: SizedBox(
              width: 220, // العرض الأصلي للكرت
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
                            widget.company.profileImage != null &&
                                    widget.company.profileImage!.isNotEmpty
                                ? Image.network(
                                  widget.company.profileImage!,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 120,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(
                                          Icons.domain_verification,
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
                                      Icons.domain_verification,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                      ),
                      if (widget.onFavoriteToggle != null)
                        Positioned(
                          // استخدام Positioned لتحكم أفضل في موقع أيقونة القلب
                          top: 4,
                          right: 4,
                          child: Material(
                            // Material لإعطاء خلفية وظل إذا لزم الأمر
                            color: Colors.transparent, // أو لون خفيف
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              // InkWell لتأثير الضغط على القلب
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
                                padding: const EdgeInsets.all(
                                  6.0,
                                ), // تقليل الـ padding قليلاً
                                child: Icon(
                                  _isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      _isFavorite
                                          ? Colors.redAccent
                                          : Colors.white,
                                  size: 26, // تقليل حجم الأيقونة قليلاً
                                  shadows:
                                      _isHovered ||
                                              !_isFavorite // إضافة ظل خفيف للأيقونة لتبرز أكثر
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
                          widget.company.name,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        if (widget.company.rating != null)
                          Row(
                            children: <Widget>[
                              Icon(Icons.star, color: Colors.amber, size: 16.0),
                              const SizedBox(width: 4.0),
                              Text(
                                widget.company.rating!.toStringAsFixed(1),
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
