import 'package:caferesto/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:caferesto/common/widgets/layouts/grid_layout.dart';
import 'package:caferesto/common/widgets/products/cart/cart_menu_icon.dart';
import 'package:caferesto/common/widgets/brands/brand_card.dart';
import 'package:caferesto/common/widgets/shimmer/brands_shimmer.dart';
import 'package:caferesto/common/widgets/texts/section_heading.dart';
import 'package:caferesto/features/shop/controllers/brand_controller.dart';
import 'package:caferesto/features/shop/screens/brand/all_brands.dart';
import 'package:caferesto/features/shop/screens/brand/brand_products.dart';
import 'package:caferesto/utils/constants/sizes.dart';
import 'package:caferesto/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/appbar/tabbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../controllers/category_controller.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brandController = Get.put(BrandController());
    final categories = CategoryController.instance.featuredCategories;
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
          appBar: TAppBar(
            title: Text(
              'Store',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            actions: [
              TCartCounterIcon(
                iconColor: AppColors.primary,
                counterBgColor: AppColors.primary,
              )
            ],
          ),
          body: NestedScrollView(

              /// Header
              headerSliverBuilder: (_, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    expandedHeight: 440,
                    // Space between appBar and TabBar
                    automaticallyImplyLeading: false,
                    backgroundColor: THelperFunctions.isDarkMode(context)
                        ? AppColors.black
                        : AppColors.white,

                    flexibleSpace: Padding(
                      padding: const EdgeInsets.all(AppSizes.defaultSpace),
                      child: ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          /// -- SearchBar
                          const SizedBox(
                            height: AppSizes.spaceBtwItems,
                          ),
                          const TSearchContainer(
                            text: 'Rechercher un produit',
                            showBorder: true,
                            showBackground: false,
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(
                            height: AppSizes.spaceBtwSections,
                          ),

                          /// -- Featured Brands
                          TSectionHeading(
                            title: 'Marques Populaires',
                            onPressed: () =>
                                Get.to(() => const AllBrandsScreen()),
                          ),
                          const SizedBox(
                            height: AppSizes.spaceBtwItems / 1.5,
                          ),

                          /// -- Brands Grid
                          Obx(() {
                            if (brandController.isLoading.value) {
                              return const TbrandsShimmer();
                            }

                            if (brandController.featuredBrands.isEmpty) {
                              return Center(
                                  child: Text('Aucune marque trouvée',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .apply(color: Colors.white)));
                            }
                            return GridLayout(
                                itemCount:
                                    brandController.featuredBrands.length,
                                mainAxisExtent: 80,
                                itemBuilder: (_, index) {
                                  final brand =
                                      brandController.featuredBrands[index];
                                  return BrandCard(
                                      showBorder: true,
                                      brand: brand,
                                      onTap: () => Get.to(
                                          () => BrandProducts(brand: brand)));
                                });
                          }),
                        ],
                      ),
                    ),

                    /// TABS
                    bottom: Tabbar(
                        tabs: categories
                            .map((category) => Tab(
                                  child: Text(
                                    category.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .apply(color: AppColors.primary),
                                  ),
                                ))
                            .toList()),
                    /*
                    [

                    ] */
                  )
                ];
              },
              body: TabBarView(
                children: categories
                    .map((category) => Tab(
                          child: Text(
                            category.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .apply(color: AppColors.primary),
                          ),
                        ))
                    .toList(),
              ))),
    );
  }
}
