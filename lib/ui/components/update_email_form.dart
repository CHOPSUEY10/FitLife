import 'package:flutter/material.dart';
import '../../features/profile/logic/profile_account_controller.dart';

class UpdateEmailForm extends StatefulWidget {
  final ProfileAccountController controller;

  const UpdateEmailForm({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<UpdateEmailForm> createState() => _UpdateEmailFormState();
}

class _UpdateEmailFormState extends State<UpdateEmailForm> {
  static const Color bgColor = Color(0xFF0F0C1B);
  static const Color cardColor = Color(0xFF1A1A2E);
  static const Color limeGreen = Color(0xFFC6FF00);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF888888);
  static const Color borderColor = Color(0xFF2A2A3E);

  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrentPassword = true;

  @override
  void initState() {
    super.initState();
    widget.controller.clearMessages();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _emailController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final controller = widget.controller;

      if (controller.needsReauth) {
        // We need reauth first
        final success = await controller.verifyAndRetryEmail(
          _currentPasswordController.text,
          _emailController.text,
        );
        if (success && mounted) {
          _currentPasswordController.clear();
        }
      } else {
        // Normal update
        await controller.changeEmail(_emailController.text);
      }
    }
  }

  Future<void> _submitGoogleReauth() async {
    FocusScope.of(context).unfocus();
    await widget.controller.verifyAndRetryEmail(null, _emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
                    'Ubah Email',
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
              const SizedBox(height: 20),
              
              // Email input (disabled if needs re-auth)
              const Text(
                'Email Baru',
                style: TextStyle(
                  color: grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                enabled: !controller.needsReauth && !controller.isEmailLoading,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cardColor,
                  hintText: 'Masukkan email baru',
                  hintStyle: const TextStyle(color: grey),
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
                  if (value == null || value.trim().isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!controller.validateEmailFormat(value.trim())) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),

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

              // Error Messages
              if (controller.emailError != null && !controller.needsReauth) ...[
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
                          controller.emailError!,
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
              if (controller.emailSuccessMessage != null) ...[
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
                          controller.emailSuccessMessage!,
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
                  onPressed: (controller.isEmailLoading || controller.isReauthLoading)
                      ? null
                      : (controller.needsReauth && controller.signInProvider == 'google.com'
                          ? _submitGoogleReauth
                          : _submit),
                  child: (controller.isEmailLoading || controller.isReauthLoading)
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
                              : 'Simpan Perubahan',
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
    );
  }
}
