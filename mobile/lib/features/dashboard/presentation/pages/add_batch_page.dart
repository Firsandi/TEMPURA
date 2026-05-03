import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/datasources/batch_remote_data_source.dart';

class AddBatchPage extends StatefulWidget {
  const AddBatchPage({super.key});

  @override
  State<AddBatchPage> createState() => _AddBatchPageState();
}

class _AddBatchPageState extends State<AddBatchPage> {
  final _namaController = TextEditingController();
  final _bungkusController = TextEditingController();
  final _kedelaiController = TextEditingController();
  final _ragiController = TextEditingController();
  
  late BatchRemoteDataSource _dataSource;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    _dataSource = BatchRemoteDataSource(dio);
    
    _namaController.text = "";
    _bungkusController.text = "";
    _kedelaiController.text = "";
    _ragiController.text = "";
  }

  Future<void> _submit() async {
    if (_namaController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      await _dataSource.createBatch(
        namaBatch: "TMP-${_namaController.text}",
        jumlahBungkus: int.tryParse(_bungkusController.text) ?? 0,
        jumlahKedelai: double.tryParse(_kedelaiController.text) ?? 0,
        jumlahRagi: int.tryParse(_ragiController.text) ?? 0,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(""),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tambah Batch\nProduksi",
              style: TextStyle(
                color: AppTheme.primaryGold,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 40),
            _buildField("Nama Batch", _namaController, null, prefix: "TMP-"),
            const SizedBox(height: 24),
            _buildField("Jumlah Bungkus", _bungkusController, "Pcs"),
            const SizedBox(height: 24),
            _buildField("Jumlah Kacang Kedelai", _kedelaiController, "Kg"),
            const SizedBox(height: 24),
            _buildField("Jumlah Ragi Tempe", _ragiController, "Gram"),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text("Tambah", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String? suffix, {String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: (label != "Nama Batch") ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: AppTheme.primaryGold, fontSize: 20, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            fillColor: const Color(0xFF1E1E1E),
            filled: true,
            prefixIcon: prefix != null 
              ? Padding(
                  padding: const EdgeInsets.only(left: 20, right: 10),
                  child: Text(prefix, style: const TextStyle(color: AppTheme.primaryGold, fontSize: 20, fontWeight: FontWeight.bold)),
                )
              : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: suffix != null 
              ? Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: Text(suffix, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ) 
              : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryGold, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}
