import 'package:caferesto/features/authentication/screens/signup.widgets/otp_verification_screen.dart';
import 'package:caferesto/utils/local_storage/storage_utility.dart';
import 'package:flutter/services.dart';

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

  Session? get session => _auth.currentSession;
  User? get authUser => _auth.currentUser;

  /// On stocke le dernier password utilisé (register ou login)
  // String? lastAuthPassword;

  @override
  void onReady() {
    FlutterNativeSplash.remove();

    _auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;
      final pending = deviceStorage.read('pending_user_data');

      print(
          '🔔 onAuthStateChange event: $event, session: ${session != null}, pending_user_data: ${pending != null}');

      try {
        if (event == AuthChangeEvent.signedIn && session != null) {
          // If pending_user_data exists, we are in signup flow; defer navigation
          if (pending != null) {
            print(
                '⏳ Sign-in detected during signup flow — deferring global navigation until pending_user_data cleared');
            return;
          }

          // Normal post-login flow
          print(
              '✅ Signed in, fetching user details and navigating to NavigationMenu');
          try {
            await UserRepository.instance.fetchUserDetails();
          } catch (e) {
            print('⚠️ fetchUserDetails returned error: $e');
          }
          await TLocalStorage.init(session.user.id);
          Get.offAll(() => const NavigationMenu());
        } else if (event == AuthChangeEvent.signedOut) {
          print(
              '🔒 Signed out — clearing pending_user_data and going to Login');
          await deviceStorage.remove('pending_user_data');
          Get.offAll(() => const LoginScreen());
        }
      } catch (e) {
        print('❌ Error in auth state change handler: $e');
      }
    });

    screenRedirect();
  }

  Future<void> screenRedirect() async {
    final Map<String, dynamic> userData = SignupController.instance.userData;

    final user = authUser;
    final pending = deviceStorage.read('pending_user_data');

    print(
        'screenRedirect: authUser ${user?.id}, pending_user_data: ${pending != null}');

    if (user != null) {
      final meta = user.userMetadata ?? {};
      final emailVerified =
          (meta['email_verified'] == true) || (user.emailConfirmedAt != null);
      print('authUser emailVerified? $emailVerified');

      if (emailVerified) {
        print('true email verified - navigating to main app');
        await TLocalStorage.init(user.id);
        Get.offAll(() => const NavigationMenu());
      } else {
        // If pending exists, show OTPVerificationScreen with stored email + userData
        final pendingMap = pending as Map<String, dynamic>?;
        final pendingEmail = pendingMap?['email'] as String? ?? user.email;
        final pendingUserData =
            pendingMap?['user_data'] as Map<String, dynamic>? ?? userData;
        print('Navigating to OTPVerificationScreen for $pendingEmail');
        Get.offAll(() => OTPVerificationScreen(
            email: pendingEmail ?? user.email!, userData: pendingUserData));
      }
    } else {
      deviceStorage.writeIfNull('IsFirstTime', true);
      final isFirst = deviceStorage.read('IsFirstTime') == true;
      print('No auth user. isFirstTime: $isFirst');
      deviceStorage.read('IsFirstTime') != true
          ? Get.offAll(() => const LoginScreen())
          : Get.offAll(() => const OnBoardingScreen());
    }
  }

  /// Sign up with email and send OTP
  Future<void> signUpWithEmailOTP(
      String email, Map<String, dynamic> userData) async {
    try {
      print(
          '🔄 signUpWithEmailOTP sending OTP to $email and storing pending_user_data');
      // Store user data temporarily for after verification
      await deviceStorage.write('pending_user_data', {
        'email': email,
        'user_data': userData,
      });

      // Send OTP to email. emailRedirectTo null to request OTP code (not magic link)
      final res = await _auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
        data: userData,
        emailRedirectTo: null,
      );
    } on AuthException catch (e, st) {
      print('❌ AuthException signUpWithEmailOTP: ${e.message}\n$st');
      rethrow;
    } on PlatformException catch (e, st) {
      print('❌ PlatformException signUpWithEmailOTP: ${e.message}\n$st');
      rethrow;
    } catch (e, st) {
      print('❌ Unknown error signUpWithEmailOTP: $e\n$st');
      rethrow;
    }
  }

  /// Verify OTP, save user record in DB, clear pending_user_data, and return AuthResponse
  Future<AuthResponse> verifyOTP(String email, String token) async {
    try {
      print('🔐 verifyOTP called for $email with token length ${token.length}');
      final response = await _auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );
      print(
          '✅ verifyOTP response: ${response.user?.id ?? 'no user in response'}');

      // Determine the authenticated user (response.user or currentUser)
      final supabaseUser = response.user ??
          _auth.currentUser ??
          Supabase.instance.client.auth.currentUser;
      if (supabaseUser == null) {
        throw 'Verification succeeded but no authenticated user found. Please check supabase response.';
      }

      // Load pending_user_data (we stored it on signUp)
      final pending =
          deviceStorage.read('pending_user_data') as Map<String, dynamic>?;
      final Map<String, dynamic> savedUserData =
          (pending != null && pending['user_data'] != null)
              ? Map<String, dynamic>.from(pending['user_data'] as Map)
              : <String, dynamic>{};

      // Build normalized user fields with fallbacks to avoid null errors
      String _get(Map<String, dynamic> m, String key) {
        final val = m[key];
        return val == null ? '' : val.toString();
      }

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

      print(
          '🔄 Saving user to DB from AuthenticationRepository: ${userModel.toJson()}');

      // Save using UserRepository.upsert (centralized here)
      await UserRepository.instance.saveUserRecord(userModel);

      // Clear pending_user_data now that DB is updated
      await deviceStorage.remove('pending_user_data');
      print('🗑 pending_user_data removed');

      // optionally initialize local storage for that user
      try {
        await TLocalStorage.init(userModel.id);
        print('✅ Local storage initialized for user ${userModel.id}');
      } catch (e) {
        print('⚠️ TLocalStorage.init failed: $e');
      }

      return response;
    } on AuthException catch (e, st) {
      print('❌ AuthException verifyOTP: ${e.message}\n$st');
      rethrow;
    } on PlatformException catch (e, st) {
      print('❌ PlatformException verifyOTP: ${e.message}\n$st');
      rethrow;
    } catch (e, st) {
      print('❌ Unknown error verifyOTP: $e\n$st');
      rethrow;
    }
  }

  /// Resend OTP
  Future<void> resendOTP(String email) async {
    try {
      print('🔄 resendOTP to $email');
      final res = await _auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
        emailRedirectTo: null,
      );
    } on AuthException catch (e, st) {
      print('❌ AuthException resendOTP: ${e.message}\n$st');
      rethrow;
    } on PlatformException catch (e, st) {
      print('❌ PlatformException resendOTP: ${e.message}\n$st');
      rethrow;
    } catch (e, st) {
      print('❌ Unknown error resendOTP: $e\n$st');
      rethrow;
    }
  }

  // Password reset using OTP (sends OTP)
  /*Future<void> sendPasswordResetEmail(String email) async {
    try {
      print('🔄 sendPasswordResetEmail to $email');
      final res = await _auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
        emailRedirectTo: null,
      );
      print('✅ sendPasswordResetEmail response: ');
    } on AuthException catch (e, st) {
      print('❌ AuthException sendPasswordResetEmail: ${e.message}\n$st');
      rethrow;
    } catch (e, st) {
      print('❌ Unknown sendPasswordResetEmail: $e\n$st');
      rethrow;
    }
  }*/

  Future<void> logout() async {
    try {
      print('🔒 Logging out');
      await _auth.signOut();
      await deviceStorage.remove('pending_user_data');
      Get.offAll(() => const LoginScreen());
    } on AuthException catch (e, st) {
      print('❌ AuthException logout: ${e.message}\n$st');
      rethrow;
    } catch (e, st) {
      print('❌ Unknown error logout: $e\n$st');
      rethrow;
    }
  }
  /// Envoi OTP par email
  Future<void> sendOtp(String email) async {
    try {
      await _auth.signInWithOtp(
        email: email,
        shouldCreateUser: true, // crée le user s'il n'existe pas
      );
    } catch (e) {
      TLoaders.errorSnackBar(
        title: "Erreur OTP",
        message: e.toString(),
      );
      rethrow;
    }
  }

  /// Vérification OTP
  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: otp,
      );

      if (response.user == null) {
        throw Exception("Échec de la vérification OTP.");
      }

      // Sauvegarder l’utilisateur dans UserController
      await Get.put(UserController()).saveUserRecord(response.user!);

    } catch (e) {
      TLoaders.errorSnackBar(
        title: "Erreur Vérification",
        message: e.toString(),
      );
      rethrow;
    }
  }


/*
  Future<AuthResponse> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response =
          await _auth.signInWithPassword(email: email, password: password);
      print('✅ loginWithEmailAndPassword response: ${response.user?.id}');
      return response;
    } on AuthException catch (e, st) {
      print('❌ AuthException loginWithEmailAndPassword: ${e.message}\n$st');
      rethrow;
    } catch (e, st) {
      print('❌ Unknown error loginWithEmailAndPassword: $e\n$st');
      rethrow;
    }
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
