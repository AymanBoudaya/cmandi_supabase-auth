import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../data/repositories/user/user_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../personalization/models/user_model.dart';
import '../../screens/signup.widgets/verify_email.dart';
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

      final AuthResponse response =
          await AuthenticationRepository.instance.registerWithEmailAndPassword(
        email.text.trim(),
        password.text.trim(),
      );

      // 5. Ensure user is loaded
      final user = response.user;

      if (user == null) {
        throw Exception(
          "L'utilisateur n'a pas pu être chargé après l'inscription.",
        );
      }

      print('✅ Utilisateur créé avec ID: ${user.id}');

      // 6. Enregistrer les donnés utilisateurs dans la table Supabase
      final newUser = UserModel(
        id: user.id,
        email: email.text.trim(),
        username: username.text.trim(),
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        phone: phoneNumber.text.trim(),
        sex: selectedGender.value.dbValue,
        role: selectedRole.value.dbValue,
        profileImageUrl: '',
      );

      print('🔄 Sauvegarde des données utilisateur...');

      await _userRepository.saveUserRecord(newUser);

      // 7. Navigate to verify email screen
      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
        title: "Félicitations!",
        message:
            "Votre compte a été créé! Vérifiez votre email pour continuer.",
      );

      Get.off(() => VerifyEmailScreen(
            email: email.text.trim(),
            password: password.text.trim(),
          ));
    } catch (e) {
      TFullScreenLoader.stopLoading();
      print('❌ Erreur complète: $e');
      // Message d'erreur plus spécifique
      String errorMessage = 'Une erreur est survenue';
      if (e.toString().contains('duplicate key')) {
        errorMessage = 'Cet utilisateur existe déjà';
      }

      TLoaders.errorSnackBar(title: 'Erreur', message: errorMessage);
      TLoaders.errorSnackBar(title: 'Erreur !', message: e.toString());
    } finally {
      _isProcessing = false;
    }
  }
}
