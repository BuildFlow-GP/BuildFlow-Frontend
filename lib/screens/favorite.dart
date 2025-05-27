// screens/favorites_screen.dart
import 'package:flutter/material.dart';
import '../services/favorite_service.dart';
import '../models/fav/userfav_model.dart';

// استيراد المودلز الفعلية OfficeModel, CompanyModel, ProjectModel
import '../models/office_model.dart';
import '../models/company_model.dart';
import '../models/project_model.dart';

//import 'profiles/project_details_screen.dart'; // أو اسم شاشة تفاصيل المشروع
import '../screens/ReadonlyProfiles/office_readonly_profile.dart';
import '../screens/ReadonlyProfiles/company_readonly_profile.dart';
//import '../screens/ReadonlyProfiles/project_readonly_profile.dart';
// استيراد DetailedFavoriteItem ViewModel
import '../models/fav/detailed_fav_model.dart';

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
      // افترض أن لديك شاشة لتفاصيل المشروع
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => ProjectDetailsScreen(projectId: detailedItem.favoriteInfo.itemId)),
      // );
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
        // هنا ستبنين الكرت لكل عنصر مفضل
        // يمكنكِ إنشاء ويدجت كرت منفصلة (مثلاً FavoriteItemCard)
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
          onBackgroundImageError: (_, __) {
            // للتعامل مع أخطاء تحميل الصورة
            // يمكنكِ هنا استخدام صورة placeholder مختلفة إذا فشل التحميل
          },
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
}
