import 'package:caferesto/common/widgets/appbar/appbar.dart';
import 'package:caferesto/common/widgets/icons/t_circular_icon.dart';
import 'package:caferesto/features/shop/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';


class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
   // final controller = FavoritesController.instance;
    return Scaffold(
        appBar: TAppBar(
          title: Text(
            'Favoris',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          actions: [
            TCircularIcon(
                icon: Iconsax.add,
                onPressed: () => Get.to(() => const HomeScreen())),
          ],
        ),

        /// Body
        body: const Text(
            'Favoris') /*SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(AppSizes.defaultSpace),

                /// Products Grid
                child: Column(
                  children: [
                    Obx(
                      () => FutureBuilder(
                          future: controller.favoriteProducts(),
                          builder: (context, snapshot) {
                            final emptyWidget = TAnimationLoaderWidget(
                                text: "La liste de favoris est vide !",
                                animation: TImages.pencilAnimation,
                                showAction: true,
                                actionText: "Ajoutons des favoris !",
                                onActionPressed: () =>
                                    Get.off(() => const NavigationMenu()));

                            const loader =
                                TVerticalProductShimmer(itemCount: 6);
                            final widget =
                                TCloudHelperFunctions.checkMultiRecordState(
                                    snapshot: snapshot,
                                    loader: loader,
                                    nothingFound: emptyWidget);
                            if (widget != null) return widget;

                            final products = snapshot.data!;
                            return GridLayout(
                                itemCount: products.length,
                                itemBuilder: (_, index) => ProductCardVertical(
                                      product: products[index],
                                    ));
                          }),
                    )
                  ],
                )))*/
        );
  }
}
