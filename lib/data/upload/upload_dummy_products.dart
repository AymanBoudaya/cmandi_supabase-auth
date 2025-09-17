import '../../../features/shop/models/brand_model.dart';
import '../../../features/shop/models/product_attribute_model.dart';
import '../../../features/shop/models/product_model.dart';
import '../../../features/shop/models/product_variation_model.dart';
import '../../../utils/constants/image_strings.dart';

class StoreProducts {
  StoreProducts._();

  static final List<ProductModel> dummyProducts = [
    ProductModel(
      id: '001',
      title: 'Délice',
      stock: 10,
      price: 1.5,
      isFeatured: true,
      thumbnail: TImages.delice,
      description: 'Freshly roasted organic coffee beans.',
      salePrice: 1,
      productType: 'ProductType.single',
      sku: 'COF-001',
      categoryId: 'cat1',
      images: [
        TImages.productImage10,
        TImages.productImage11,
      ],
      brand: BrandModel(
        id: 'b1',
        name: 'CoffeeLand',
        image: TImages.productImage10,
        isFeatured: true,
        productsCount: 10,
      ),
      productAttributes: [
        ProductAttributeModel(
          name: 'Weight',
          values: ['250g', '500g', '1kg'],
        ),
      ],
      productVariations: [
        ProductVariationModel(
          id: 'pv1',
          sku: 'COF-250G',
          image: TImages.productImage1,
          price: 1.5,
          salePrice: 0,
          stock: 20,
          attributeValues: {'Weight': '250g'},
        ),
        ProductVariationModel(
          id: 'pv2',
          sku: 'COF-500G',
          image: TImages.productImage2,
          price: 1.5,
          salePrice: 0,
          stock: 30,
          attributeValues: {'Weight': '500g'},
        ),
      ],
    ),
    ProductModel(
      id: '002',
      title: 'Mlewi',
      stock: 50,
      price: 5.5,
      isFeatured: true,
      thumbnail: TImages.mlewi,
      description: 'Mlewi de différentes variétés et gouts.',
      salePrice: 5.9,
      productType: 'ProductType.variable',
      sku: 'COF-001',
      categoryId: 'cat1',
      images: [
        TImages.productImage10,
        TImages.productImage11,
      ],
      brand: BrandModel(
        id: 'b2',
        name: 'Hsouna',
        image: TImages.hsouna,
        isFeatured: true,
        productsCount: 10,
      ),
      productAttributes: [
        ProductAttributeModel(
          name: 'Pattes',
          values: ['simple', 'double'],
        ),
        ProductAttributeModel(
          name: 'Ingrédients',
          values: [
            'Thon',
            'Thon-Omlette',
            'Thon-Fromage',
            'Thon-Fromage-Omlette',
            'Spécial',
            'Chawarma',
            'Cordon Bleu'
          ],
        ),
      ],
      productVariations: [
        ProductVariationModel(
          id: 'pv1',
          sku: 'COF-250G',
          image: TImages.productImage1,
          price: 5.5,
          salePrice: 5.0,
          stock: 20,
          attributeValues: {'Ingrédients': 'Thon', 'Pattes': 'simple'},
        ),
        ProductVariationModel(
          id: 'pv2',
          sku: 'COF-500G',
          image: TImages.productImage2,
          price: 6.0,
          salePrice: 5.8,
          stock: 30,
          attributeValues: {'Ingrédients': 'Thon-Omlette', 'Pattes': 'double'},
        ),
      ],
    ),

    // You can define more dummy products here
  ];
}
