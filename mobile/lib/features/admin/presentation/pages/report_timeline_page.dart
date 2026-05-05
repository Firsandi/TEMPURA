import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../utils/report_generator.dart';

class ReportTimelinePage extends StatefulWidget {
  final String batchId;
  const ReportTimelinePage({super.key, required this.batchId});

  @override
  State<ReportTimelinePage> createState() => _ReportTimelinePageState();
}

class _ReportTimelinePageState extends State<ReportTimelinePage> {
  final Dio _dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8080"));
  Map<String, dynamic>? _batch;
  List<dynamic> _runs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.get('/batch/${widget.batchId}');
      setState(() {
        _batch = response.data['data']['batch'];
        _runs = response.data['data']['production_runs'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat detail: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }

  void _downloadPdf() async {
    if (_batch == null) return;
    try {
      final path = await ReportGenerator.generatePdf(_batch!, _runs);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF berhasil disimpan di: $path'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat PDF: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }

  void _downloadExcel() async {
    if (_batch == null) return;
    try {
      final path = await ReportGenerator.generateExcel(_batch!, _runs);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel berhasil disimpan di: $path'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat Excel: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        title: const Text("Detail Laporan", style: TextStyle(color: AppTheme.primaryGold)),
        backgroundColor: AppTheme.backgroundBlack,
        elevation: 0,
        actions: [
          if (!_isLoading && _batch != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.download, color: AppTheme.primaryGold),
              color: AppTheme.cardGrey,
              onSelected: (value) {
                if (value == 'pdf') _downloadPdf();
                if (value == 'excel') _downloadExcel();
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'pdf',
                  child: Text('Unduh PDF', style: TextStyle(color: Colors.white)),
                ),
                const PopupMenuItem<String>(
                  value: 'excel',
                  child: Text('Unduh Excel (XLSX)', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBatchInfo(),
                  const SizedBox(height: 24),
                  const Text("Timeline Produksi", style: TextStyle(color: AppTheme.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ..._runs.map((run) => _buildTimelineItem(run)).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildBatchInfo() {
    if (_batch == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_batch!['nama_batch'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _infoRow("Status", _batch!['status_batch'] ?? '-'),
          _infoRow("Kedelai", "${_batch!['jumlah_kedelai']} kg"),
          _infoRow("Ragi", "${_batch!['jumlah_ragi']} g"),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(dynamic run) {
    final startFormat = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(run['start_time']).toLocal());
    final endFormat = run['end_time'] != null ? DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(run['end_time']).toLocal()) : 'Berjalan';
    final startedBy = run['started_by_name'] ?? 'Sistem';
    final stoppedBy = run['stopped_by_name'];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(color: AppTheme.primaryGold, shape: BoxShape.circle),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: AppTheme.primaryGold.withOpacity(0.3),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Run #${run['run_number']}", style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.play_circle_outline, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text("Mulai: $startFormat", style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                    Text("Oleh: $startedBy", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    if (run['end_time'] != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.stop_circle_outlined, color: AppTheme.accentRed, size: 16),
                          const SizedBox(width: 8),
                          Text("Selesai: $endFormat", style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                      Text("Oleh: ${stoppedBy ?? 'Sistem'}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text("Status: ${run['status']}", style: const TextStyle(color: AppTheme.primaryGold, fontSize: 12, fontStyle: FontStyle.italic)),
                    ] else ...[
                      const Text("Status: Sedang Berjalan", style: TextStyle(color: Colors.green, fontSize: 12)),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
