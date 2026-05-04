import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tempura/core/constants/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/dashboard_model.dart';
import '../widgets/sensor_card.dart';
import '../widgets/monitoring_chart.dart';

class MonitoringPage extends StatefulWidget {
  final User user;
  const MonitoringPage({super.key, required this.user});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  late DashboardRemoteDataSource _dataSource;
  DashboardDataModel? _data;
  Timer? _timer;
  String? _error;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    _dataSource = DashboardRemoteDataSource(dio);
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final newData = await _dataSource.getLatestDashboardData();
      if (mounted) {
        setState(() {
          _data = newData;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  bool _isSensorOnline(DateTime? timestamp) {
    if (timestamp == null) return false;
    final now = DateTime.now();
    // Data is considered offline if older than 24 hours (bypass timezone issues for now)
    return now.difference(timestamp).inHours < 24;
  }

  @override
  Widget build(BuildContext context) {
    final bool sensorOnline = _isSensorOnline(_data?.latestSensor?.timestamp);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.analytics_outlined, color: AppTheme.primaryGold),
            const SizedBox(width: 8),
            const Text(
              "TEMPURA",
              style: TextStyle(
                color: AppTheme.primaryGold,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: const NetworkImage("https://ui-avatars.com/api/?name=User&background=random"),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          color: AppTheme.primaryGold,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text("Gagal mengambil data: $_error", style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),

                // System Condition Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: sensorOnline ? const Color(0xFF1B2E26) : const Color(0xFF2E1B1B), // Dark green or dark red
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: (sensorOnline ? Colors.green : Colors.red).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: sensorOnline ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        sensorOnline ? "KONDISI SISTEM: NORMAL" : "PERHATIAN: SENSOR TIDAK TERDETEKSI",
                        style: TextStyle(
                          color: sensorOnline ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Batch & Condition Info Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        "ID BATCH",
                        _data?.batch != null ? (_data?.batch?.namaBatch ?? "---") : "Tidak Ada Batch",
                        Icons.qr_code_scanner,
                        _data?.batch != null ? "TOTAL ${_data?.batch?.jumlahBungkus}X" : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        "KONDISI",
                        _data?.batch != null ? (_data?.fermentationStatus ?? "Proses\nFermentasi") : "Tidak Ada Batch",
                        Icons.settings_input_component,
                        null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // LIVE indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: sensorOnline ? Colors.green : Colors.grey, size: 8),
                          const SizedBox(width: 6),
                          Text(
                            sensorOnline ? "LIVE" : "OFFLINE",
                            style: const TextStyle(fontSize: 10, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Sensor Cards
                SensorCard(
                  title: "SUHU",
                  value: _data?.latestSensor?.temp.toStringAsFixed(0) ?? "--",
                  unit: "°C",
                  icon: Icons.thermostat_outlined,
                  statusText: "+2° ke target suhu",
                  accentColor: AppTheme.accentRed,
                  isOnline: sensorOnline,
                ),
                const SizedBox(height: 16),
                SensorCard(
                  title: "KELEMBABAN",
                  value: _data?.latestSensor?.hum.toStringAsFixed(0) ?? "--",
                  unit: "%",
                  icon: Icons.water_drop_outlined,
                  statusText: "Optimal",
                  accentColor: AppTheme.accentGreen,
                  isOnline: sensorOnline,
                ),
                const SizedBox(height: 24),

                // Statistic Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.show_chart, color: AppTheme.primaryGold, size: 24),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Statistik",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "Suhu dan Kelembaban",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sensorOnline 
                            ? "Avg Temp: ${(_data?.stats['avg_temp'] ?? 0).toStringAsFixed(1)}°C | Avg Hum: ${(_data?.stats['avg_hum'] ?? 0).toStringAsFixed(1)}%"
                            : "Data statistik tidak tersedia secara real-time",
                          style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MonitoringChart(history: _data?.sensorHistory ?? []),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, String? subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textGrey, fontSize: 10)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.textGrey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 10)),
          ],
        ],
      ),
    );
  }
}
