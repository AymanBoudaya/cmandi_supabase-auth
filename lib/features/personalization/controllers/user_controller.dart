import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/user/user_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../models/user_model.dart';
import 'package:image_picker/image_picker.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final profileLoading = false.obs;
  Rx<UserModel> user = UserModel.empty().obs;

  final userRepository = Get.find<UserRepository>();

  final hidePassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    // Listener sur l'état de connexion Supabase
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        fetchUserRecord();
      } else {
        user(UserModel.empty());
        debugPrint("👤 Utilisateur déconnecté");
      }
    });
  }

  /// Charger les infos utilisateur
  Future<void> fetchUserRecord() async {
    try {
      profileLoading.value = true;
      final user = await userRepository.fetchUserDetails();
      this.user(user);
    } catch (e) {
      user(UserModel.empty());
      Get.snackbar('Erreur', 'Impossible de récupérer les données utilisateur');
    } finally {
      profileLoading.value = false;
    }
  }

  /// Save user Record from any registration provider
  Future<void> saveUserRecord(User? supabaseUser) async {
    try {
      if (supabaseUser != null) {
        // Convertir Name en First and Last Name (si displayName est stocké côté Supabase metadata)
        final displayName = supabaseUser.userMetadata?['full_name'] ?? '';
        final nameParts = UserModel.nameParts(displayName);
        final username = UserModel.generateUsername(displayName);
        // Map data (adapter selon ton modèle UserModel)
        final user = UserModel(
          id: supabaseUser.id,
          email: supabaseUser.email ?? '',
          firstName: nameParts.isNotEmpty ? nameParts[0] : '',
          lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
          username: username,
          phone: supabaseUser.phone ?? '',
          role: 'Client',
          orderIds: [],
          profileImageUrl:
              supabaseUser.userMetadata?['profile_image_url'] ?? '',
        );
        // Sauvegarde (dans Supabase table "users")
        await userRepository.saveUserRecord(user);
      }
    } catch (e) {
      TLoaders.warningSnackBar(
        title: 'Donnés non enregistrés',
        message:
            "Quelque chose s'est mal passé en enregistrant vos informations. Vous pouver réenregistrer vos données dans votre profil.",
      );
    }
  }

  /// Delete account Warning
  /* void deleteAccountWarningPopup() { Get.defaultDialog( contentPadding: const EdgeInsets.all(AppSizes.md), title: 'Supprimer compte', middleText: "Êtes vous sûr? Cette action est irréversible et supprimera toutes vos données.", confirm: ElevatedButton( onPressed: () async => deleteUserAccount(), style: ElevatedButton.styleFrom( backgroundColor: Colors.red, side: const BorderSide(color: Colors.red), ), child: const Padding( padding: EdgeInsets.symmetric(horizontal: AppSizes.lg), child: Text("Supprimer"), ), ), cancel: OutlinedButton( onPressed: () => Navigator.of(Get.overlayContext!).pop(), child: const Text('Annuler')), ); }*/

  /// Delet user account
  /* void deleteUserAccount() async { try { // Start Loading TFullScreenLoader.openLoadingDialog( "Nous sommes en train de supprimer votre compte...", TImages.docerAnimation); /// First re-authenticate the user final auth = AuthenticationRepository.instance; final provider = auth.authUser!.providerData.map((e) => e.providerId).first; if (provider.isNotEmpty) { // Reverify auth email if (provider == 'google.com') { await auth.signInWithGoogle(); await auth.deleteAccount(); TFullScreenLoader.stopLoading(); Get.offAll(() => const LoginScreen()); } else if (provider == 'password') { TFullScreenLoader.stopLoading(); Get.to(() => const ReAuthLoginForm()); } } } catch (e) { // Remove Loader TFullScreenLoader.stopLoading(); // Show error message TLoaders.warningSnackBar(title: "Erreur", message: e.toString()); } }*/
  /*Future<void> reAuthenticateEmailAndPasswordUser() async {
    try {
      TFullScreenLoader.openLoadingDialog(
          "Nous sommes en train de vérifier votre compte...",
          TImages.docerAnimation);
      // Check internet connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }
      if (!reAuthFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }
      await AuthenticationRepository.instance
          .reAuthenticateWithEmailAndPassword(
              verifyEmail.text.trim(), verifyPassword.text.trim());
      await AuthenticationRepository.instance.deleteAccount();
      TFullScreenLoader.stopLoading();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.warningSnackBar(title: "Erreur!", message: e.toString());
    }
  }*/

  Future<void> updateProfileImage(XFile pickedFile) async {
    try {
      final userId = user.value.id;

      // Upload sur Supabase Storage
      final path =
          'profile_images/$userId-${DateTime.now().millisecondsSinceEpoch}.png';
      final bytes = await pickedFile.readAsBytes();

      await Supabase.instance.client.storage
          .from('profile_images')
          .uploadBinary(path, bytes,
              fileOptions: const FileOptions(contentType: 'image/png'));

      // Récupérer l’URL publique
      final publicUrl = Supabase.instance.client.storage
          .from('profile_images')
          .getPublicUrl(path);

      debugPrint("✅ Image uploaded. Public URL: $publicUrl");

      // Mettre à jour la table users
      await Supabase.instance.client
          .from('users')
          .update({'profile_image_url': publicUrl}).eq('id', userId);

      // Mettre à jour le contrôleur local
      user.update((val) {
        val?.profileImageUrl = publicUrl;
      });

      TLoaders.successSnackBar(
          title: 'Succès', message: 'Photo de profil mise à jour !');
    } catch (e, st) {
      debugPrint("❌ Erreur updateProfileImage: $e\n$st");
      TLoaders.warningSnackBar(title: 'Erreur', message: e.toString());
    }
  }
}
