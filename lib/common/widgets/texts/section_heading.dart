import 'package:flutter/material.dart';

import '../../../utils/constants/sizes.dart';

class TSectionHeading extends StatelessWidget {
  const TSectionHeading({
    super.key,
    required this.title,
    this.showActionButton = false,
    this.buttonTitle = 'Voir plus',
    this.onPressed,
    this.padding,
  });

  final String title;
  final bool showActionButton;
  final String buttonTitle;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
      child: SizedBox(
        width: double.infinity, // Contrainte de largeur
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showActionButton)
              TextButton(
                onPressed: onPressed,
                child: Text(buttonTitle),
              ),
          ],
        ),
      ),
    );
  }
}
