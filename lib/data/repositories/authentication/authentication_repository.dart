import 'package:flutter/services.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/authentication/screens/login/login.dart';
import '../../../features/authentication/screens/onboarding/onboarding.dart';
import '../../../features/authentication/screens/signup.widgets/verify_email.dart';
import '../../../navigation_menu.dart';
import '../../../utils/local_storage/storage_utility.dart';
import '../user/user_repository.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  GoTrueClient get _auth => Supabase.instance.client.auth;

  Session? get session => _auth.currentSession;
  User? get authUser => _auth.currentUser;

  /// On stocke le dernier password utilisé (register ou login)

  String? lastAuthPassword;

  @override
  void onReady() {
    FlutterNativeSplash.remove();

    _auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;
      if (event == AuthChangeEvent.signedIn && session != null) {
        // Fetch user details here
        final userDetails = await UserRepository.instance.fetchUserDetails();

        await TLocalStorage.init(session.user.id);

        Get.offAll(() => const NavigationMenu());
      } else if (event == AuthChangeEvent.signedOut) {
        Get.offAll(() => const LoginScreen());
      }
    });
    screenRedirect();
  }

  screenRedirect() async {
    final user = authUser;

    if (user != null) {
      if (user.emailConfirmedAt != null) {
        final userDetails = await UserRepository.instance.fetchUserDetails();

        await TLocalStorage.init(user.id);
        Get.offAll(() => const NavigationMenu());
      } else {
        /// Correction : on passe aussi le password stocké
        Get.offAll(() => VerifyEmailScreen(
              email: user.email ?? '',
              password: lastAuthPassword ?? '',
            ));
      }
    } else {
      deviceStorage.writeIfNull('IsFirstTime', true);
      deviceStorage.read('IsFirstTime') != true
          ? Get.offAll(() => const LoginScreen())
          : Get.offAll(() => const OnBoardingScreen());
    }
  }

  Future<AuthResponse> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      lastAuthPassword = password; // 👈 on stocke le password
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw e.message;
    } on PlatformException catch (e) {
      throw e.message ?? 'Platform error occurred.';
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<AuthResponse> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      lastAuthPassword = password; // 👈 on stocke aussi ici
      return await _auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.flutterquickstart://login-callback',
      );
    } on AuthException catch (e) {
      throw e.message;
    } on PlatformException catch (e) {
      throw e.message ?? 'Platform error occurred.';
    } catch (_) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final email = authUser?.email;
      if (email == null) throw 'No authenticated user found.';
      await _auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } on AuthException catch (e) {
      throw e.message;
    } catch (_) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.offAll(() => const LoginScreen());
    } on AuthException catch (e) {
      throw e.message;
    } catch (_) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> reAuthenticateWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await loginWithEmailAndPassword(email, password);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flutterquickstart://reset-password',
      );
    } on AuthException catch (e) {
      throw e.message;
    } catch (_) {
      throw 'Something went wrong. Please try again';
    }
  }

  Future<void> deleteAccount() async {
    try {
      throw 'Account deletion must be handled server-side via Supabase Admin API.';
    } catch (e) {
      throw e.toString();
    }
  }
}
