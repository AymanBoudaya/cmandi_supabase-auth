import 'package:flutter/material.dart';

import '../../../features/shop/models/brand_model.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/sizes.dart';
import '../images/circular_image.dart';
import '../products/product_cards/widgets/rounded_container.dart';
import '../texts/brand_title_text_with_verified_icon.dart';

class BrandCard extends StatelessWidget {
  const BrandCard({
    super.key,
    required this.showBorder,
    this.onTap,
    required this.brand,
  });

  final BrandModel brand;
  final bool showBorder;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TRoundedContainer(
        padding: const EdgeInsets.all(AppSizes.sm),
        showBorder: showBorder,
        backgroundColor: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Icone
            CircularImage(
              isNetworkImage: true,
              image: brand.image,
              backgroundColor: Colors.transparent,
              width: 50,
              height: 50,
              padding: 2,
              // overlayColor: THelperFunctions.isDarkMode(context)
              //     ? AppColors.white
              //     : AppColors.black,
            ),
            const SizedBox(width: AppSizes.spaceBtwItems / 2),

            /// Texte
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        child: BrandTitleWithVerifiedIcon(
                          title: brand.name,
                          brandTextSize: TexAppSizes.large,
                        ),
                      );
                    },
                  ),
                  // Nombre de Produits
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        child: Text(
                          '${brand.productsCount ?? 0} produits',
                          style: Theme.of(context).textTheme.labelMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
