import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/texts/product_price_text.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/product/cart_controller.dart';
import '../add_remove_button.dart';
import '../cart_item.dart';

class TCartItems extends StatelessWidget {
  const TCartItems({super.key, this.showAddRemoveButtons = true});
  final bool showAddRemoveButtons;

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    return Obx(
      () => ListView.separated(
        shrinkWrap: true,
        itemCount: cartController.cartItems.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSizes.spaceBtwSections),
        itemBuilder: (_, index) => Obx(() {
          final item = cartController.cartItems[index];
          return Column(
            children: [
              /// Cart Item
              TCartItem(
                cartItem: item,
              ),
              if (showAddRemoveButtons)
                const SizedBox(
                  height: AppSizes.spaceBtwItems,
                ),
              if (showAddRemoveButtons)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Extra Space
                      const SizedBox(
                        width: 70,
                      ),

                      /// Add Remove Buttons
                      TProductQuantityWithAddRemoveButton(
                        quantity: item.quantity,
                        add: () => cartController.addOneToCart(item),
                        remove: () => cartController.removeOneFromCart(item),
                      ),
                      Spacer(),

                      /// Product total price
                      ProductPriceText(
                        price: (item.price * item.quantity).toStringAsFixed(1),
                      )
                    ],
                  ),
                )
            ],
          );
        }),
      ),
    );
  }
}
