import 'package:flutter/material.dart';

import 'package:bbeez_one/platform/core/service_locator.dart';
import 'package:bbeez_one/platform/repositories/settings_repository.dart';
import 'package:bbeez_one/platform/security/biometric_service.dart';
import 'package:bbeez_one/platform/security/security_service.dart';
import 'package:bbeez_one/apps/one/widgets/common_appbar.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final currentController = TextEditingController();

  final newController = TextEditingController();

  final confirmController = TextEditingController();

  bool currentObscure = true;
  bool newObscure = true;
  bool confirmObscure = true;

  bool isLoading = false;
  bool biometricEnabled = false;
  bool isBiometricVerified = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final enabled = await locate<SettingsRepository>().getBiometricEnabled();
    final available = await BiometricService.isBiometricAvailable();
    setState(() {
      biometricEnabled = enabled && available;
    });
  }

  Future<void> verifyWithBiometric() async {
    final authenticated = await BiometricService.authenticate();
    if (authenticated) {
      setState(() {
        isBiometricVerified = true;
        currentController.clear();
      });
      showMessage('Biometric Verified');
    }
  }

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> updatePassword() async {
    final current = currentController.text.trim();
    final newPass = newController.text.trim();
    final confirm = confirmController.text.trim();

    if (!isBiometricVerified && current.isEmpty) {
      showMessage('Please enter current password or use biometric');
      return;
    }

    if (newPass.isEmpty || confirm.isEmpty) {
      showMessage('Please fill all fields');
      return;
    }

    if (newPass.length < 6) {
      showMessage('Password must be at least 6 characters');
      return;
    }

    if (newPass != confirm) {
      showMessage('Passwords do not match');
      return;
    }

    setState(() {
      isLoading = true;
    });

    bool success = false;
    if (isBiometricVerified) {
      await SecurityService.setNewPassword(newPass);
      success = true;
    } else {
      success = await SecurityService.changePassword(
        currentPassword: current,
        newPassword: newPass,
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      showMessage('Password Updated Successfully');
      Navigator.pop(context);
    } else {
      showMessage('Current password incorrect');
    }
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  Widget passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.white70,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(
            22,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
            ),
            onPressed: toggle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(
        context,
        "Password",
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF062B68),
              Color(0xFF00153C),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              22,
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Change Master Password",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  padding: const EdgeInsets.all(
                    24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: Colors.white,
                      ),
                      if (biometricEnabled && !isBiometricVerified)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: TextButton.icon(
                            onPressed: isLoading ? null : verifyWithBiometric,
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Colors.white.withValues(alpha: .05),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              side: BorderSide(
                                  color: const Color(0xFF14F1FF)
                                      .withValues(alpha: 0.3)),
                            ),
                            icon: const Icon(Icons.fingerprint,
                                color: Color(0xFF14F1FF)),
                            label: const Text(
                              "VERIFY WITH BIOMETRIC",
                              style: TextStyle(
                                  color: Color(0xFF14F1FF),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      if (isBiometricVerified)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.green.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 10),
                              Text(
                                "Biometric Verified",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      if (!isBiometricVerified)
                        passwordField(
                          controller: currentController,
                          label: "Current Password",
                          obscure: currentObscure,
                          toggle: () {
                            setState(() {
                              currentObscure = !currentObscure;
                            });
                          },
                        ),
                      passwordField(
                        controller: newController,
                        label: "New Password",
                        obscure: newObscure,
                        toggle: () {
                          setState(() {
                            newObscure = !newObscure;
                          });
                        },
                      ),
                      passwordField(
                        controller: confirmController,
                        label: "Confirm Password",
                        obscure: confirmObscure,
                        toggle: () {
                          setState(() {
                            confirmObscure = !confirmObscure;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF8F6BFF,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                18,
                              ),
                            ),
                          ),
                          onPressed: isLoading ? null : updatePassword,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Update Password",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
