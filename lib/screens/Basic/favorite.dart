/*

// screens/favorites_screen.dart
import 'package:flutter/material.dart';
import '../../services/Basic/favorite_service.dart';
import '../../models/fav/userfav_model.dart';

// استيراد المودلز الفعلية OfficeModel, CompanyModel, ProjectModel
import '../../models/Basic/office_model.dart';
import '../../models/Basic/company_model.dart';
import '../../models/Basic/project_model.dart';

//import 'profiles/project_details_screen.dart'; // أو اسم شاشة تفاصيل المشروع
import '../ReadonlyProfiles/office_readonly_profile.dart';
import '../ReadonlyProfiles/company_readonly_profile.dart';
import '../ReadonlyProfiles/project_readonly_profile.dart';
// استيراد DetailedFavoriteItem ViewModel
import '../../models/fav/detailed_fav_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  List<DetailedFavoriteItem> _detailedFavorites = [];
  bool _isLoading = true;
  String? _error;
  static const String baseUrl =
      "http://localhost:5000"; // غيرها حسب سيرفرك الفعلي

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final favoriteItems = await _favoriteService.getFavorites();
      if (favoriteItems.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // جلب تفاصيل كل عنصر مفضل
      // استخدام Future.wait لجلبهم بشكل متوازٍ
      final List<DetailedFavoriteItem?> fetchedDetails = await Future.wait(
        favoriteItems.map((favInfo) async {
          try {
            final detail = await _favoriteService.getFavoriteItemDetail(
              favInfo.itemId,
              favInfo.itemType,
            );
            return DetailedFavoriteItem(
              favoriteInfo: favInfo,
              itemDetail: detail,
            );
          } catch (e) {
            print(
              "Error fetching detail for ${favInfo.itemType} ${favInfo.itemId}: $e",
            );
            return null; // إرجاع null في حالة الخطأ لجلب عنصر واحد
          }
        }).toList(),
      );

      if (mounted) {
        setState(() {
          // فلترة العناصر التي فشل جلب تفاصيلها (null)
          _detailedFavorites =
              fetchedDetails
                  .where((item) => item != null)
                  .cast<DetailedFavoriteItem>()
                  .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load favorites: ${e.toString()}";
          _isLoading = false;
        });
      }
      print("Error in _loadFavorites: $e");
    }
  }

  Future<void> _removeFromFavorites(FavoriteItemModel favoriteItem) async {
    try {
      await _favoriteService.removeFavorite(
        favoriteItem.itemId,
        favoriteItem.itemType,
      );
      // إعادة تحميل القائمة أو إزالة العنصر محلياً من _detailedFavorites
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${favoriteItem.itemType} removed from favorites.'),
          ),
        );
        _loadFavorites(); // الأسهل إعادة التحميل
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove from favorites: ${e.toString()}'),
          ),
        );
      }
      print("Error removing favorite: $e");
    }
  }

  void _navigateToDetail(DetailedFavoriteItem detailedItem) {
    // بناءً على itemDetail type، انتقل للشاشة المناسبة
    if (detailedItem.itemDetail is OfficeModel) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => OfficerProfileScreen(
                officeId: detailedItem.favoriteInfo.itemId,
              ),
        ),
      );
    } else if (detailedItem.itemDetail is CompanyModel) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => CompanyrProfileScreen(
                companyId: detailedItem.favoriteInfo.itemId,
              ),
        ),
      );
    } else if (detailedItem.itemDetail is ProjectModel) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ProjectreadDetailsScreen(
                projectId: detailedItem.favoriteInfo.itemId,
              ),
        ),
      );
      print("Navigate to project details: ${detailedItem.favoriteInfo.itemId}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_detailedFavorites.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'You have no favorite items yet.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _detailedFavorites.length,
      itemBuilder: (context, index) {
        final detailedItem = _detailedFavorites[index];
        return _buildFavoriteCard(detailedItem);
      },
    );
  }

  // مثال بسيط لكيفية بناء الكرت
  Widget _buildFavoriteCard(DetailedFavoriteItem detailedItem) {
    String title = 'Unknown Item';
    String? subtitle = 'Type: ${detailedItem.favoriteInfo.itemType}';
    ImageProvider? imageProvider;

    dynamic actualItem = detailedItem.itemDetail;

    if (actualItem is OfficeModel) {
      title = actualItem.name;
      subtitle = actualItem.location ?? subtitle; // أو أي معلومة أخرى
      if (actualItem.profileImage != null &&
          actualItem.profileImage!.isNotEmpty) {
        // تأكدي أن profileImage هو URL كامل أو أضيفي الـ baseUrl
        imageProvider = NetworkImage(
          actualItem.profileImage!.startsWith('http')
              ? actualItem.profileImage!
              : '$baseUrl/${actualItem.profileImage}',
        );
      }
    } else if (actualItem is CompanyModel) {
      title = actualItem.name;
      subtitle = actualItem.companyType ?? subtitle;
      if (actualItem.profileImage != null &&
          actualItem.profileImage!.isNotEmpty) {
        imageProvider = NetworkImage(
          actualItem.profileImage!.startsWith('http')
              ? actualItem.profileImage!
              : '$baseUrl/${actualItem.profileImage}',
        );
      }
    } else if (actualItem is ProjectModel) {
      title = actualItem.name;
      subtitle = actualItem.status; // أو أي معلومة أخرى
      // ProjectModel قد لا يحتوي على صورة بنفس الطريقة
    }

    imageProvider ??= const AssetImage('assets/company.png'); // صورة افتراضية

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: imageProvider,
          radius: 25,
          onBackgroundImageError: (_, __) {},
          child:
              // ignore: unnecessary_null_comparison
              imageProvider == null
                  ? const Icon(Icons.business)
                  : null, // أيقونة إذا لم تكن هناك صورة
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle!),
        trailing: IconButton(
          icon: const Icon(
            Icons.favorite,
            color: Colors.red,
          ), // أيقونة "مفضل" (مضاف بالفعل)
          tooltip: 'Remove from favorites',
          onPressed: () => _removeFromFavorites(detailedItem.favoriteInfo),
        ),
        onTap: () => _navigateToDetail(detailedItem),
      ),
    );
  }
}*/

// screens/favorites_screen.dart
import 'package:buildflow_frontend/models/Basic/company_model.dart';
import 'package:buildflow_frontend/models/Basic/office_model.dart';
import 'package:buildflow_frontend/models/Basic/project_model.dart';
import 'package:buildflow_frontend/models/fav/detailed_fav_model.dart';
import 'package:buildflow_frontend/models/fav/userfav_model.dart';
import 'package:buildflow_frontend/screens/ReadonlyProfiles/company_readonly_profile.dart';
import 'package:buildflow_frontend/screens/ReadonlyProfiles/office_readonly_profile.dart';
import 'package:buildflow_frontend/screens/ReadonlyProfiles/project_readonly_profile.dart';
import 'package:buildflow_frontend/services/Basic/favorite_service.dart';
import 'package:flutter/material.dart';
import 'package:buildflow_frontend/themes/app_colors.dart';
import 'package:logger/logger.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

final Logger logger = Logger();

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  List<DetailedFavoriteItem> _detailedFavorites = [];
  bool _isLoading = true;
  String? _error;
  static const String baseUrl =
      "http://localhost:5000"; // غيرها حسب سيرفرك الفعلي

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final favoriteItems = await _favoriteService.getFavorites();
      if (favoriteItems.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final List<DetailedFavoriteItem?> fetchedDetails = await Future.wait(
        favoriteItems.map((favInfo) async {
          try {
            final detail = await _favoriteService.getFavoriteItemDetail(
              favInfo.itemId,
              favInfo.itemType,
            );
            return DetailedFavoriteItem(
              favoriteInfo: favInfo,
              itemDetail: detail,
            );
          } catch (e) {
            logger.i(
              "Error fetching detail for ${favInfo.itemType} ${favInfo.itemId}: $e",
            );
            return null;
          }
        }).toList(),
      );

      if (mounted) {
        setState(() {
          _detailedFavorites =
              fetchedDetails
                  .where((item) => item != null)
                  .cast<DetailedFavoriteItem>()
                  .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Failed to load favorites: ${e.toString()}";
          _isLoading = false;
        });
      }
      logger.e("Error in _loadFavorites: $e");
    }
  }

  Future<void> _removeFromFavorites(FavoriteItemModel favoriteItem) async {
    try {
      await _favoriteService.removeFavorite(
        favoriteItem.itemId,
        favoriteItem.itemType,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${favoriteItem.itemType} removed from favorites.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        _loadFavorites();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to remove from favorites: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      logger.e("Error removing favorite: $e");
    }
  }

  void _navigateToDetail(DetailedFavoriteItem detailedItem) {
    if (detailedItem.itemDetail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Item details not available.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (detailedItem.itemDetail is OfficeModel) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => OfficerProfileScreen(
                officeId: detailedItem.favoriteInfo.itemId,
              ),
        ),
      );
    } else if (detailedItem.itemDetail is CompanyModel) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => CompanyrProfileScreen(
                companyId: detailedItem.favoriteInfo.itemId,
              ),
        ),
      );
    } else if (detailedItem.itemDetail is ProjectModel) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ProjectreadDetailsScreen(
                projectId: detailedItem.favoriteInfo.itemId,
              ),
        ),
      );
      logger.i(
        "Navigate to project details: ${detailedItem.favoriteInfo.itemId}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.accent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadFavorites,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Try Again',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_detailedFavorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                color: AppColors.textSecondary,
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'You have no favorite items yet.',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Add items to your favorites to see them here!',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final isWeb = MediaQuery.of(context).size.width > 600;

    return isWeb
        ? GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.0,
          ),
          itemCount: _detailedFavorites.length,
          itemBuilder: (context, index) {
            return _buildFavoriteItemCard(_detailedFavorites[index]);
          },
        )
        : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _detailedFavorites.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildFavoriteItemCard(_detailedFavorites[index]),
            );
          },
        );
  }

  // دالة مساعدة لبناء بطاقة عنصر مفضل فردية
  Widget _buildFavoriteItemCard(DetailedFavoriteItem detailedItem) {
    String title;
    String subtitle;
    // لم نعد بحاجة لـ imageProvider أو defaultIcon بما أننا لن نعرض CircleAvatar
    // ignore: unused_local_variable
    ImageProvider? imageProvider;
    dynamic actualItem = detailedItem.itemDetail;

    // معالجة حالة itemDetail == null
    if (actualItem == null) {
      title = 'Unavailable Item';
      subtitle =
          'ID: ${detailedItem.favoriteInfo.itemId} (Type: ${detailedItem.favoriteInfo.itemType})';
    } else if (actualItem is OfficeModel) {
      title = actualItem.name;
      subtitle = 'Office Location: ${actualItem.location ?? 'N/A'}';
      if (actualItem.profileImage != null &&
          actualItem.profileImage!.isNotEmpty) {
        imageProvider = NetworkImage(
          actualItem.profileImage!.startsWith('http')
              ? actualItem.profileImage!
              : '$baseUrl/${actualItem.profileImage}',
        );
      }
    } else if (actualItem is CompanyModel) {
      title = actualItem.name;
      subtitle = 'Company Type: ${actualItem.companyType ?? 'N/A'}';
      if (actualItem.profileImage != null &&
          actualItem.profileImage!.isNotEmpty) {
        imageProvider = NetworkImage(
          actualItem.profileImage!.startsWith('http')
              ? actualItem.profileImage!
              : '$baseUrl/${actualItem.profileImage}',
        );
      }
    } else if (actualItem is ProjectModel) {
      title = actualItem.name;
      subtitle = 'Status: ${actualItem.status ?? 'N/A'}';
    } else {
      title = 'Favorite Project';
      subtitle = 'Type: ${detailedItem.favoriteInfo.itemType}';
    }

    return GestureDetector(
      onTap: () => _navigateToDetail(detailedItem),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // أو Row إذا أردت الصورة بجانب المحتوى
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // *** تمت إزالة CircleAvatar بالكامل من هنا ***
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    tooltip: 'Remove from favorites',
                    onPressed:
                        () => _removeFromFavorites(detailedItem.favoriteInfo),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
