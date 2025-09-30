import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utils/popups/loaders.dart';

class OTPVerificationController extends GetxController {
  static OTPVerificationController get instance => Get.find();

  final AuthenticationRepository _authRepo = AuthenticationRepository.instance;

  /// Champs liés à l’OTP
  final emailController = TextEditingController();
  final otpController = TextEditingController();

  /// Timer & état
  final secondsRemaining = 60.obs;
  final isResendAvailable = false.obs;
  Timer? _timer;

  final isLoading = false.obs;

  @override
  void onClose() {
    _timer?.cancel();
    emailController.dispose();
    otpController.dispose();
    super.onClose();
  }

  /// Lancer un compte à rebours de 60 secondes
  void startTimer() {
    _timer?.cancel();
    secondsRemaining.value = 60;
    isResendAvailable.value = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        isResendAvailable.value = true;
        timer.cancel();
      }
    });
  }

  /// Vérification de l’OTP
  Future<void> verifyOTP() async {
    try {
      isLoading.value = true;

      final email = emailController.text.trim();
      final otp = otpController.text.trim();

      if (email.isEmpty || otp.isEmpty) {
        TLoaders.warningSnackBar(
          title: "Champs manquants",
          message: "Veuillez entrer votre email et le code OTP.",
        );
        return;
      }

      await _authRepo.verifyOTP(email: email, otp: otp);

      // Succès => navigation déjà gérée dans AuthenticationRepository
    } catch (e) {
      TLoaders.errorSnackBar(
        title: "Erreur",
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Renvoyer un nouvel OTP
  Future<void> resendOTP() async {
    if (!isResendAvailable.value) return;

    try {
      final email = emailController.text.trim();
      if (email.isEmpty) {
        TLoaders.warningSnackBar(
          title: "Email manquant",
          message: "Veuillez entrer un email avant de renvoyer un code.",
        );
        return;
      }

      isLoading.value = true;

      await _authRepo.sendOtp(email);

      TLoaders.successSnackBar(
        title: "Code envoyé",
        message: "Un nouveau code OTP a été envoyé à $email",
      );

      startTimer();
    } catch (e) {
      TLoaders.errorSnackBar(
        title: "Erreur envoi OTP",
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
