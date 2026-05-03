import 'package:dio/dio.dart';
import '../models/dashboard_model.dart';

class DashboardRemoteDataSource {
  final Dio dio;

  DashboardRemoteDataSource(this.dio);

  Future<DashboardDataModel> getLatestDashboardData() async {
    try {
      final response = await dio.get('/dashboard/latest');
      if (response.statusCode == 200) {
        if (response.data['status'] == 'success') {
          return DashboardDataModel.fromJson(response.data['data']);
        } else if (response.data['status'] == 'no_active_batch') {
          return DashboardDataModel.fromJson(response.data['data']);
        }
        throw response.data['message'] ?? 'Gagal mengambil data dashboard';
      }
      throw 'Server error: ${response.statusCode}';
    } catch (e) {
      throw 'Kesalahan koneksi: $e';
    }
  }

  Future<void> controlDevice(int deviceId, String action) async {
    try {
      await dio.post('/dashboard/control', data: {
        'device_id': deviceId,
        'action': action,
      });
    } catch (e) {
      throw 'Gagal mengontrol perangkat: $e';
    }
  }
}
