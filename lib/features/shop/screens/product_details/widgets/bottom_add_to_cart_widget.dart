import 'package:caferesto/common/widgets/icons/t_circular_icon.dart';
import 'package:caferesto/features/shop/controllers/product/cart_controller.dart';
import 'package:caferesto/utils/constants/colors.dart';
import 'package:caferesto/utils/constants/sizes.dart';
import 'package:caferesto/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/product_model.dart';

class TBottomAddToCart extends StatelessWidget {
  const TBottomAddToCart({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.defaultSpace,
          vertical: AppSizes.defaultSpace / 2),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkerGrey : AppColors.light,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.cardRadiusLg),
          topRight: Radius.circular(AppSizes.cardRadiusLg),
        ),
      ),
      child: Obx(() {
        final quantity = controller.getTempQuantity(product);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                TCircularIcon(
                  icon: Iconsax.minus,
                  backgroundColor: AppColors.darkGrey,
                  width: 40,
                  height: 40,
                  color: AppColors.white,
                  onPressed: () {
                    if (quantity > 0) {
                      controller.updateTempQuantity(product, quantity - 1);
                    }
                  },
                ),
                const SizedBox(width: AppSizes.spaceBtwItems),
                Text(
                  quantity.toString(),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(width: AppSizes.spaceBtwItems),
                TCircularIcon(
                  icon: Iconsax.add,
                  backgroundColor: AppColors.black,
                  width: 40,
                  height: 40,
                  color: AppColors.white,
                  onPressed: () {
                    controller.updateTempQuantity(product, quantity + 1);
                  },
                ),
              ],
            ),
            ElevatedButton(
              onPressed:
                  quantity < 1 ? null : () => controller.addToCart(product),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppSizes.md),
                backgroundColor: AppColors.black,
                side: const BorderSide(color: AppColors.black),
              ),
              child: const Text('Ajouter à la carte'),
            ),
          ],
        );
      }),
    );
  }
}
