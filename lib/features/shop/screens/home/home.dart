import 'package:caferesto/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/shimmer/vertical_product_shimmer.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../authentication/screens/home/widgets/home_categories.dart';
import '../../controllers/product/product_controller.dart';
import '../all_products/all_products.dart';
import 'widgets/home_appbar.dart';
import 'widgets/promo_slider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Primary Header Container
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  /// AppBar
                  const THomeAppBar(),
                  const SizedBox(height: AppSizes.spaceBtwSections),

                  /// Categories
                  TSectionHeading(
                    title: 'Catégories Populaires',
                    showActionButton: true,
                  ),
                  const SizedBox(
                    height: AppSizes.spaceBtwItems,
                  ),

                  /// Categories List
                  THomeCategories(),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                ],
              ),
            ),

            /// Body
            Padding(
                padding: const EdgeInsets.all(AppSizes.defaultSpace),
                child: Column(
                  children: [
                    /// --PromoSlider
                    const TPromoSlider(
                      banners: [
                        TImages.promoBanner1,
                        TImages.promoBanner2,
                        TImages.promoBanner3
                      ],
                    ),
                    const SizedBox(
                      height: AppSizes.spaceBtwSections,
                    ),

                    /// -- Heading
                    TSectionHeading(
                      title: 'Produits Populaires',
                      onPressed: () => Get.to(() => AllProducts(
                          title: 'Produits populaires',
                          futureMethod: controller.fetchAllFeaturedProducts())),
                    ),
                    const SizedBox(
                      height: AppSizes.spaceBtwItems,
                    ),

                    /// Popular products
                    Obx(() {
                      if (controller.isLoading.value) {
                        return const TVerticalProductShimmer();
                      }
                      if (controller.featuredProducts.isEmpty) {
                        return const Center(
                          child: Text('Aucun produit trouvé'),
                        );
                      }
                      return GridLayout(
                        itemCount: controller.featuredProducts.length,
                        itemBuilder: (_, index) => ProductCardVertical(
                          product: controller.featuredProducts[index],
                        ),
                      );
                    })
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
