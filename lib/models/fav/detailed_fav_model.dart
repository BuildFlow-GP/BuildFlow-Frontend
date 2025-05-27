// view_models/detailed_favorite_item.dart (كمثال لاسم المجلد)
import 'userfav_model.dart';
// استيراد OfficeModel, CompanyModel, ProjectModel
import '../office_model.dart';
import '../company_model.dart';
import '../project_model.dart';

class DetailedFavoriteItem {
  final FavoriteItemModel favoriteInfo; // المعلومات الأساسية للمفضلة
  final dynamic itemDetail; // سيكون OfficeModel, CompanyModel, أو ProjectModel

  DetailedFavoriteItem({required this.favoriteInfo, required this.itemDetail});

  // يمكنك إضافة getters للوصول السهل للبيانات المشتركة
  String get itemName {
    if (itemDetail is OfficeModel) return (itemDetail as OfficeModel).name;
    if (itemDetail is CompanyModel) return (itemDetail as CompanyModel).name;
    if (itemDetail is ProjectModel) return (itemDetail as ProjectModel).name;
    return 'Unknown Item';
  }

  String? get itemImage {
    // افترض أن لديهم profileImage أو حقل مشابه
    if (itemDetail is OfficeModel)
      return (itemDetail as OfficeModel).profileImage;
    if (itemDetail is CompanyModel)
      return (itemDetail as CompanyModel).profileImage;
    // ProjectModel قد لا يحتوي على صورة رئيسية بنفس الطريقة
    return null;
  }

  // ... أي getters أخرى مشتركة أو خاصة بالنوع
}
