import 'dart:async';

import 'package:get/get.dart';

import '../../../../common/widgets/success_screen/success_screen.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../data/repositories/user/user_repository.dart';
import '../../../../navigation_menu.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../personalization/models/user_model.dart';

class OTPVerificationController extends GetxController {
  static OTPVerificationController get instance => Get.find();

  final RxBool isLoading = false.obs;
  final RxBool canResendOTP = false.obs;
  final RxInt resendCountdown = 60.obs;
  Timer? _resendTimer;
  final UserRepository _userRepository = UserRepository.instance;
  
  @override
  void onInit() {
    super.onInit();
    startResendTimer();
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }

  /// Start timer for resend OTP
  void startResendTimer() {
    canResendOTP.value = false;
    resendCountdown.value = 60;
    
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        canResendOTP.value = true;
        timer.cancel();
      }
    });
  }

  /// Verify OTP and save user data
  Future<void> verifyOTP(String email, String otpCode, Map<String, dynamic> userData) async {
    try {
      isLoading.value = true;
      TFullScreenLoader.openLoadingDialog("Vérification en cours...", TImages.docerAnimation);
      
      // Verify OTP
      final response = await AuthenticationRepository.instance.verifyOTP(email, otpCode);
      
      if (response.user != null) {
        // 6. Enregistrer les données utilisateurs dans la table Supabase
        final newUser = UserModel(
          id: response.user!.id,
          email: email,
          username: userData['username'],
          firstName: userData['first_name'],
          lastName: userData['last_name'],
          phone: userData['phone'],
          sex: userData['sex'],
          role: userData['role'],
          profileImageUrl: userData['profile_image_url'],
        );

        print('🔄 Sauvegarde des données utilisateur...');
        await _userRepository.saveUserRecord(newUser);
        
        TFullScreenLoader.stopLoading();
        
        // 7. Navigate to success screen
        TLoaders.successSnackBar(
          title: "Félicitations!",
          message: "Votre compte a été créé avec succès!",
        );

        Get.offAll(() => SuccessScreen(
          image: TImages.successfullyRegisterAnimation,
          title: 'Compte créé avec succès',
          subTitle: 'Bienvenue dans notre application!',
          onPressed: () => Get.offAll(() => const NavigationMenu()),
        ));
      } else {
        throw 'Échec de la vérification OTP';
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Erreur de vérification',
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend OTP
  Future<void> resendOTP(String email) async {
    try {
      await AuthenticationRepository.instance.resendOTP(email);
      TLoaders.successSnackBar(
        title: 'OTP renvoyé',
        message: 'Un nouveau code a été envoyé à votre email.',
      );
      
      // Reset the timer
      startResendTimer();
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Erreur',
        message: 'Impossible de renvoyer le code: ${e.toString()}',
      );
    }
  }
}