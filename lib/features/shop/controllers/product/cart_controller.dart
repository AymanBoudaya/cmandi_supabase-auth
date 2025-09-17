import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../utils/constants/enums.dart';
import '../../../../utils/popups/loaders.dart';
import '../../models/cart_item_model.dart';
import '../../models/product_model.dart';
import 'variation_controller.dart';

class CartController extends GetxController {
  static CartController get instance => Get.find();

  RxInt cartItemsCount = 0.obs;
  RxDouble totalCartPrice = 0.0.obs;
  final RxMap<String, int> tempQuantityMap = <String, int>{}.obs;
  RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final variationController = Get.put(VariationController());

  CartController() {
    loadCartItems();
  }

  String _getKey(ProductModel product) {
    final variationId = product.productType == ProductType.variable.toString()
        ? variationController.selectedVariation.value.id
        : "";
    return '${product.id}-$variationId';
  }

  void updateTempQuantity(ProductModel product, int quantity) {
    final key = _getKey(product);
    tempQuantityMap[key] = quantity;
  }

  int getTempQuantity(ProductModel product) {
    final key = _getKey(product);
    return tempQuantityMap[key] ?? getExistingQuantity(product);
  }

  int getExistingQuantity(ProductModel product) {
    if (product.productType == ProductType.single.toString()) {
      return getProductQuantityInCart(product.id);
    } else {
      final variationId = variationController.selectedVariation.value.id;
      return variationId.isNotEmpty
          ? getVariationQuantityInCart(product.id, variationId)
          : 0;
    }
  }

  void addToCart(ProductModel product) {
    final quantity = getTempQuantity(product);

    if (quantity < 1) {
      TLoaders.customToast(message: 'Veuillez choisir une quantité');
      return;
    }

    if (product.productType == ProductType.variable.toString() &&
        variationController.selectedVariation.value.id.isEmpty) {
      TLoaders.customToast(message: 'Veuillez choisir une variante');
      return;
    }

    if (product.productType == ProductType.variable.toString()) {
      if (variationController.selectedVariation.value.stock < 1) {
        TLoaders.customToast(message: 'Produit hors stock');
        return;
      }
    } else {
      if (product.stock < 1) {
        TLoaders.customToast(message: 'Produit hors stock');
        return;
      }
    }

    final selectedCartItem = productToCartItem(product, quantity);
    int index = cartItems.indexWhere((cartItem) =>
        cartItem.productId == selectedCartItem.productId &&
        cartItem.variationId == selectedCartItem.variationId);

    if (index >= 0) {
      cartItems[index].quantity = selectedCartItem.quantity;
    } else {
      cartItems.add(selectedCartItem);
    }

    updateCart();
    TLoaders.customToast(message: 'Produit ajouté au panier');
  }

  CartItemModel productToCartItem(ProductModel product, int quantity) {
    if (product.productType == ProductType.single.toString()) {
      variationController.resetSelectedAttributes();
    }

    final variation = variationController.selectedVariation.value;
    final isVariation = variation.id.isNotEmpty;
    final price = isVariation
        ? variation.salePrice > 0
            ? variation.salePrice
            : variation.price
        : product.salePrice > 0.0
            ? product.salePrice
            : product.price;
    return CartItemModel(
      productId: product.id,
      title: product.title,
      price: price,
      image: isVariation ? variation.image : product.thumbnail,
      quantity: quantity,
      variationId: variation.id,
      brandName: product.brand != null ? product.brand!.name : '',
      selectedVariation: isVariation ? variation.attributeValues : null,
    );
  }

  void updateCart() {
    updateCartTotals();
    saveCartItems();
    cartItems.refresh();
  }

  void addOneToCart(CartItemModel item) {
    int index = cartItems.indexWhere((cartItem) =>
        cartItem.productId == item.productId &&
        cartItem.variationId == item.variationId);

    if (index >= 0) {
      cartItems[index].quantity++;
    } else {
      cartItems.add(item);
    }
    updateCart();
  }

  void removeOneFromCart(CartItemModel item) {
    int index = cartItems.indexWhere((cartItem) =>
        cartItem.productId == item.productId &&
        cartItem.variationId == item.variationId);

    if (index >= 0) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
      } else {
        cartItems[index].quantity == 1
            ? removeFromCartDialog(index)
            : cartItems.removeAt(index);
      }
      updateCart();
    }
  }

  void removeFromCartDialog(int index) {
    Get.defaultDialog(
      title: 'Confirmation',
      middleText: 'Voulez-vous vraiment supprimer ce produit du panier?',
      textConfirm: 'Oui',
      textCancel: 'Non',
      onConfirm: () {
        cartItems.removeAt(index);
        updateCart();
        TLoaders.customToast(message: 'Produit supprimé du panier');
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }

  void updateCartTotals() {
    double calculatedTotalPrice = 0.0;
    int calculatedcartItemsCount = 0;
    for (var item in cartItems) {
      calculatedTotalPrice += (item.price) * item.quantity.toDouble();
      calculatedcartItemsCount += item.quantity;
    }
    totalCartPrice.value = calculatedTotalPrice;
    cartItemsCount.value = calculatedcartItemsCount;
  }

  void saveCartItems() async {
    final cartItemStrings = cartItems.map((item) => item.toJson()).toList();
    await GetStorage().write('cartItems', cartItemStrings);
  }

  void loadCartItems() async {
    final cartItemStrings = GetStorage().read<List<dynamic>>('cartItems');
    if (cartItemStrings != null) {
      cartItems.assignAll(cartItemStrings
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>)));
      updateCartTotals();
    }
  }

  int getProductQuantityInCart(String productId) {
    return cartItems
        .where((item) => item.productId == productId)
        .fold(0, (previousValue, element) => previousValue + element.quantity);
  }

  int getVariationQuantityInCart(String productId, String variationId) {
    final foundItem = cartItems.firstWhere(
        (item) =>
            item.productId == productId && item.variationId == variationId,
        orElse: () => CartItemModel.empty());
    return foundItem.quantity;
  }

  void clearCart() {
    tempQuantityMap.clear();
    cartItems.clear();
    updateCart();
  }
}
