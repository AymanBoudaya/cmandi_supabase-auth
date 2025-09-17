import 'package:caferesto/common/widgets/layouts/grid_layout.dart';
import 'package:caferesto/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:caferesto/features/shop/controllers/product/all_products_controller.dart';
import 'package:caferesto/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../features/shop/models/product_model.dart';

class TSortableProducts extends StatelessWidget {
  const TSortableProducts({
    super.key,
    required this.products,
  });

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    final controller = AllProductsController.instance;
    controller.assignProducts(products);
    return Column(
      children: [
        /// DropDown
        DropdownButtonFormField(
            decoration: const InputDecoration(prefixIcon: Icon(Iconsax.sort)),
            items: [
              'Nom',
              'Prix croissant',
              'Prix décroissant',
              'Récent',
              'Ventes',
            ]
                .map((option) =>
                    DropdownMenuItem(value: option, child: Text(option)))
                .toList(),
            initialValue: controller.selectedSortOption.value,
            onChanged: (value) {
              controller.sortProducts(value!);
            }),
        const SizedBox(height: AppSizes.spaceBtwSections),

        /// Products
        Obx(
          () => GridLayout(
              itemCount: controller.products.length,
              itemBuilder: (_, index) =>
                  ProductCardVertical(product: controller.products[index])),
        )
      ],
    );
  }
}
