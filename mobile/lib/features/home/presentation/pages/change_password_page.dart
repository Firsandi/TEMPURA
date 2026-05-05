import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';

class ChangePasswordPage extends StatefulWidget {
  final int userId;
  const ChangePasswordPage({super.key, required this.userId});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _oldFocus = FocusNode();
  final _newFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _oldFocus.dispose();
    _newFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
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
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppTheme.accentRed : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _changePassword() async {
    final oldPass = _oldPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (oldPass.isEmpty) {
      _showSnackbar("Harap masukkan kata sandi lama", true);
      _oldFocus.requestFocus();
      return;
    }
    if (newPass.isEmpty) {
      _showSnackbar("Harap masukkan kata sandi baru", true);
      _newFocus.requestFocus();
      return;
    }
    if (newPass.length < 6) {
      _showSnackbar("Kata sandi baru minimal 6 karakter", true);
      _newFocus.requestFocus();
      return;
    }
    if (confirmPass.isEmpty) {
      _showSnackbar("Harap konfirmasi kata sandi baru", true);
      _confirmFocus.requestFocus();
      return;
    }
    if (newPass != confirmPass) {
      _showSnackbar("Konfirmasi kata sandi tidak cocok", true);
      _confirmFocus.requestFocus();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      await dio.post('/auth/change-password', data: {
        'user_id': widget.userId,
        'old_password': oldPass,
        'new_password': newPass,
      });

      if (mounted) {
        _showSuccessDialog();
      }
    } on DioException catch (e) {
      _showSnackbar(
        e.response?.data['error'] ?? 'Gagal mengubah kata sandi',
        true,
      );
    } catch (e) {
      _showSnackbar("Terjadi kesalahan: $e", true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            ),
            const SizedBox(height: 24),
            const Text(
              "Berhasil!",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Kata sandi Anda telah berhasil diperbarui.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Pop dialog
                  Navigator.pop(context); // Pop page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("KEMBALI KE PROFIL", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
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
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primaryGold, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              AppTheme.primaryGold.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Hero(
                  tag: 'lock-icon',
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.lock_reset_rounded, color: AppTheme.primaryGold, size: 40),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Ubah\nKata Sandi",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Pastikan kata sandi baru Anda aman dan sulit ditebak oleh orang lain.",
                  style: TextStyle(color: Colors.white38, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 48),
                
                _buildField(
                  label: "KATA SANDI LAMA",
                  controller: _oldPasswordController,
                  focusNode: _oldFocus,
                  nextFocus: _newFocus,
                  obscure: _obscureOld,
                  onToggle: () => setState(() => _obscureOld = !_obscureOld),
                ),
                const SizedBox(height: 28),
                
                _buildField(
                  label: "KATA SANDI BARU",
                  controller: _newPasswordController,
                  focusNode: _newFocus,
                  nextFocus: _confirmFocus,
                  obscure: _obscureNew,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                ),
                const SizedBox(height: 28),
                
                _buildField(
                  label: "KONFIRMASI SANDI",
                  controller: _confirmPasswordController,
                  focusNode: _confirmFocus,
                  isLast: true,
                  obscure: _obscureConfirm,
                  onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  onSubmitted: (_) => _changePassword(),
                ),
                
                const SizedBox(height: 60),
                
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 10,
                      shadowColor: AppTheme.primaryGold.withOpacity(0.4),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 3)
                        : const Text(
                            "SIMPAN PERUBAHAN",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required bool obscure,
    required VoidCallback onToggle,
    bool isLast = false,
    Function(String)? onSubmitted,
  }) {
    final bool isFocused = focusNode.hasFocus;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isFocused ? AppTheme.primaryGold : Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isFocused ? Colors.white.withOpacity(0.05) : const Color(0xFF121212),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFocused ? AppTheme.primaryGold : Colors.white.withOpacity(0.1),
              width: isFocused ? 1.5 : 1,
            ),
            boxShadow: isFocused ? [
              BoxShadow(
                color: AppTheme.primaryGold.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscure,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
            onSubmitted: (val) {
              if (isLast) {
                if (onSubmitted != null) onSubmitted(val);
              } else {
                nextFocus?.requestFocus();
              }
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              border: InputBorder.none,
              hintText: "••••••••",
              hintStyle: const TextStyle(color: Colors.white12),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: isFocused ? AppTheme.primaryGold : Colors.white24,
                  size: 20,
                ),
                onPressed: onToggle,
              ),
            ),
            onTap: () => setState(() {}),
          ),
        ),
      ],
    );
  }
}
