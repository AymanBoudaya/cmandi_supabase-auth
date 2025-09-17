import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/images/circular_image.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/user_controller.dart';
import 'widgets/profile_menu.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: const Text('Mon Profil'),
      ),
      body: Obx(() {
        if (controller.profileLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.user.value;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.defaultSpace),
            child: Column(
              children: [
                /// Profile Picture
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Obx(() => CircularImage(
                            isNetworkImage: true,
                            image: controller
                                    .user.value.profileImageUrl!.isNotEmpty
                                ? controller.user.value.profileImageUrl!
                                : controller.user.value.sex == 'Homme'
                                    ? TImages.userMale
                                    : TImages.userFemale,
                            width: 80,
                            height: 80,
                          )),
                      TextButton(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (pickedFile != null) {
                            await controller.updateProfileImage(pickedFile);
                          }
                        },
                        child: const Text('Modifier la photo de profil'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.spaceBtwItems / 2),
                const Divider(),
                const SizedBox(height: AppSizes.spaceBtwItems),

                const TSectionHeading(
                    title: 'Informations du profil', showActionButton: false),
                const SizedBox(height: AppSizes.spaceBtwItems),

                TProfileMenu(
                    title: "Nom",
                    value: "${user.firstName} ${user.lastName}",
                    onPressed: () {}),
                TProfileMenu(
                    title: "Nom d'utilisateur",
                    value: user.username,
                    onPressed: () {}),

                const SizedBox(height: AppSizes.spaceBtwItems),
                const Divider(),
                const SizedBox(height: AppSizes.spaceBtwItems),

                const TSectionHeading(
                    title: 'Infos personnelles', showActionButton: false),
                const SizedBox(height: AppSizes.spaceBtwItems),

                TProfileMenu(
                    title: "ID utilisateur",
                    value: user.id,
                    icon: Iconsax.copy,
                    onPressed: () {}),
                TProfileMenu(
                    title: "E-mail", value: user.email, onPressed: () {}),
                TProfileMenu(
                    title: "Téléphone", value: user.phone, onPressed: () {}),
              ],
            ),
          ),
        );
      }),
    );
  }
}
