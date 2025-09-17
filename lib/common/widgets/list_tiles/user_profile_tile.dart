import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../features/personalization/controllers/user_controller.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../images/circular_image.dart';

class TUserProfileTile extends StatelessWidget {
  const TUserProfileTile({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular image with custom size

          CircularImage(
            isNetworkImage: true,
            image: controller.user.value.profileImageUrl!.isNotEmpty
                ? controller.user.value.profileImageUrl!
                : controller.user.value.sex == 'Homme'
                    ? TImages.userMale
                    : TImages.userFemale,
            width: 80,
            height: 80,
          ),
          const SizedBox(width: 16), // Spacing between image and text
          // Expanded text section to prevent overflow
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name
                Text(
                  controller.user.value.fullName,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall!.apply(color: AppColors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Email d'utilisateur
                Text(
                  controller.user.value.email,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.apply(color: AppColors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Edit button
          IconButton(
            onPressed: onPressed,
            icon: const Icon(Iconsax.edit, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}
