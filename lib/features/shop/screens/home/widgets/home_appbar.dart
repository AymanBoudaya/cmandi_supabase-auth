import 'package:caferesto/features/personalization/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/products/cart/cart_menu_icon.dart';
import '../../../../../common/widgets/shimmer/shimmer_effect.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/text_strings.dart';
import 'custom_search_bar.dart';

class THomeAppBar extends StatelessWidget {
  const THomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    return TAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            if (controller.profileLoading.value) {
              return const TShimmerEffect(width: 80, height: 15);
            } else {
              return Text(TTexts.homeAppbarSubTitle,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .apply(color: AppColors.grey));
            }
          }),
          Obx(() {
            if (controller.profileLoading.value) {
              return const TShimmerEffect(width: 80, height: 15);
            } else {
              return Text(controller.user.value.fullName,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .apply(color: AppColors.grey));
            }
          }),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Iconsax.search_normal_1, color: Colors.white),
          onPressed: () {
            Get.to(() => const CustomSearchPage(),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 300),
                opaque: false,
                routeName: '/search');
          },
        ),
        TCartCounterIcon(
            counterBgColor: AppColors.black,
            counterTextColor: AppColors.white,
            iconColor: AppColors.white)
      ],
    );
  }
}
