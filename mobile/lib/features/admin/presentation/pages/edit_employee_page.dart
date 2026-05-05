import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_theme.dart';

class EditEmployeePage extends StatefulWidget {
  final Map<String, dynamic> employee;
  const EditEmployeePage({super.key, required this.employee});

  @override
  State<EditEmployeePage> createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends State<EditEmployeePage> {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8080"));
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.employee['full_name'] ?? '');
    _emailCtrl = TextEditingController(text: widget.employee['email'] ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white, size: 20,
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

  Future<void> _saveChanges() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty) {
      _showSnackbar("Nama lengkap tidak boleh kosong", true);
      return;
    }
    if (email.isEmpty) {
      _showSnackbar("Email tidak boleh kosong", true);
      return;
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      _showSnackbar("Format email tidak valid", true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _dio.put('/users/${widget.employee['id']}', data: {
        "full_name": name,
        "email": email,
      });
      if (mounted) {
        _showSnackbar("Data pegawai berhasil diperbarui", false);
        Navigator.pop(context, true); // true = ada perubahan
      }
    } on DioException catch (e) {
      _showSnackbar(
        e.response?.data['error'] ?? 'Gagal memperbarui data',
        true,
      );
    } catch (e) {
      _showSnackbar('Gagal: $e', true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Edit Pegawai",
            style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryGold.withOpacity(0.15),
                    child: const Icon(Icons.person, size: 40, color: AppTheme.primaryGold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.employee['full_name'] ?? '',
                    style: const TextStyle(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.employee['email'] ?? '',
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Form Fields
            _buildLabel("NAMA LENGKAP"),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _nameCtrl,
              hint: "Masukkan nama lengkap",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 24),

            _buildLabel("EMAIL"),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _emailCtrl,
              hint: "Masukkan email",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 48),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 5,
                  shadowColor: AppTheme.primaryGold.withOpacity(0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.save_outlined, size: 20),
                          SizedBox(width: 10),
                          Text("SIMPAN PERUBAHAN",
                              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ],
                      ),
              ),
            ),
          ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        prefixIcon: Icon(icon, color: AppTheme.primaryGold.withOpacity(0.7), size: 22),
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
