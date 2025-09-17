import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/shop/models/product_model.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../../upload/upload_dummy_products.dart';

class ProductRepository extends GetxController {
  static ProductRepository get instance => Get.find();

  /// Supabase client instance
  final _db = Supabase.instance.client;

  /// Get limited featured products
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final response = await _db
          .from('products')
          .select('*, brands(*)')
          .eq('is_featured', true)
          .limit(4)
          .order('created_at', ascending: false);
      return response.map((json) => ProductModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'Echec de chargement des produits en vedette : ${e.toString()}';
    }
  }

  Future<List<ProductModel>> getAllFeaturedProducts() async {
    try {
      final response = await _db
          .from('products')
          .select('*, brands(*)')
          .eq('is_featured', true)
          .order('Title');
      return response.map((json) => ProductModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'Echec de chargement des produits en vedette : ${e.toString()}';
    }
  }

  Future<List<ProductModel>> fetchProductsByQuery(
      Map<String, dynamic> query) async {
    try {
      PostgrestFilterBuilder request = _db.from('Products').select();

      query.forEach((key, value) {
        if (value is List) {
          request = request.inFilter(key, value);
        } else {
          request = request.eq(key, value);
        }
      });

      final response = await request;
      return response.map((json) => ProductModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw 'Query error: ${e.message}';
    } catch (e) {
      throw 'Something went wrong! Please try again';
    }
  }

  Future<List<ProductModel>> getFavoriteProducts(
      List<String> productIds) async {
    if (productIds.isEmpty) return [];

    try {
      final chunks = _chunkList(productIds, 100);
      List<ProductModel> allProducts = [];

      for (final chunk in chunks) {
        final response =
            await _db.from('products').select().inFilter('id', chunk);

        allProducts.addAll(
            response.map((json) => ProductModel.fromJson(json)).toList());
      }
      return allProducts;
    } on PostgrestException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'Echec de chargement des produits favoris :${e.toString()}';
    }
  }

  Future<List<ProductModel>> getProductsForBrand(
      {required String brandId, int limit = -1}) async {
    try {
      final query =
          _db.from('products').select().eq('Brand.id', brandId).order('Title');

      final response = limit == -1 ? await query : await query.limit(limit);
      return response.map((json) => ProductModel.fromJson(json)).toList();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong! Please try again';
    }
  }

  Future<List<ProductModel>> getProductsForCategory(
      {required String categoryId, int limit = -1}) async {
    try {
      final productCategoryRes = await _db
          .from('ProductCategory')
          .select('ProductId')
          .eq('categoryId', categoryId);

      if (productCategoryRes.isEmpty) return [];

      final productIds =
          productCategoryRes.map((e) => e['ProductId'] as String).toList();

      // Split into chunks
      final chunks = _chunkList(productIds, 100);
      List<ProductModel> products = [];

      for (final chunk in chunks) {
        final response =
            await _db.from('Products').select().inFilter('Id', chunk);

        products.addAll(
            response.map((json) => ProductModel.fromJson(json)).toList());
      }

      return limit == -1 ? products : products.take(limit).toList();
    } on PostgrestException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'Something went wrong! Please try again';
    }
  }

  /// Upload dummy data to the Cloud Firebase
  Future<void> uploadDummyData() async {
    try {
      final dummyProducts = StoreProducts.dummyProducts;
      final chunks = _chunkList(dummyProducts, 100); // Supabase batch limit

      for (final chunk in chunks) {
        final data = chunk.map((product) => product.toJson()).toList();
        await _db.from('products').insert(data);
      }
    } on PostgrestException catch (e) {
      throw 'Upload failed: ${e.message}';
    } catch (e) {
      throw 'Something went wrong! Please try again.';
    }
  }

  // Helper to split lists into chunks
  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(
          i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }
}
