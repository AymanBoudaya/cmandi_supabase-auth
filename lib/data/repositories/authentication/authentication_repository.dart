import 'package:caferesto/features/authentication/screens/signup.widgets/otp_verification_screen.dart';
import 'package:caferesto/utils/local_storage/storage_utility.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/authentication/controllers/signup/signup_controller.dart';
import '../../../features/authentication/screens/login/login.dart';
import '../../../features/authentication/screens/onboarding/onboarding.dart';
import '../../../features/personalization/controllers/user_controller.dart';
import '../../../features/personalization/models/user_model.dart';
import '../../../navigation_menu.dart';
import '../../../utils/popups/loaders.dart';
import '../user/user_repository.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final GetStorage deviceStorage = GetStorage();
  GoTrueClient get _auth => Supabase.instance.client.auth;

  User? get authUser => _auth.currentUser;

  @override
  void onReady() {
    FlutterNativeSplash.remove();

    _auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;
      final pending = deviceStorage.read('pending_user_data');

      try {
        if (event == AuthChangeEvent.signedIn && session != null) {
          // Si signup en cours (pending data), on ne redirige pas encore
          if (pending != null) {
            // 'Inscription flow en cours, attente de vérification OTP';
            return;
          }

          // Cas login normal
          // 'Connecté — récupération des infos utilisateur'
          try {
            await UserRepository.instance.fetchUserDetails();
          } catch (e) {
            throw Exception('Détails utilisateur erreur de chargement: $e');
          }
          await TLocalStorage.init(session.user.id);
          Get.offAll(() => const NavigationMenu());
        } else if (event == AuthChangeEvent.signedOut) {
          // Déconnexion — nettoyage et retour Login'
          await deviceStorage.remove('pending_user_data');
          Get.offAll(() => const LoginScreen());
        }
      } catch (e) {
        throw Exception('Erreur dans auth state change handler: $e');
      }
    });

    screenRedirect();
  }

  /// -- Flux de redirection

  Future<void> screenRedirect() async {
    final Map<String, dynamic> userData = SignupController.instance.userData;

    final user = authUser;
    final pending = deviceStorage.read('pending_user_data');

    if (user != null) {
      final meta = user.userMetadata ?? {};
      final emailVerified =
          (meta['email_verified'] == true) || (user.emailConfirmedAt != null);

      if (emailVerified) {
        // Email déjà vérifié — navigation vers app principale
        await TLocalStorage.init(user.id);
        Get.offAll(() => const NavigationMenu());
      } else {
        // OTP à vérifier
        final pendingMap = pending as Map<String, dynamic>?;
        final pendingEmail = pendingMap?['email'] as String? ?? user.email;
        final pendingUserData =
            pendingMap?['user_data'] as Map<String, dynamic>? ?? userData;
        // Navigation vers OTPVerificationScreen pour pendingEmail
        Get.offAll(() => OTPVerificationScreen(
            email: pendingEmail ?? user.email!, userData: pendingUserData));
      }
    } else {
      deviceStorage.writeIfNull('IsFirstTime', true);
      final isFirst = deviceStorage.read('IsFirstTime') == true;
      isFirst
          ? Get.offAll(() => const OnBoardingScreen())
          : Get.offAll(() => const LoginScreen());
    }
  }

  /// -- S'inscrire avec email par OTP

  Future<void> signUpWithEmailOTP(
      String email, Map<String, dynamic> userData) async {
    try {
      await deviceStorage.write('pending_user_data', {
        'email': email,
        'user_data': userData,
      });

      await _auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
        data: userData,
        emailRedirectTo: null,
      );
    } catch (e, st) {
      throw Exception('Erreur de signUpWithEmailOTP : $e\n$st');
    }
  }

  /// Connexion avec OTP

  Future<void> sendOtp(String email) async {
    try {
      await _auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
        emailRedirectTo: null,
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: "Erreur OTP", message: e.toString());
      rethrow;
    }
  }

  /// -- Renvoyer OTP

  Future<void> resendOTP(String email) async {
    try {
      await _auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
        emailRedirectTo: null,
      );
    } catch (e, st) {
      throw Exception('resendOTP erreur: $e\n$st');
    }
  }

  /// -- Vérification OTP

  Future<void> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      // Vérifier OTP
      final response = await _auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: otp,
      );

      final supabaseUser = response.user ?? _auth.currentUser;
      if (supabaseUser == null) {
        throw Exception(
            "Échec de la vérification OTP : aucun utilisateur retourné.");
      }

      // Vérifier si c’est un flux de signup
      final pending =
          deviceStorage.read('pending_user_data') as Map<String, dynamic>?;

      if (pending != null) {
        final savedUserData = Map<String, dynamic>.from(
          pending['user_data'] as Map? ?? {},
        );

        String _get(Map<String, dynamic> m, String key) =>
            m[key]?.toString() ?? '';

        final userModel = UserModel(
          id: supabaseUser.id,
          email: supabaseUser.email ?? email,
          username: _get(savedUserData, 'username'),
          firstName: _get(savedUserData, 'first_name'),
          lastName: _get(savedUserData, 'last_name'),
          phone: _get(savedUserData, 'phone'),
          sex: _get(savedUserData, 'sex'),
          role: _get(savedUserData, 'role'),
          profileImageUrl: _get(savedUserData, 'profile_image_url'),
        );

        await UserRepository.instance.saveUserRecord(userModel);

        await deviceStorage.remove('pending_user_data');
      } else {
        final existingUser =
            await UserRepository.instance.fetchUserDetails(supabaseUser.id);

        if (existingUser == null) {
          throw Exception("Utilisateur introuvable. Inscription requise.");
        }
        throw Exception("Utilisateur existant trouvé: ${existingUser.id}");
      }

      // Init du stockage local
      await TLocalStorage.init(supabaseUser.id);

      // Lecture des données utilisateur
      await UserController.instance.fetchUserRecord();

      // Redirection vers page home
      Get.offAll(() => const NavigationMenu());
    } catch (e, st) {
      TLoaders.errorSnackBar(
        title: "Erreur Vérification",
        message: e.toString(),
      );
      throw Exception("Erreur verifyOTP: $e\n$st");
    }
  }

  /// -- Connexion avec un compte google

  Future<void> signInWithGoogle() async {
    try {
      await _auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback',
        scopes: null,
        authScreenLaunchMode: LaunchMode.platformDefault,
        queryParams: null,
      );
    } on AuthException catch (e, st) {
      throw Exception('AuthException signInWithGoogle: ${e.message}\n$st');
    } catch (e, st) {
      throw Exception('Erreur inconnue signInWithGoogle: $e\n$st');
    }
  }

  /// -- Déconnexion

  Future<void> logout() async {
    try {
      await _auth.signOut();
      await deviceStorage.remove('pending_user_data');
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      throw Exception('logout erreur: $e');
    }
  }
}
