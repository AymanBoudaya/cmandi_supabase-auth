import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/signup/verify_otp_controller.dart';

class OTPVerificationScreen extends StatelessWidget {
  final String email;
  final Map<String, dynamic> userData;

  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OTPVerificationController());
    controller.emailController.text = email;
    controller.startTimer();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification OTP'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Vérification de code',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Entrez le code reçu à l\'adresse $email',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // OTP Fields (pas besoin de Obx ici)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  child: TextField(
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty) {
                        final text = controller.otpController.text;
                        final newText = text.padRight(6, ' ');
                        controller.otpController.text =
                            newText.replaceRange(index, index + 1, val);

                        if (index < 5) FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),

            // Verify Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.verifyOTP(),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Vérifier'),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Resend OTP Section
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Vous n'avez pas reçu le code ? "),
                  TextButton(
                    onPressed: controller.isResendAvailable.value
                        ? () => controller.resendOTP()
                        : null,
                    child: Text(
                      controller.isResendAvailable.value
                          ? 'Renvoyer'
                          : 'Renvoyer (${controller.secondsRemaining.value}s)',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
