import 'package:flutter/material.dart';
import '../../models/company_model.dart'; // تأكدي من المسار الصحيح

class CompanySuggestionCard extends StatefulWidget {
  final CompanyModel company;
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
                                  Icons.domain_verification,
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
                          widget.onFavoriteToggle!();
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
                      widget.company.name,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    // إذا قررتِ إضافة company_type وتم تعديل الـ API ليشمله
                    // if (widget.company.companyType != null && widget.company.companyType!.isNotEmpty)
                    //   Text(
                    //     widget.company.companyType!,
                    //     style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                    //     maxLines: 1,
                    //     overflow: TextOverflow.ellipsis,
                    //   ),
                    // const SizedBox(height: 4.0),
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
    );
  }
}
