import 'package:caferesto/common/widgets/layouts/grid_layout.dart';
import 'package:caferesto/common/widgets/texts/section_heading.dart';
import 'package:caferesto/features/shop/controllers/category_controller.dart';
import 'package:caferesto/features/shop/screens/all_products/all_products.dart';
import 'package:caferesto/features/shop/screens/store/widgets/category_brands.dart';
import 'package:caferesto/utils/helpers/cloud_helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/products/product_cards/product_card_vertical.dart';
import '../../../../../common/widgets/shimmer/vertical_product_shimmer.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/category_model.dart';

class CategoryTab extends StatelessWidget {
  const CategoryTab({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final controller = CategoryController.instance;
    return ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.defaultSpace),
            child: Column(
              children: [
                /// Brands
                CategoryBrands(category: category),
                const SizedBox(
                  height: AppSizes.spaceBtwItems,
                ),

                /// Products
                FutureBuilder(
                    future:
                        controller.getCategoryProducts(categoryId: category.id),
                    builder: (context, snapshot) {
                      /// Handle loader , No record, Or Error Message
                      final response =
                          TCloudHelperFunctions.checkMultiRecordState(
                              snapshot: snapshot,
                              loader: const TVerticalProductShimmer());
                      if (response != null) return response;

                      /// Records found
                      final products = snapshot.data!;

                      return Column(
                        children: [
                          TSectionHeading(
                            title: "Vous aimez peut être",
                            onPressed: () => Get.to(
                              () => AllProducts(
                                title: category.name,
                                futureMethod: controller.getCategoryProducts(
                                    categoryId: category.id, limit: -1),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: AppSizes.spaceBtwItems,
                          ),
                          GridLayout(
                            itemCount: products.length,
                            itemBuilder: (_, index) =>
                                ProductCardVertical(product: products[index]),
                          ),
                          const SizedBox(
                            height: AppSizes.spaceBtwSections,
                          ),
                        ],
                      );
                    }),
              ],
            ),
          ),
        ]);
  }
}
