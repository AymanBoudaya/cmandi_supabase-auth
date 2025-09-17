import 'package:caferesto/common/widgets/texts/section_heading.dart';
import 'package:caferesto/features/personalization/controllers/address_controller.dart';
import 'package:caferesto/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class TBillingAddressSection extends StatelessWidget {
  const TBillingAddressSection({super.key});
  @override
  Widget build(BuildContext context) {
    final addressController = AddressController.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TSectionHeading(
          title: 'Adresse de livraison',
          buttonTitle: 'Changer',
          onPressed: () => addressController.selectNewAddressPopup(context),
        ),
        addressController.selectedAddress.value.id.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ALi karray',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(
                    height: AppSizes.spaceBtwItems / 2,
                  ),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.grey, size: 16),
                      const SizedBox(
                        height: AppSizes.spaceBtwItems,
                      ),
                      Text(
                        '+216-55 21 52 36',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: AppSizes.spaceBtwItems / 2,
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_history,
                          color: Colors.grey, size: 16),
                      const SizedBox(
                        height: AppSizes.spaceBtwItems,
                      ),
                      Expanded(
                        child: Text(
                          'Gremda km 10, Sfax, Tunisie',
                          style: Theme.of(context).textTheme.bodyMedium,
                          softWrap: true,
                        ),
                      )
                    ],
                  ),
                ],
              )
            : Text('Sélectionner une adresse',
                style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
