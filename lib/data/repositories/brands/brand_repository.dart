import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/shop/models/brand_model.dart';
import '../../../utils/exceptions/format_exceptions.dart';

class BrandRepository extends GetxController {
  static BrandRepository get instance => Get.find();

  /// Variables

  final _db = Supabase.instance.client;

  /// Get all brands
  Future<List<BrandModel>> getAllBrands() async {
    try {
      final response = await _db
          .from('brands')
          .select()
          .withConverter<List<BrandModel>>((data) {
        return data.map((e) => BrandModel.fromMap(e)).toList();
      });

      return response;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PostgrestException catch (e) {
      throw 'Erreur Supabase: ${e.message}';
    } catch (e) {
      print(e);
      throw 'Quelque chose s\'est mal passée lors de la récupération des marques $e';
    }
  }

  Future<List<BrandModel>> getBrandsForCategory(String categoryId) async {
    try {
      // 1. Récupération des IDs de marques associées à la catégorie
      final brandCategories = await _db
          .from('BrandCategory')
          .select('brandId')
          .eq('categoryId', categoryId);

      // Extraction des IDs
      final brandIds = brandCategories
          .map<String>((item) => item['brandId'] as String)
          .toList();

      // 2. Récupération des marques correspondantes
      if (brandIds.isEmpty) return [];

      final response = await _db
          .from('brands')
          .select()
          .inFilter('id', brandIds)
          .limit(2)
          .withConverter<List<BrandModel>>((data) {
        return data.map((e) => BrandModel.fromMap(e)).toList();
      });
      return response;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PostgrestException catch (e) {
      throw 'Erreur Supabase: ${e.message}';
    } catch (e) {
      throw 'Quelque chose s\'est mal passée lors de la récupération des bannières.';
    }
  }
}
