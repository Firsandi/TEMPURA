import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/datasources/batch_remote_data_source.dart';
import '../../data/models/dashboard_model.dart';
import '../../../auth/domain/entities/user.dart';
import 'edit_batch_page.dart';

class BatchDetailPage extends StatefulWidget {
  final BatchModel batch;
  final User user;
  const BatchDetailPage({super.key, required this.batch, required this.user});

  @override
  State<BatchDetailPage> createState() => _BatchDetailPageState();
}

class _BatchDetailPageState extends State<BatchDetailPage> {
  late BatchRemoteDataSource _dataSource;
  bool _isLoading = false;
  late BatchModel _currentBatch;
  List<ProductionHistoryModel> _productionRuns = [];

  @override
  void initState() {
    super.initState();
    _currentBatch = widget.batch;
    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    _dataSource = BatchRemoteDataSource(dio);
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    try {
      final detail = await _dataSource.getBatchDetail(_currentBatch.id);
      setState(() {
        _currentBatch = detail['batch'];
        _productionRuns = detail['production_runs'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startBatch() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardGrey,
        title: const Text("Mulai Batch?", style: TextStyle(color: Colors.white)),
        content: const Text("Pastikan alat IoT sudah aktif dan terhubung ke sensor.", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Mulai", style: TextStyle(color: AppTheme.primaryGold))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _dataSource.startBatch(_currentBatch.id, widget.user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Batch berhasil dijalankan"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteBatch() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardGrey,
        title: const Text("Hapus Batch?", style: TextStyle(color: Colors.white)),
        content: const Text("Data draft batch ini akan dihapus secara permanen.", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _dataSource.deleteBatch(_currentBatch.id);
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

  Future<void> _stopBatch() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardGrey,
        title: const Text("Hentikan Batch?", style: TextStyle(color: Colors.white)),
        content: const Text("Proses fermentasi untuk batch ini akan dihentikan secara paksa.", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Hentikan", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _dataSource.stopBatch(_currentBatch.id, widget.user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Batch berhasil dihentikan paksa"), backgroundColor: Colors.orange),
        );
        Navigator.pop(context, true);
      }
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
    final batch = _currentBatch;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primaryGold),
          onPressed: () => Navigator.pop(context, true), // Pop with true to refresh list
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (batch.status == 'draft') ...[
            _buildActionIcon(Icons.delete_outline, _deleteBatch),
            const SizedBox(width: 8),
            _buildActionIcon(Icons.edit_outlined, () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditBatchPage(batch: batch)),
              );
              if (result == true) _fetchDetail();
            }),
            const SizedBox(width: 8),
            _buildActionIcon(Icons.play_arrow_outlined, _startBatch),
          ] else if (batch.status == 'active')
            _buildActionIcon(Icons.stop, _stopBatch)
          else if (batch.status == 'completed')
            _buildActionIcon(Icons.play_arrow_outlined, _startBatch),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Batch",
              style: TextStyle(color: AppTheme.primaryGold, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Text(
              batch.namaBatch,
              style: const TextStyle(color: AppTheme.primaryGold, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            _buildSummaryField("Jumlah Bungkus", "${batch.jumlahBungkus}", "Pcs"),
            const SizedBox(height: 24),
            _buildSummaryField("Jumlah Kacang Kedelai", "${batch.jumlahKedelai}", "Kg"),
            const SizedBox(height: 24),
            _buildSummaryField("Jumlah Ragi Tempe", "${batch.jumlahRagi}", "Gram"),
            
            const SizedBox(height: 48),
            const Text(
              "Riwayat Produksi",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildHistoryTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback? onPressed) {
    return IconButton(
      onPressed: _isLoading ? null : onPressed,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryGold, size: 20),
      ),
    );
  }

  Widget _buildSummaryField(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(color: AppTheme.primaryGold, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                unit,
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Expanded(flex: 2, child: Text("PRODUKSI", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text("START", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text("END", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text("STATUS", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          if (_productionRuns.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("Belum ada riwayat produksi", style: TextStyle(color: Colors.grey, fontSize: 12)),
            )
          else
            ..._productionRuns.map((run) => _buildHistoryRow(
              "Produksi ${run.runNumber}",
              DateFormat('dd/MM HH:mm').format(run.startTime),
              run.endTime != null ? DateFormat('dd/MM HH:mm').format(run.endTime!) : "--",
              run.status,
            )),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String prod, String start, String end, String status) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(prod, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(start, style: const TextStyle(color: Colors.grey, fontSize: 11))),
          Expanded(flex: 3, child: Text(end, style: const TextStyle(color: Colors.grey, fontSize: 11))),
          Expanded(flex: 3, child: Text(
            status, 
            style: TextStyle(
              color: status.contains('Berhasil') ? const Color(0xFF2ECC71) : Colors.orange, 
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          )),
        ],
      ),
    );
  }
}
