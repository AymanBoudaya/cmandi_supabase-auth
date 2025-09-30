import 'package:caferesto/utils/exceptions/supabase_exception.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/shop/models/category_model.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../upload/upload_categories.dart';

class CategoryRepository extends GetxController {
  static CategoryRepository get instance => Get.find();

  /// Variables
  final _db = Supabase.instance.client;
  final _table = 'categories';

  /// Charger toutes les categories
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response =
          await _db.from(_table).select().order('name', ascending: true);
      return response
          .map((category) => CategoryModel.fromJson(category))
          .toList();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Echec de récupération des catégories : $e';
    }
  }

  /// Charger sous-categories
  Future<List<CategoryModel>> getSubCategories(String categoryId) async {
    try {
      final response = await _db
          .from(_table)
          .select()
          .eq('parentId', categoryId)
          .order('name', ascending: true);
      return response
          .map((category) => CategoryModel.fromJson(category))
          .toList();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Echec de récupération des catégories : ${e.toString()}';
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      final response = await _db.from(_table).insert(category.toJson());
      if (response.error != null) {
        throw response.error!.message;
      }
    } on SupabaseException catch (e) {
      throw SupabaseException(e.code).message;
    } on PostgrestException catch (e) {
      throw 'Erreur base de données : ${e.code} - ${e.message}';
    } catch (e) {
      print(e);
      throw 'Erreur lors ajout categorie : ${e} }';
    }
  }

  Future<void> uploadDummyCategories() async {
    try {
      final categories = UploadCategories.dummyCategories;

      final insertData =
          categories.map((category) => category.toJson()).toList();
      final response = await _db.from(_table).insert(insertData);

      if (response.error != null) {
        throw response.error!.message;
      }
    } on SupabaseException catch (e) {
      throw SupabaseException(e.code).message;
    } on PostgrestException catch (e) {
      throw 'DB Error: ${e.code} - ${e.message}';
    } catch (e) {
      throw 'Something went wrong! Please try again.';
    }
  }
}
