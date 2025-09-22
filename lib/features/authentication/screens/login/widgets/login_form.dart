import 'package:caferesto/features/authentication/controllers/login/login_controller.dart';
import 'package:caferesto/features/authentication/screens/signup.widgets/signup.dart';
import 'package:caferesto/utils/constants/sizes.dart';
import 'package:caferesto/utils/constants/text_strings.dart';
import 'package:caferesto/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:iconsax/iconsax.dart';

import '../../password-config/forget_password.dart';

class TLoginForm extends StatelessWidget {
  const TLoginForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    return Form(
        key: controller.loginFormKey,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: AppSizes.spaceBtwSections),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Email
              TextFormField(
                  controller: controller.email,
                  validator: (value) => TValidator.validateEmail(value),
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.direct_right),
                      labelText: TTexts.email)),
              const SizedBox(
                height: AppSizes.spaceBtwInputFields,
              ),
              /*Obx(
                () => TextFormField(
                  controller: controller.password,
                  validator: (value) => TValidator.validatePassword(value),
                  obscureText: controller.hidePassword.value,
                  decoration: InputDecoration(
                    labelText: TTexts.password,
                    prefixIcon: const Icon(Iconsax.password_check),
                    suffixIcon: IconButton(
                        onPressed: () => controller.hidePassword.value =
                            !controller.hidePassword.value,
                        icon: Icon(
                          controller.hidePassword.value
                              ? Iconsax.eye_slash
                              : Iconsax.eye,
                        )),
                  ),
                ),
              ),
              const SizedBox(
                height: AppSizes.spaceBtwInputFields / 2,
              ),

              /// Remember Me & Forget Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Remember Me
                  Flexible(
                    child: Row(
                      children: [
                        Obx(() => Checkbox(
                            value: controller.rememberMe.value,
                            onChanged: (value) => controller.rememberMe.value =
                                !controller.rememberMe.value)),
                        Flexible(child: const Text(TTexts.rememberMe))
                      ],
                    ),
                  ),

                  /// Forget Password
                  TextButton(
                      onPressed: () => Get.to(() => const ForgetPassword()),
                      child: const Text(TTexts.forgetPassword))
                ],
              ),
              const SizedBox(
                height: AppSizes.spaceBtwSections,
              ),

              /// Sign in button
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () => controller.emailAndPasswordSignIn(),
                      child: const Text(TTexts.signIn))),

*/

              /// Bouton envoyer OTP
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.emailOtpSignIn(),
                  child: const Text("Recevoir un code OTP"),
                ),
              ),
              const SizedBox(
                height: AppSizes.spaceBtwItems / 2,
              ),

              /// Create account button
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                      onPressed: () => Get.to(() => const SignupScreen()),
                      child: const Text(TTexts.createAccount)))
            ],
          ),
        ));
  }
}
