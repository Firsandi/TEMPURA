import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/repositories/auth_repository.dart';

import 'verify_otp_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  final _authRepository = sl<AuthRepository>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestToken() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackbar("Email tidak boleh kosong", true);
      return;
    }

    // Validasi format email
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      _showSnackbar("Format email tidak valid", true);
      return;
    }

    setState(() => _isLoading = true);
    final result = await _authRepository.forgotPassword(email);
    
    setState(() => _isLoading = false);
    
    result.fold(
      (failure) => _showSnackbar(failure.message, true),
      (message) async {
        _showSnackbar("Kode OTP berhasil dikirim ke $email", false);
        // Delay agar user sempat membaca pesan sebelum pindah halaman
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyOTPPage(email: email),
            ),
          );
        }
      },
    );
  }

  void _showSnackbar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: isError ? AppTheme.accentRed : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Lupa\nKata Sandi",
                        style: TextStyle(
                          color: AppTheme.primaryGold,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Masukkan email terdaftar Anda. Kami akan mengirimkan kode verifikasi untuk mereset password.",
                        style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 48),
                      
                      _buildLabel("EMAIL TERDAFTAR"),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: "contoh@email.com",
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                          prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryGold, size: 22),
                          fillColor: const Color(0xFF1A1A1A),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.primaryGold, width: 1),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _requestToken,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGold,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 5,
                            shadowColor: AppTheme.primaryGold.withOpacity(0.4),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text("KIRIM KODE VERIFIKASI",
                                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    SizedBox(width: 8),
                                    Icon(Icons.send_rounded, size: 18),
                                  ],
                                ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Back to login
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: RichText(
                              text: const TextSpan(
                                text: "Ingat kata sandi? ",
                                style: TextStyle(color: Colors.white38, fontSize: 13),
                                children: [
                                  TextSpan(
                                    text: "Masuk",
                                    style: TextStyle(
                                      color: AppTheme.primaryGold,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.primaryGold,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }
}
