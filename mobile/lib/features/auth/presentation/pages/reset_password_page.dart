import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/repositories/auth_repository.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String token;

  const ResetPasswordPage({super.key, required this.email, required this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  final _authRepository = sl<AuthRepository>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty) {
      _showSnackbar("Kata sandi baru tidak boleh kosong", true);
      return;
    }

    if (password.length < 6) {
      _showSnackbar("Kata sandi minimal 6 karakter", true);
      return;
    }

    if (confirm.isEmpty) {
      _showSnackbar("Konfirmasi kata sandi tidak boleh kosong", true);
      return;
    }

    if (password != confirm) {
      _showSnackbar("Konfirmasi kata sandi tidak cocok", true);
      return;
    }

    setState(() => _isLoading = true);
    final result = await _authRepository.resetPassword(
      email: widget.email,
      token: widget.token,
      newPassword: password,
    );
    
    setState(() => _isLoading = false);
    
    result.fold(
      (failure) => _showSnackbar(failure.message, true),
      (message) {
        _showSnackbar("Kata sandi berhasil diperbarui! Silakan login.", false);
        Navigator.popUntil(context, (route) => route.isFirst);
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
                        "Buat\nSandi Baru",
                        style: TextStyle(
                          color: AppTheme.primaryGold,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Silakan masukkan kata sandi baru untuk akun Anda. Pastikan mudah diingat namun sulit ditebak.",
                        style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 48),
                      
                      _buildLabel("KATA SANDI BARU"),
                      const SizedBox(height: 12),
                      _buildPasswordField(
                        controller: _passwordController,
                        hint: "Minimal 6 karakter",
                        isVisible: _isPasswordVisible,
                        onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      _buildLabel("KONFIRMASI KATA SANDI"),
                      const SizedBox(height: 12),
                      _buildPasswordField(
                        controller: _confirmController,
                        hint: "Ulangi kata sandi baru",
                        isVisible: _isConfirmVisible,
                        onToggle: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGold,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 5,
                            shadowColor: AppTheme.primaryGold.withOpacity(0.4),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text("SIMPAN PERUBAHAN",
                                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    SizedBox(width: 8),
                                    Icon(Icons.save_outlined, size: 18),
                                  ],
                                ),
                        ),
                      ),
                      
                      const Spacer(),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryGold, size: 22),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.white38,
            size: 20,
          ),
          onPressed: onToggle,
        ),
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
    );
  }
}
