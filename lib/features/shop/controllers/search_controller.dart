import 'dart:async';

import 'package:caferesto/features/shop/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'product/all_products_controller.dart';

class Query {
  final String keyword;
  Query(this.keyword);
}

class ProductSearchController extends GetxController {
  final RxString query = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final allProductsController = Get.put(AllProductsController());
  final RxList<ProductModel> searchedProducts = <ProductModel>[].obs;

  final RxBool isLoading = false.obs;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    _onSearchChanged(); // Initial trigger
  }

  void _onSearchChanged() {
    final text = searchController.text;
    query.value = text;

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (text.isEmpty) {
        searchedProducts.assignAll(allProductsController.products);
      } else {
        isLoading.value = true;
        // final queryObject = Query(text);
        //final results = await allProductsController.fetchProductsByQuery(queryObject);
        // searchedProducts.assignAll(results);
        isLoading.value = false;
      }
    });
  }

  void clearSearch() {
    query.value = '';
    searchController.clear();
    searchedProducts.assignAll(allProductsController.products);
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }
}
