import 'package:flutter/material.dart';
import '../../models/office_model.dart'; // تأكدي من المسار الصحيح

class OfficeSuggestionCard extends StatefulWidget {
  final OfficeModel office;
  final VoidCallback? onFavoriteToggle; // للتعامل مع ضغطة القلب
  final VoidCallback? onTap; // للتعامل مع ضغطة الكرت كامل

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
  // مبدئياً، حالة المفضلة ستكون محلية هنا
  // لاحقاً، يجب أن تأتي هذه الحالة من مصدر بيانات أعلى (e.g., BLoC, Provider, GetX state)
  // أو يتم تحديثها بناءً على استجابة الـ API
  bool _isFavorite = false; // افترض أنها ليست مفضلة مبدئياً

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
          width: 220, // عرض ثابت للكرت ليتناسب مع التمرير الأفقي
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
                              // معالجة الخطأ في حال عدم تحميل الصورة
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.business,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                              // إظهار مؤشر تحميل أثناء تحميل الصورة
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
                                          loadingProgress.expectedTotalBytes !=
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.white,
                          size: 28,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.3),
                        ),
                        onPressed: () {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                          widget.onFavoriteToggle!(); // استدعاء الـ callback
                        },
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
    );
  }
}
