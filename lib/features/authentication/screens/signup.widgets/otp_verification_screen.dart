import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/signup/verify_otp_controller.dart';


class OTPVerificationScreen extends StatelessWidget {
  final String email;
  final Map<String, dynamic> userData;
  
  const OTPVerificationScreen({
    super.key, 
    required this.email,
    required this.userData
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OTPVerificationController());
    final otpController = TextEditingController();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification OTP'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Text(
              'Vérification de code',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Entrez le code reçu à l\'adresse $email',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // OTP Input Field
            TextFormField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: 'Code OTP',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            
            // Verify Button
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.verifyOTP(email, otpController.text.trim(), userData),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator()
                    : const Text('Vérifier'),
              ),
            )),
            const SizedBox(height: 20),
            
            // Resend OTP Section
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Vous n'avez pas reçu le code?",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: controller.canResendOTP.value
                      ? () => controller.resendOTP(email)
                      : null,
                  child: Text(
                    controller.canResendOTP.value
                        ? 'Renvoyer'
                        : 'Renvoyer (${controller.resendCountdown.value}s)',
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}