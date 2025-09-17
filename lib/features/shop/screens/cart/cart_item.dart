import 'package:caferesto/common/widgets/images/t_rounded_image.dart';
import 'package:caferesto/common/widgets/texts/brand_title_text_with_verified_icon.dart';
import 'package:caferesto/common/widgets/texts/product_title_text.dart';
import 'package:caferesto/features/shop/models/cart_item_model.dart';
import 'package:caferesto/utils/constants/colors.dart';
import 'package:caferesto/utils/constants/sizes.dart';
import 'package:caferesto/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

class TCartItem extends StatelessWidget {
  const TCartItem({
    super.key,
    required this.cartItem,
  });

  final CartItemModel cartItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          /// Image
          TRoundedImage(
            imageUrl: cartItem.image ?? '',
            width: 60,
            height: 60,
            isNetworkImage: true,
            padding: EdgeInsets.all(AppSizes.sm),
            backgroundColor: THelperFunctions.isDarkMode(context)
                ? AppColors.darkerGrey
                : AppColors.light,
          ),
          const SizedBox(
            width: AppSizes.spaceBtwItems,
          ),

          /// Title , Price & size
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BrandTitleWithVerifiedIcon(title: cartItem.brandName ?? ''),
                Flexible(
                  child: TProductTitleText(
                    title: cartItem.title,
                    maxLines: 1,
                  ),
                ),

                /// Attributes
                Text.rich(TextSpan(
                  children: (cartItem.selectedVariation ?? {})
                      .entries
                      .map((entry) => TextSpan(children: [
                            TextSpan(
                              text: '${entry.key} ',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            TextSpan(
                              text: '${entry.value} ',
                              style: Theme.of(context).textTheme.bodyLarge,
                            )
                          ]))
                      .toList(),
                ))
              ],
            ),
          )
        ],
      ),
    );
  }
}
