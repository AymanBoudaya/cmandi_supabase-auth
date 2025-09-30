import 'package:caferesto/features/authentication/controllers/signup/signup_controller.dart';
import 'package:get/get.dart';

import '../data/repositories/product/product_repository.dart';
import '../data/repositories/user/user_repository.dart';
import '../features/authentication/controllers/signup/verify_otp_controller.dart';
import '../features/personalization/controllers/address_controller.dart';
import '../features/personalization/controllers/user_controller.dart';
import '../features/shop/controllers/product/checkout_controller.dart';
import '../features/shop/controllers/product/variation_controller.dart';
import '../utils/helpers/network_manager.dart';

class GeneralBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ProductRepository());
    Get.put(UserRepository());

    Get.lazyPut(() => SignupController());
    Get.lazyPut(() => OTPVerificationController());

    Get.put(NetworkManager());
    Get.put(UserController());
    Get.put(VariationController());
    Get.put(AddressController());
    Get.put(CheckoutController());
  }
}
