import 'package:get/get.dart';

import '../../../../data/repositories/product/product_repository.dart';
import '../../models/product_model.dart';

class AllProductsController extends GetxController {
  // This controller can be used to manage the state of all products in the shop.
  // You can add methods and properties here to handle product data, such as fetching products from an API,
  // filtering products, or managing the cart.
  static AllProductsController get instance => Get.find();
  final repository = ProductRepository.instance;
  final RxString selectedSortOption = 'Nom'.obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;

/*
  Future<List<ProductModel>> fetchProductsByQuery(Query? query) async {
    try {
      if (query == null) {
        return [];
      }
      final products = await repository.fetchProductsByQuery(query);
      return products;
    } catch (e) {
      TLoaders.errorSnackBar(title: "Erreur", message: e.toString());
      return [];
    }
  }
*/
  void sortProducts(String sortOption) {
    selectedSortOption.value = sortOption;
    switch (sortOption) {
      case 'Nom':
        products.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Prix décroissant':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Prix croissant':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Récent':
        products.sort((a, b) => a.date!.compareTo(b.date!));
        break;
      case 'Ventes':
        products.sort((a, b) {
          if (b.salePrice > 0) {
            return b.salePrice.compareTo(a.salePrice);
          } else if (a.salePrice > 0) {
            return -1;
          } else {
            return 1;
          }
        });
        break;
      default:
        products.sort((a, b) => a.title.compareTo(b.title));
    }
  }

  void assignProducts(List<ProductModel> products) {
    this.products.assignAll(products);
    sortProducts('title');
  }
}
