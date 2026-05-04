import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  Future<void> controlDevice(String device, String action) async {
    try {
      await dio.post('/dashboard/control', data: {
        'device': device,
        'action': action,
      });
    } catch (e) {
      throw 'Gagal mengontrol perangkat: $e';
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await dio.get('/dashboard/settings');
      return response.data['data'];
    } catch (e) {
      throw 'Gagal mengambil pengaturan: $e';
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      await dio.put('/dashboard/settings', data: settings);
    } catch (e) {
      throw 'Gagal memperbarui pengaturan: $e';
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      debugPrint('Supabase Change Password Error: $e');
      throw 'Gagal: ${e.toString().replaceAll('AuthException: ', '')}';
    }
  }
}
