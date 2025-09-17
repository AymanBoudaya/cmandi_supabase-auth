import 'package:caferesto/common/widgets/shimmer/shimmer_effect.dart';
import 'package:caferesto/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class THorizontalProductShimmer extends StatelessWidget {
  const THorizontalProductShimmer({super.key, this.itemCount = 4});
  final int itemCount;
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: AppSizes.spaceBtwSections),
        height: 120,
        child: ListView.separated(
            itemCount: itemCount,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSizes.spaceBtwItems),
            itemBuilder: (_, __) => const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TShimmerEffect(width: 120, height: 120),
                    SizedBox(height: AppSizes.spaceBtwItems),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: AppSizes.spaceBtwItems / 2),
                      ],
                    )
                  ],
                )));
  }
}
