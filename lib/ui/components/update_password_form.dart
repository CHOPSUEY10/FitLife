import 'package:flutter/material.dart';
import '../../features/profile/logic/profile_account_controller.dart';
import 'otp_input_field.dart';

class UpdatePasswordForm extends StatefulWidget {
  final ProfileAccountController controller;

  const UpdatePasswordForm({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<UpdatePasswordForm> createState() => _UpdatePasswordFormState();
}

class _UpdatePasswordFormState extends State<UpdatePasswordForm> {
  static const Color bgColor = Color(0xFF0F0C1B);
  static const Color cardColor = Color(0xFF1A1A2E);
  static const Color limeGreen = Color(0xFFC6FF00);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF888888);
  static const Color borderColor = Color(0xFF2A2A3E);

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscureCurrentPassword = true;
  String _otpCode = "";

  @override
  void initState() {
    super.initState();
    widget.controller.clearMessages();
    widget.controller.addListener(_onControllerChanged);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final controller = widget.controller;

      if (controller.needsReauth) {
        // We need reauth first
        final success = await controller.verifyAndRetryPassword(
          _currentPasswordController.text,
          _passwordController.text,
          _confirmPasswordController.text,
        );
        if (success && mounted) {
          _currentPasswordController.clear();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kata sandi berhasil diperbarui.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else if (!controller.passwordOtpSent) {
        // Step 1: Send OTP
        await controller.sendPasswordOtp(
          _passwordController.text,
          _confirmPasswordController.text,
        );
      } else {
        // Step 2: Verify OTP & change password
        final success = await controller.verifyAndChangePassword(
          _otpCode,
          _passwordController.text,
          _confirmPasswordController.text,
        );
        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kata sandi berhasil diperbarui.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _submitGoogleReauth() async {
    FocusScope.of(context).unfocus();
    final success = await widget.controller.verifyAndRetryPassword(
      null,
      _passwordController.text,
      _confirmPasswordController.text,
    );
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi berhasil diperbarui.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }



  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom - 24,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(
            top: BorderSide(color: borderColor, width: 1.5),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ubah Kata Sandi',
                    style: TextStyle(
                      color: white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: white),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                // Input Form (disabled if OTP is sent or needs re-auth)
                const Text(
                  'Kata Sandi Baru',
                  style: TextStyle(
                    color: grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !controller.needsReauth && !controller.isPasswordLoading && !controller.passwordOtpSent,
                  style: const TextStyle(color: white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: cardColor,
                    hintText: 'Masukkan kata sandi baru',
                    hintStyle: const TextStyle(color: grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: limeGreen,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: limeGreen),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kata sandi tidak boleh kosong';
                    }
                    if (!controller.validatePasswordStrength(value)) {
                      return 'Kata sandi minimal harus 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Konfirmasi Kata Sandi Baru',
                  style: TextStyle(
                    color: grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  enabled: !controller.needsReauth && !controller.isPasswordLoading && !controller.passwordOtpSent,
                  style: const TextStyle(color: white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: cardColor,
                    hintText: 'Konfirmasi kata sandi baru',
                    hintStyle: const TextStyle(color: grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: limeGreen,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: limeGreen),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi kata sandi tidak boleh kosong';
                    }
                    if (value != _passwordController.text) {
                      return 'Konfirmasi kata sandi tidak cocok';
                    }
                    return null;
                  },
                ),

                // OTP Input Section
                if (controller.passwordOtpSent && !controller.needsReauth) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Masukkan 6 Digit Kode OTP',
                    style: TextStyle(
                      color: limeGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OtpInputField(
                    length: 6,
                    onChanged: (value) {
                      setState(() {
                        _otpCode = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          controller.passwordOtpCountdown > 0
                              ? "Kirim ulang kode dalam ${controller.passwordOtpCountdown}s"
                              : "Tidak menerima kode?",
                          style: const TextStyle(color: grey, fontSize: 14),
                        ),
                        if (controller.canResendPasswordOtp) ...[
                          GestureDetector(
                            onTap: (controller.isPasswordOtpLoading || controller.isPasswordLoading)
                                ? null
                                : () => controller.sendPasswordOtp(
                                      _passwordController.text,
                                      _confirmPasswordController.text,
                                    ),
                            child: const Text(
                              "Kirim Ulang",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Re-authentication Section
                if (controller.needsReauth) ...[
                  const SizedBox(height: 20),
                  if (controller.signInProvider == 'password') ...[
                    const Text(
                      'Kata Sandi Saat Ini (Verifikasi Keamanan)',
                      style: TextStyle(
                        color: limeGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      style: const TextStyle(color: white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: cardColor,
                        hintText: 'Masukkan kata sandi saat ini',
                        hintStyle: const TextStyle(color: grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                            color: limeGreen,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword = !_obscureCurrentPassword;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: limeGreen),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan kata sandi saat ini untuk melanjutkan';
                        }
                        return null;
                      },
                    ),
                  ] else if (controller.signInProvider == 'google.com') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: limeGreen.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: limeGreen.withAlpha(76)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: limeGreen, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Sesi Anda memerlukan verifikasi ulang Google. Silakan ketuk tombol verifikasi di bawah.',
                              style: TextStyle(color: white, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],

                // OTP Error Message
                if (controller.passwordOtpError != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withAlpha(76)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.passwordOtpError!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Error Messages
                if (controller.passwordError != null && !controller.needsReauth) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withAlpha(76)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.passwordError!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (controller.reauthError != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withAlpha(76)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.reauthError!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Success Message
                if (controller.passwordSuccessMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: limeGreen.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: limeGreen.withAlpha(76)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: limeGreen, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.passwordSuccessMessage!,
                            style: const TextStyle(color: limeGreen, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                // Dynamic Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: limeGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: (controller.isPasswordLoading ||
                            controller.isReauthLoading ||
                            controller.isPasswordOtpLoading ||
                            (!controller.needsReauth && controller.passwordOtpSent && _otpCode.length != 6))
                        ? null
                        : (controller.needsReauth && controller.signInProvider == 'google.com'
                            ? _submitGoogleReauth
                            : _submit),
                    child: (controller.isPasswordLoading ||
                            controller.isReauthLoading ||
                            controller.isPasswordOtpLoading)
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            controller.needsReauth
                                ? (controller.signInProvider == 'google.com'
                                    ? 'Verifikasi dengan Google'
                                    : 'Verifikasi & Simpan')
                                : (!controller.passwordOtpSent
                                    ? 'Kirim Kode Verifikasi'
                                    : 'Verifikasi & Simpan Perubahan'),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
