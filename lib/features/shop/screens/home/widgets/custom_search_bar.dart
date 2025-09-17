import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/search_controller.dart';
import '../../../models/product_model.dart';

class CustomSearchPage extends StatelessWidget {
  const CustomSearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductSearchController());
    //final allProductsController = AllProductsController.instance;
    Future.microtask(() async {
      //final results = await allProductsController.fetchProductsByQuery();
      //allProductsController.assignProducts(results);
    });
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Blur
          BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.transparent)),
          // Semi-transparent overlay
          Container(
            color: Colors.black.withAlpha((255 * 0.3).toInt()),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Hero(
                      tag: 'barre de recherche',
                      child: Material(
                          color: Colors.transparent,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          Colors.white
                                              .withAlpha((255 * 0.15).toInt()),
                                          Colors.white
                                              .withAlpha((255 * 0.05).toInt()),
                                        ]),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                            color: Colors.white
                                                .withAlpha((255 * 0.2).toInt()),
                                            width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withAlpha((255 * 0.1).toInt()),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          )
                                        ]),
                                    child: Row(
                                      children: [
                                        const Icon(Iconsax.search_normal_1,
                                            color: Colors.white, size: 22),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextField(
                                            controller:
                                                controller.searchController,
                                            onChanged: (val) =>
                                                controller.query.value = val,
                                            autofocus: true,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                            decoration: const InputDecoration(
                                                hintText: "Rechercher...",
                                                hintStyle: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 16),
                                                border: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.zero),
                                          ),
                                        ),
                                        Obx(() => controller.query.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(Icons.close,
                                                    color: Colors.white70,
                                                    size: 22),
                                                onPressed:
                                                    controller.clearSearch,
                                              )
                                            : const SizedBox())
                                      ],
                                    ),
                                  ))))),
                  const SizedBox(height: 25),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white));
                      }

                      if (controller.searchedProducts.isEmpty &&
                          controller.query.isNotEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildProductGrid(controller.searchedProducts);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.search_status,
              color: Colors.white.withAlpha(128), size: 64),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat trouvé',
            style: TextStyle(
                color: Colors.white.withAlpha((255 * 0.7).toInt()),
                fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(RxList<ProductModel> products) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((255 * 0.1).toInt()),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: Colors.white.withAlpha((255 * 0.15).toInt())),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    image: DecorationImage(
                      image: NetworkImage(product.thumbnail),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Product Details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        /*Icon(Iconsax.star1,
                            color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          product.rating?.toStringAsFixed(1) ?? '0.0',
                          style: TextStyle(
                              color: Colors.white.withAlpha((255 * 0.8).toInt()),
                              fontSize: 12),
                        ),
                        const Spacer(),*/
                        Text(
                          '${product.price.toStringAsFixed(2)} DT',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
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
