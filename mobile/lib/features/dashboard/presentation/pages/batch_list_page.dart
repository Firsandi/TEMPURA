import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/datasources/batch_remote_data_source.dart';
import '../../data/models/dashboard_model.dart';
import '../../../auth/domain/entities/user.dart';
import 'add_batch_page.dart';
import 'batch_detail_page.dart';

class BatchListPage extends StatefulWidget {
  final User user;
  const BatchListPage({super.key, required this.user});

  @override
  State<BatchListPage> createState() => _BatchListPageState();
}

class _BatchListPageState extends State<BatchListPage> {
  late BatchRemoteDataSource _dataSource;
  List<BatchModel> _batches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    _dataSource = BatchRemoteDataSource(dio);
    _fetchBatches();
  }

  Future<void> _fetchBatches() async {
    setState(() => _isLoading = true);
    try {
      final batches = await _dataSource.getBatches();
      setState(() {
        _batches = batches;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeBatch = _batches.firstWhere((b) => b.status == 'active', 
        orElse: () => BatchModel(id: 0, namaBatch: '', status: '', jumlahBungkus: 0, jumlahKedelai: 0, jumlahRagi: 0, createdAt: DateTime.now()));

    final historyBatches = _batches.where((b) => b.status == 'completed').toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchBatches,
          color: AppTheme.primaryGold,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Batch Produksi",
                  style: TextStyle(
                    color: AppTheme.primaryGold,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Search Bar
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Cari ID Batch...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    fillColor: const Color(0xFF1E1E1E),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Active Batch Section
                const Text(
                  "BATCH BERJALAN",
                  style: TextStyle(
                    color: Color(0xFF2ECC71),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppTheme.primaryGold)))
                else if (_error != null)
                  Center(child: Padding(padding: const EdgeInsets.all(20), child: Text("Error: $_error", style: const TextStyle(color: Colors.red))))
                else if (activeBatch.id != 0)
                  _buildActiveBatchCard(activeBatch)
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("Tidak ada batch aktif", style: TextStyle(color: Colors.grey)),
                    ),
                  ),

                const SizedBox(height: 32),

                // Saved Batches Section
                if (!_isLoading && _error == null) ...[
                  const Text(
                    "BATCH TERSIMPAN",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...historyBatches.map((b) => _buildBatchListItem(b)),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    "DRAFT BATCH",
                    style: TextStyle(
                      color: AppTheme.primaryGold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._batches.where((b) => b.status == 'draft').map((b) => _buildBatchListItem(b)),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBatchPage()),
          );
          if (result == true) _fetchBatches();
        },
        backgroundColor: AppTheme.primaryGold,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildActiveBatchCard(BatchModel batch) {
    final duration = DateTime.now().difference(batch.createdAt);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => BatchDetailPage(batch: batch, user: widget.user)));
        if (result == true) _fetchBatches();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("BATCH AKTIF", style: TextStyle(color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(
                      batch.namaBatch,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.circle, color: Colors.green, size: 8),
                      SizedBox(width: 6),
                      Text("LIVE", style: TextStyle(fontSize: 10, color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("UNIT TERPRODUKSI", style: TextStyle(color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "${batch.jumlahBungkus}",
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        const Text("x", style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("DURASI BERJALAN", style: TextStyle(color: Colors.grey, fontSize: 10)),
                    const SizedBox(height: 8),
                    Text(
                      "${days > 0 ? '$days Hari ' : ''}$hours Jam",
                      style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchListItem(BatchModel batch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: batch.status == 'draft' ? AppTheme.primaryGold.withOpacity(0.2) : Colors.white10),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => BatchDetailPage(batch: batch, user: widget.user)));
              if (result == true) _fetchBatches();
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                batch.status == 'draft' ? Icons.edit_note : Icons.inventory_2_outlined,
                color: batch.status == 'draft' ? AppTheme.primaryGold : Colors.grey,
              ),
            ),
            title: Text(
              batch.namaBatch,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              batch.status == 'draft' 
                  ? "BELUM DIMULAI" 
                  : "TERAKHIR DIGUNAKAN ${DateFormat('dd-MM-yyyy').format(batch.endTimestamp ?? batch.createdAt)}",
              style: TextStyle(
                color: batch.status == 'draft' ? AppTheme.primaryGold.withOpacity(0.7) : Colors.grey, 
                fontSize: 10,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
