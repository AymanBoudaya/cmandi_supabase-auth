import 'package:get/get.dart';

import '../../models/product_model.dart';
import '../../models/product_variation_model.dart';
import 'cart_controller.dart';
import 'images_controller.dart';

class VariationController extends GetxController {
  static VariationController get instance => Get.find();
  /// Variables
  final RxMap<String, dynamic> selectedAttributes = <String, dynamic>{}.obs;
  final RxString variationStockStatus = ''.obs;
  final Rx<ProductVariationModel> selectedVariation =
      ProductVariationModel.empty().obs;

  /// -- Select Attribute and variation
  void onAttributeSelected(
      ProductModel product, String attributeName, dynamic attributeValue) {
    // Update selected attributes
    selectedAttributes[attributeName] = attributeValue;

    // Find matching variation
    final selectedVariation = _findMatchingVariation(product);

    // Update UI and cart state
    _updateSelectionStates(product, selectedVariation);
  }

  ProductVariationModel _findMatchingVariation(ProductModel product) {
    return product.productVariations?.firstWhere(
          (variation) => _isSameAttributeValues(
            variation.attributeValues,
            selectedAttributes,
          ),
          orElse: () => ProductVariationModel.empty(),
        ) ??
        ProductVariationModel.empty();
  }

  void _updateSelectionStates(
      ProductModel product, ProductVariationModel variation) {
    // Update selected variation
    selectedVariation.value = variation;

    // Update product image if variation has one
    if (variation.image.isNotEmpty) {
      ImagesController.instance.selectedProductImage.value = variation.image;
    }

    // Update stock status
    getProductVariationStockStatus();

    // Reset temp quantity when variation changes
    if (variation.id.isNotEmpty) {
      final cartController = CartController.instance;
      cartController.updateTempQuantity(
        product,
        cartController.getExistingQuantity(product),
      );
    }
  }

  /// -- Check if selected attributes match variation attributes
  bool _isSameAttributeValues(
    Map<String, dynamic> variationAttributes,
    Map<String, dynamic> selectedAttributes,
  ) {
    if (variationAttributes.length != selectedAttributes.length) return false;

    for (final key in variationAttributes.keys) {
      if (variationAttributes[key] != selectedAttributes[key]) return false;
    }

    return true;
  }

  /// -- Get available attribute values based on stock
  Set<String?> getAttributesAvailabilityInVariation(
      List<ProductVariationModel> variations, String attributeName) {
    return variations
        .where((variation) =>
            variation.attributeValues[attributeName] != null &&
            variation.attributeValues[attributeName]!.isNotEmpty &&
            variation.stock > 0)
        .map((variation) => variation.attributeValues[attributeName])
        .toSet();
  }

  String getVariationPrice() {
    return (selectedVariation.value.salePrice > 0
            ? selectedVariation.value.salePrice
            : selectedVariation.value.price)
        .toString();
  }

  /// -- Update stock status text
  void getProductVariationStockStatus() {
    variationStockStatus.value =
        selectedVariation.value.stock > 0 ? 'En Stock' : 'Hors Stock';
  }

  /// -- Reset all selections
  void resetSelectedAttributes() {
    selectedAttributes.clear();
    variationStockStatus.value = '';
    selectedVariation.value = ProductVariationModel.empty();
  }
}
