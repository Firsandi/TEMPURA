import 'package:dio/dio.dart';
import '../models/dashboard_model.dart';

class BatchRemoteDataSource {
  final Dio dio;

  BatchRemoteDataSource(this.dio);

  Future<List<BatchModel>> getBatches() async {
    try {
      final response = await dio.get('/batch');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return (response.data['data'] as List)
            .map((e) => BatchModel.fromJson(e))
            .toList();
      }
      throw response.data['message'] ?? 'Gagal mengambil daftar batch';
    } catch (e) {
      throw 'Kesalahan koneksi: $e';
    }
  }

  Future<void> createBatch({
    required String namaBatch,
    required int jumlahBungkus,
    required double jumlahKedelai,
    required int jumlahRagi,
  }) async {
    try {
      await dio.post('/batch', data: {
        'nama_batch': namaBatch,
        'jumlah_bungkus': jumlahBungkus,
        'jumlah_kedelai': jumlahKedelai,
        'jumlah_ragi': jumlahRagi,
        'created_by': 1, // Default for now
      });
    } catch (e) {
      throw 'Gagal membuat batch: $e';
    }
  }

  Future<void> stopBatch(int batchId, String userId) async {
    try {
      await dio.put('/batch/$batchId/stop?user_id=$userId');
    } catch (e) {
      throw 'Gagal menghentikan batch: $e';
    }
  }

  Future<void> startBatch(int batchId, String userId) async {
    try {
      await dio.put('/batch/$batchId/start?user_id=$userId');
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Gagal menjalankan batch';
    } catch (e) {
      throw 'Gagal menjalankan batch: $e';
    }
  }

  Future<void> updateBatch({
    required int batchId,
    required String namaBatch,
    required int jumlahBungkus,
    required double jumlahKedelai,
    required int jumlahRagi,
  }) async {
    try {
      await dio.put('/batch/$batchId', data: {
        'nama_batch': namaBatch,
        'jumlah_bungkus': jumlahBungkus,
        'jumlah_kedelai': jumlahKedelai,
        'jumlah_ragi': jumlahRagi,
      });
    } catch (e) {
      throw 'Gagal memperbarui batch: $e';
    }
  }

  Future<void> deleteBatch(int batchId) async {
    try {
      await dio.delete('/batch/$batchId');
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Gagal menghapus batch';
    } catch (e) {
      throw 'Gagal menghapus batch: $e';
    }
  }
  Future<Map<String, dynamic>> getBatchDetail(int batchId) async {
    try {
      final response = await dio.get('/batch/$batchId');
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final data = response.data['data'];
        return {
          'batch': BatchModel.fromJson(data['batch']),
          'production_runs': (data['production_runs'] as List)
              .map((e) => ProductionHistoryModel.fromJson(e))
              .toList(),
        };
      }
      throw response.data['message'] ?? 'Gagal mengambil detail batch';
    } catch (e) {
      throw 'Kesalahan koneksi: $e';
    }
  }
}
