import 'package:caferesto/common/widgets/appbar/appbar.dart';
import 'package:caferesto/common/widgets/brands/brand_card.dart';
import 'package:caferesto/common/widgets/products/sortable/sortable_products.dart';
import 'package:caferesto/utils/constants/sizes.dart';
import 'package:caferesto/utils/helpers/cloud_helper_functions.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/shimmer/vertical_product_shimmer.dart';
import '../../controllers/brand_controller.dart';
import '../../models/brand_model.dart';

class BrandProducts extends StatelessWidget {
  const BrandProducts({super.key, required this.brand});

  final BrandModel brand;

  @override
  Widget build(BuildContext context) {
    final controller = BrandController.instance;
    return Scaffold(
      appBar: TAppBar(
        title: Text(brand.name),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.all(AppSizes.defaultSpace),
        child: Column(
          children: [
            /// Details de marques
            BrandCard(
              showBorder: true,
              brand: brand,
            ),
            SizedBox(
              height: AppSizes.spaceBtwSections,
            ),
            FutureBuilder(
                future: controller.getBrandProducts(brandId: brand.id),
                builder: (context, snapshot) {
                  /// Handle loader , No record, Or Error Message
                  const loader = TVerticalProductShimmer();
                  final widget = TCloudHelperFunctions.checkMultiRecordState(
                      snapshot: snapshot, loader: loader);
                  if (widget != null) return widget;

                  /// Records found
                  final brandProducts = snapshot.data!;
                  return TSortableProducts(products: brandProducts);
                })
          ],
        ),
      )),
    );
  }
}
