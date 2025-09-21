import 'package:flutter/services.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/authentication/screens/login/login.dart';
import '../../../features/authentication/screens/onboarding/onboarding.dart';
import '../../../navigation_menu.dart';
import '../user/user_repository.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  GoTrueClient get _auth => Supabase.instance.client.auth;

  Session? get session => _auth.currentSession;
  User? get authUser => _auth.currentUser;

  /// On stocke le dernier password utilisé (register ou login)

  String? lastAuthPassword;

    late final GetStorage deviceStorage;
  
  @override
  void onInit() {
    super.onInit();
    // Initialize storage in onInit to ensure it's ready
    deviceStorage = GetStorage();
  }
  

  @override
  void onReady() {
    FlutterNativeSplash.remove();

    _auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;
      if (event == AuthChangeEvent.signedIn && session != null) {
        try {
          await UserRepository.instance.fetchUserDetails();
        } catch (_) {}
        Get.offAll(() => const NavigationMenu());
      } else if (event == AuthChangeEvent.signedOut) {
        Get.offAll(() => const LoginScreen());
      }
    });
    screenRedirect();
    super.onReady();

  }

  screenRedirect() async {
    final user = authUser;

    if (user != null) {
        Get.offAll(() => const NavigationMenu());
  
    } else {
      deviceStorage.writeIfNull('IsFirstTime', true);
      deviceStorage.read('IsFirstTime') != true
          ? Get.offAll(() => const LoginScreen())
          : Get.offAll(() => const OnBoardingScreen());
    }
  }

   /// Sign up with email and send OTP
  Future<void> signUpWithEmailOTP(String email, Map<String, dynamic> userData) async {
    try {
      // Store user data temporarily for after verification
      await deviceStorage.write('pending_user_data', {
        'email': email,
        'user_data': userData,
      });

      // Send OTP to email
      await _auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
        data: userData,
        emailRedirectTo: null,
      );
    } on AuthException catch (e) {
      throw e.message;
    } on PlatformException catch (e) {
      throw e.message ?? 'Platform error occurred.';
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  /// Verify OTP and complete signup
  Future<AuthResponse> verifyOTP(String email, String token) async {
    try {
   
      // Verify the OTP
      final response = await _auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
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

  /// Resend OTP
  Future<void> resendOTP(String email) async {
    try {
      await _auth.signInWithOtp(
        email: email,
        shouldCreateUser: false, // User already exists in pending state
      );
    } on AuthException catch (e) {
      throw e.message;
    } on PlatformException catch (e) {
      throw e.message ?? 'Platform error occurred.';
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
  /// Send password reset email using OTP
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Use signInWithOtp with type recovery for password reset
      await _auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
        emailRedirectTo: null
      );
    } on AuthException catch (e) {
      throw e.message;
    } on PlatformException catch (e) {
      throw e.message ?? 'Platform error occurred.';
    } catch (e) {
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
/*

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
  }*/
}
