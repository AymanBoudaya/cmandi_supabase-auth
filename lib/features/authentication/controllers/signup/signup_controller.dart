import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../data/repositories/user/user_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../screens/signup.widgets/otp_verification_screen.dart';
import '../../screens/signup.widgets/widgets/signup_form.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  final hidePassword = true.obs;
  final privacyPolicy = true.obs;
  final email = TextEditingController();
  final lastName = TextEditingController();
  final firstName = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final phoneNumber = TextEditingController();
  final Rx<UserRole> selectedRole = UserRole.Client.obs;
  final Rx<UserGender> selectedGender = UserGender.Homme.obs;

  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  final UserRepository _userRepository = UserRepository.instance;
  bool _isProcessing = false;

  /// -- SIGNUP
  void signup() async {
    if (_isProcessing) return;
    _isProcessing = true;
    TFullScreenLoader.openLoadingDialog(
      "Nous sommes en train de traiter vos informations...",
      TImages.docerAnimation,
    );

    try {
      // 1. Check internet connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
          title: 'Pas de connexion',
          message: 'Veuillez vérifier votre connexion internet.',
        );
        return;
      }

      // 2. Validate form
      if (!signupFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // 3. Check privacy policy
      if (!privacyPolicy.value) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
          title: 'Politique de confidentialité',
          message: 'Veuillez accepter la politique de confidentialité.',
        );
        return;
      }

      // 4. Register with Supabase
      print('🔄 Début de l\'inscription...');
      // 6. Enregistrer les donnés utilisateurs dans la table Supabase
      final userData = {
        'firstName': firstName.text.trim(),
        'lastName': lastName.text.trim(),
        'username': username.text.trim(),
        'phone': phoneNumber.text.trim(),
        'sex': selectedGender.value.dbValue,
        'role': selectedRole.value.dbValue,
        'profileImageUrl': '',
      };

      // Send OTP to email
      await AuthenticationRepository.instance.signUpWithEmailOTP(
        email.text.trim(),
        userData,
      );

      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
        title: "OTP envoyé!",
        message: "Un code de vérification a été envoyé à votre adresse email.",
      );

      // Navigate to OTP verification screen
      Get.off(() => OTPVerificationScreen(
        email: email.text.trim(),
        userData: userData,
      ));

    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Erreur',
        message: e.toString(),
      );
    } finally {
      _isProcessing = false;
    }
  }
}
