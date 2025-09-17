// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:caferesto/common/widgets/images/t_rounded_image.dart';
import 'package:caferesto/common/widgets/products/favorite_icon/favorite_icon.dart';
import 'package:caferesto/features/shop/controllers/product/product_controller.dart';
import 'package:caferesto/utils/constants/colors.dart';
import 'package:caferesto/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../features/shop/models/product_model.dart';
import '../../../../features/shop/screens/product_details/product_detail.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../styles/shadows.dart';
import '../../texts/brand_title_text_with_verified_icon.dart';
import '../../texts/product_price_text.dart';
import '../../texts/product_title_text.dart';
import 'widgets/add_to_cart_button.dart';

class ProductCardVertical extends StatelessWidget {
  const ProductCardVertical({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;
    final salePercentage =
        controller.calculateSalePercentage(product.price, product.salePrice);
    final dark = THelperFunctions.isDarkMode(context);
    return GestureDetector(
        onTap: () => Get.to(() => ProductDetailScreen(
              product: product,
            )),
        child: Container(
            width: 170,
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: dark ? AppColors.eerieBlack : AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.defaultSpace),
              boxShadow: [TShadowStyle.vericalCardProductShadow],
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              /// Thumbnail
              Stack(
                children: [
                  /// -- Thumbnail Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: TRoundedImage(
                      imageUrl: product.thumbnail,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      applyImageRadius: false,
                    ),
                  ),

                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: Stack(children: [
                        Positioned(
                            // -- Blur effect
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 50,
                            child: ClipRect(
                                child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 2.5, sigmaY: 2.5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                            Colors.white.withAlpha(
                                                (255 * 0.15).toInt()),
                                            Colors.white.withOpacity(0.01),
                                          ])),
                                    )))),

                        /// Sale Tag
                        if (salePercentage != null)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppSizes.xs,
                                  horizontal: AppSizes.sm),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(
                                    AppSizes.buttonRadius),
                              ),
                              child: Text(
                                '- $salePercentage%',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.2),
                              ),
                            ),
                          ),

                        /// -- Favorite Icon Button
                        Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                                decoration: BoxDecoration(
                                  color: dark
                                      ? Colors.black
                                          .withAlpha((255 * 0.3).toInt())
                                      : AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: FavoriteIcon(productId: product.id)))
                      ]),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: AppSizes.spaceBtwItems / 2,
              ),

              // Product info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BrandTitleWithVerifiedIcon(
                      title: product.brand?.name ?? 'Unknown',
                      textColor: dark ? Colors.white70 : Colors.grey[700],
                    ),
                    const SizedBox(
                      height: AppSizes.spaceBtwItems / 2,
                    ),

                    /// Title
                    TProductTitleText(
                      title: product.title,
                      maxLines: 2,
                      smallSize: true,
                    ),
                  ],
                ),
              ),

              // Price and cart button
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.productType ==
                                  ProductType.single.toString() &&
                              product.salePrice > 0)
                            Text(
                              '${product.price} DT',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                            ),
                          ProductPriceText(
                            price: controller.getProductPrice(product),
                            isLarge: false,
                          ),
                        ],
                      ),
                    ),
                    ProductCardAddToCartButton(product: product),
                  ],
                ),
              ),
            ])));
  }
}
