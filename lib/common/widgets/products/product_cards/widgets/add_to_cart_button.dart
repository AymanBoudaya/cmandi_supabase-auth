import 'package:caferesto/features/shop/screens/product_details/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../features/shop/controllers/product/cart_controller.dart';
import '../../../../../features/shop/models/product_model.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';

class ProductCardAddToCartButton extends StatelessWidget {
  const ProductCardAddToCartButton({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final cartController = CartController.instance;
    return Obx(() {
      final productQuantityInCart =
          cartController.getProductQuantityInCart(product.id);

      return GestureDetector(
        onTap: () {
          if (product.productType == ProductType.single.toString()) {
            final cartItem = cartController.productToCartItem(product, 1);
            cartController.addOneToCart(cartItem);
          } else {
            Get.to(() => ProductDetailScreen(product: product));
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: productQuantityInCart > 0 ? 36 : 32,
          height: 32,
          decoration: BoxDecoration(
            color: productQuantityInCart > 0
                ? AppColors.primary
                : AppColors.dark.withAlpha((255 * 0.8).toInt()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: productQuantityInCart > 0
                ? Text(
                    productQuantityInCart.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  )
                : const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
          ),
        ),
      );
    });
  }
}
