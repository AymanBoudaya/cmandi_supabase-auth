import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../screens/login/login.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get instance => Get.find();

  /// Variables
  final pageController = PageController();
  Rx<int> currentPageIndex = 0.obs;

  /// Update Current Index when Page Scroll
  void updatePageIndicator(index) => currentPageIndex.value = index;

  /// Jump to the specific dot selected page
  void dotNavigationClick(index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  /// Update Current Index & jump to next page
  void nextPage() {
    if (currentPageIndex.value < 2) {
      final nextPage = currentPageIndex.value + 1;
      currentPageIndex.value = nextPage;
      pageController.jumpToPage(nextPage);
      print(nextPage);
    } else {
      Get.to(() => LoginScreen());
    }
  }

  /// Update Current Index & jump to the last page
  void skipPage() {
    Get.to(() => LoginScreen());
  }
}
