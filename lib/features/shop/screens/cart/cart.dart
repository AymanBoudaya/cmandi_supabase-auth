import 'package:caferesto/features/shop/controllers/product/cart_controller.dart';
import 'package:caferesto/features/shop/screens/cart/widgets/cart_items.dart';
import 'package:caferesto/features/shop/screens/checkout/checkout.dart';
import 'package:caferesto/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../navigation_menu.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/loaders/animation_loader.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CartController.instance;
    return Scaffold(
      appBar: TAppBar(
          showBackArrow: true,
          title:
              Text('Panier', style: Theme.of(context).textTheme.headlineSmall)),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {}

        final emptyWidget = TAnimationLoaderWidget(
          text: "Le panier est vide !",
          animation: TImages.pencilAnimation,
          showAction: true,
          actionText: 'Ajouter des produits',
          onActionPressed: () => Get.off(() => const NavigationMenu()),
        );
        if (controller.cartItems.isEmpty) {
          return emptyWidget;
        } else {
          return SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(AppSizes.defaultSpace),

                /// Items in cart
                child: TCartItems()),
          );
        }
      }),
      bottomNavigationBar: controller.cartItems.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: ElevatedButton(
                  onPressed: () => Get.to(() => const CheckoutScreen()),
                  child: Obx(() =>
                      Text('Commander ${controller.totalCartPrice.value} DT'))),
            ),
    );
  }
}
