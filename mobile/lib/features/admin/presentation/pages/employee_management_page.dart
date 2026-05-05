import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_theme.dart';
import 'edit_employee_page.dart';

class EmployeeManagementPage extends StatefulWidget {
  const EmployeeManagementPage({super.key});

  @override
  State<EmployeeManagementPage> createState() => _EmployeeManagementPageState();
}

class _EmployeeManagementPageState extends State<EmployeeManagementPage> {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8080"));
  List<dynamic> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.get('/users');
      setState(() {
        _employees = response.data['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showSnackbar('Gagal memuat data pegawai', true);
      }
    }
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

  void _showAddEmployeeDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardGrey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Tambah Pegawai",
              style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField("Nama Lengkap", nameCtrl, Icons.person_outline),
                const SizedBox(height: 16),
                _buildDialogTextField("Email", emailCtrl, Icons.email_outlined),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: AppTheme.primaryGold, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text("Password akan dikirim otomatis ke email pegawai.",
                            style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (nameCtrl.text.trim().isEmpty) {
                        _showSnackbar("Nama lengkap tidak boleh kosong", true);
                        return;
                      }
                      if (emailCtrl.text.trim().isEmpty) {
                        _showSnackbar("Email tidak boleh kosong", true);
                        return;
                      }
                      setDialogState(() => isSubmitting = true);
                      try {
                        await _dio.post('/users', data: {
                          "full_name": nameCtrl.text.trim(),
                          "email": emailCtrl.text.trim(),
                        });
                        if (mounted) {
                          Navigator.pop(ctx);
                          _fetchEmployees();
                          _showSnackbar('Pegawai berhasil ditambahkan! Email telah dikirim.', false);
                        }
                      } on DioException catch (e) {
                        setDialogState(() => isSubmitting = false);
                        _showSnackbar(
                          e.response?.data['error'] ?? 'Gagal menambahkan pegawai',
                          true,
                        );
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        _showSnackbar('Gagal: $e', true);
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
              child: isSubmitting
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text("Simpan",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEdit(Map<String, dynamic> emp) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditEmployeePage(employee: emp)),
    );
    if (result == true) {
      _fetchEmployees();
    }
  }

  Future<void> _deleteEmployee(String id) async {
    try {
      await _dio.delete('/users/$id');
      _fetchEmployees();
      if (mounted) _showSnackbar('Pegawai berhasil dihapus', false);
    } catch (e) {
      if (mounted) _showSnackbar('Gagal menghapus pegawai', true);
    }
  }

  void _confirmDelete(Map<String, dynamic> emp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Pegawai", style: TextStyle(color: Colors.white)),
        content: Text("Yakin ingin menghapus ${emp['full_name']}?",
            style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteEmployee(emp['id'].toString());
            },
            child: const Text("Hapus", style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primaryGold.withOpacity(0.7), size: 20),
            hintText: "Masukkan $label",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14),
            fillColor: Colors.black.withOpacity(0.2),
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryGold),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        title: const Text("Manajemen Pegawai",
            style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.backgroundBlack,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _fetchEmployees,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
          : _employees.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.people_outline, size: 64, color: Colors.white12),
                      SizedBox(height: 16),
                      Text("Belum ada pegawai",
                          style: TextStyle(color: Colors.white38, fontSize: 16)),
                      SizedBox(height: 8),
                      Text("Tekan tombol + untuk menambah pegawai baru",
                          style: TextStyle(color: Colors.white24, fontSize: 12)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _employees.length,
                  itemBuilder: (context, index) {
                    final emp = _employees[index];
                    return Card(
                      color: AppTheme.cardGrey,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryGold.withOpacity(0.15),
                          child: const Icon(Icons.person, color: AppTheme.primaryGold),
                        ),
                        title: Text(
                          emp['full_name'] ?? '',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(emp['email'] ?? '',
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white54),
                          color: AppTheme.cardGrey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _navigateToEdit(emp);
                            } else if (value == 'delete') {
                              _confirmDelete(emp);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined,
                                      color: AppTheme.primaryGold, size: 20),
                                  SizedBox(width: 10),
                                  Text("Edit", style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline,
                                      color: AppTheme.accentRed, size: 20),
                                  SizedBox(width: 10),
                                  Text("Hapus",
                                      style: TextStyle(color: AppTheme.accentRed)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEmployeeDialog,
        backgroundColor: AppTheme.primaryGold,
        icon: const Icon(Icons.person_add_outlined, color: Colors.black),
        label: const Text("Tambah Pegawai",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
