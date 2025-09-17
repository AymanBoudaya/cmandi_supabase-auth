import 'package:caferesto/features/shop/controllers/product/order_controller.dart';
import 'package:caferesto/utils/constants/colors.dart';
import 'package:caferesto/utils/constants/sizes.dart';
import 'package:caferesto/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/products/product_cards/widgets/rounded_container.dart';
import '../../../../../navigation_menu.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/helpers/cloud_helper_functions.dart';
import '../../../../../utils/loaders/animation_loader.dart';

class TOrderListItems extends StatelessWidget {
  const TOrderListItems({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final controller = Get.put(OrderController());
    return FutureBuilder(
        future: controller.fetchUserOrders(),
        builder: (_, snapshot) {
          final emptyWidget = TAnimationLoaderWidget(
            text: "Aucune commande",
            animation: TImages.orderCompletedAnimation,
            showAction: true,
            actionText: 'Ajouter des commandes',
            onActionPressed: () => Get.off(() => const NavigationMenu()),
          );

          final response = TCloudHelperFunctions.checkMultiRecordState(
              snapshot: snapshot, nothingFound: emptyWidget);
          if (response != null) return response;

          final orders = snapshot.data!;
          return ListView.separated(
              shrinkWrap: true,
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(
                    height: AppSizes.spaceBtwItems,
                  ),
              itemBuilder: (_, index) {
                final order = orders[index];
                return TRoundedContainer(
                    showBorder: true,
                    padding: const EdgeInsets.all(AppSizes.md),
                    backgroundColor: dark ? AppColors.dark : AppColors.light,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      /// -- Row 1
                      Row(children: [
                        /// Icon
                        const Icon(Iconsax.ship),
                        const SizedBox(
                          width: AppSizes.spaceBtwItems / 2,
                        ),

                        /// Status and Date
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.orderStatusText,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .apply(
                                        color: AppColors.primary,
                                        fontWeightDelta: 1),
                              ),
                              Text(
                                order.formattedOrderDate,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              )
                            ],
                          ),
                        ),

                        /// Icon
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Iconsax.arrow_right_34,
                                size: AppSizes.iconSm)),
                      ]),
                      const SizedBox(
                        height: AppSizes.spaceBtwItems,
                      ),

                      /// -- Row 2
                      Row(
                        children: [
                          Expanded(
                            child: Row(children: [
                              /// Icon
                              const Icon(Iconsax.tag),
                              const SizedBox(
                                width: AppSizes.spaceBtwItems / 2,
                              ),

                              /// Status and Date
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Commande',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium),
                                    Text(
                                      order.id,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    )
                                  ],
                                ),
                              ),
                            ]),
                          ),
                          Expanded(
                            child: Row(children: [
                              /// Icon
                              const Icon(Iconsax.calendar),
                              const SizedBox(
                                width: AppSizes.spaceBtwItems / 2,
                              ),

                              /// Status and Date
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Date de livraison',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium),
                                    Text(
                                      order.formattedDeliveryDate,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    )
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        ],
                      )
                    ]));
              });
        });
  }
}
