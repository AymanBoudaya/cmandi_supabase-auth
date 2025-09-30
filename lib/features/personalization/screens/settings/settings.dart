import 'package:caferesto/common/widgets/appbar/appbar.dart';
import 'package:caferesto/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:caferesto/common/widgets/texts/section_heading.dart';
import 'package:caferesto/features/personalization/screens/categories/add_category_screen.dart';
import 'package:caferesto/features/personalization/screens/profile/profile.dart';
import 'package:caferesto/features/shop/screens/order/order.dart';
import 'package:caferesto/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/list_tiles/settings_menu_tile.dart';
import '../../../../common/widgets/list_tiles/user_profile_tile.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../data/repositories/categories/category_repository.dart';
import '../../../../data/repositories/product/product_repository.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/user_controller.dart';
import '../address/address.dart';
import '../brands/add_brand_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProductRepository.instance;
    final categoryController = CategoryRepository.instance;
    final userController = Get.put(UserController());

    bool canAddCategory() {
      final role = userController.user.value.role;
      return role == 'Gérant' || role == 'Admin';
    }

    void uploadDummyData() async {
      try {
        await controller.uploadDummyData();
        Get.snackbar("Succès", "Données factices chargées avec succès",
            snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar("Erreur", e.toString(),
            snackPosition: SnackPosition.BOTTOM);
      }
    }

    void uploadDummyCategories() async {
      try {
        await categoryController.uploadDummyCategories();
        Get.snackbar("Succès", "Catégories factices chargées avec succès",
            snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar("Erreur", e.toString(),
            snackPosition: SnackPosition.BOTTOM);
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          /// En tete
          TPrimaryHeaderContainer(
            child: Column(
              children: [
                TAppBar(
                    title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Compte',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .apply(color: AppColors.white)),
                    Text(
                      userController.user.value.role,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall!.apply(color: AppColors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )),

                /// Carte du profil avec nom et email
                TUserProfileTile(
                    onPressed: () => Get.to(() => const ProfileScreen())),
                const SizedBox(height: AppSizes.spaceBtwSections),
              ],
            ),
          ),

          Padding(
              padding: EdgeInsets.all(AppSizes.defaultSpace),
              child: Column(children: [
                /// Paramètres du compte
                TSectionHeading(
                  title: "Réglages du compte",
                  showActionButton: false,
                ),
                SizedBox(height: AppSizes.spaceBtwItems),

                TSettingsMenuTile(
                    title: "Mes Adresses",
                    subTitle: "Mes adresses de livraison",
                    icon: Iconsax.safe_home,
                    onTap: () => Get.to(() => const UserAddressScreen())),
                TSettingsMenuTile(
                    title: "Mon Panier",
                    subTitle: "Ajouter, modifier ou supprimer des articles",
                    icon: Iconsax.shopping_cart,
                    onTap: () {}),
                TSettingsMenuTile(
                    title: "Mes Commandes",
                    subTitle: "Commandes passées et en cours",
                    icon: Iconsax.bag_tick,
                    onTap: () => Get.to(() => const OrderScreen())),
                TSettingsMenuTile(
                    title: "Compte Bancaire",
                    subTitle: "Mes informations bancaires",
                    icon: Iconsax.bank,
                    onTap: () {}),
                TSettingsMenuTile(
                    title: "Mes Vouchers",
                    subTitle: "Mes bons de réduction",
                    icon: Iconsax.discount_shape,
                    onTap: () {}),
                TSettingsMenuTile(
                    title: "Notifications",
                    subTitle: "Notifications de l'application",
                    icon: Iconsax.notification,
                    onTap: () {}),
                TSettingsMenuTile(
                    title: "Sécurité du Compte",
                    subTitle: "Sécuriser mon compte",
                    icon: Iconsax.security_card,
                    onTap: () {}),

                /// Paramètres de l'app
                SizedBox(height: AppSizes.spaceBtwSections),
                TSectionHeading(title: "Paramètres", showActionButton: false),
                SizedBox(height: AppSizes.spaceBtwItems),
                TSettingsMenuTile(
                    icon: Iconsax.location,
                    title: "Géolocalisation",
                    subTitle:
                        "Définir une recommandation à partir de ma position",
                    trailing: Switch(value: true, onChanged: (value) {})),
                TSettingsMenuTile(
                    icon: Iconsax.security_user,
                    title: "Géolocalisation",
                    subTitle:
                        "Résultats de recherche sans danger pour tous les âges",
                    trailing: Switch(value: false, onChanged: (value) {})),
                TSettingsMenuTile(
                    icon: Iconsax.image,
                    title: "Qualité image HD",
                    subTitle: "Définir la qualité d'image haute définition",
                    trailing: Switch(value: false, onChanged: (value) {})),

                /// Développeur , upload
                SizedBox(height: AppSizes.spaceBtwSections),
                TSectionHeading(
                    title: "Développement", showActionButton: false),
                SizedBox(height: AppSizes.spaceBtwItems),
                TSettingsMenuTile(
                  icon: Iconsax.document_upload,
                  title: "Charger des données factices",
                  subTitle: "Insère des données test dans l'application",
                  onTap: uploadDummyData,
                ),
                SizedBox(height: AppSizes.spaceBtwItems),
                if (canAddCategory())
                  TSettingsMenuTile(
                    icon: Iconsax.add,
                    title: "Ajouter une catégorie",
                    subTitle: "Insère une nouvelle catégorie",
                    onTap: () => Get.to(() => AddCategoryScreen()),
                  ),
                SizedBox(height: AppSizes.spaceBtwItems),
                if (canAddCategory())
                  TSettingsMenuTile(
                    icon: Iconsax.add,
                    title: "Ajouter une établissement",
                    subTitle: "Insère un établissement",
                    onTap: () => Get.to(() => AddBrandScreen()),
                  ),
                SizedBox(
                  height: AppSizes.spaceBtwSections,
                ),
                SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                        onPressed: () =>
                            AuthenticationRepository.instance.logout(),
                        child: Text("Logout")))
              ]))
        ],
      )),
    );
  }
}
