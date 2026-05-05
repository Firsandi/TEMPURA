import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tempura/core/constants/api_constants.dart';
import 'package:tempura/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:tempura/features/dashboard/data/models/dashboard_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/device_entity.dart';
import '../widgets/device_card.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  late DashboardRemoteDataSource _dataSource;
  DashboardDataModel? _data;
  Timer? _timer;
  String _mode = 'manual'; // manual, auto
  bool _isUpdatingMode = false;
  
  // Map untuk menyimpan status toggle lokal sementara agar UI lebih responsif
  final Map<String, bool> _localToggles = {};
  final Map<String, Timer> _toggleTimers = {};

  @override
  void initState() {
    super.initState();
    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    _dataSource = DashboardRemoteDataSource(dio);
    _fetchInitialData();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchData());
  }

  Future<void> _fetchInitialData() async {
    await _fetchData();
    await _fetchSettings();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var timer in _toggleTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _fetchData() async {
    try {
      final newData = await _dataSource.getLatestDashboardData();
      if (mounted) {
        setState(() {
          _data = newData;
        });
      }
    } catch (e) {
      debugPrint('Error fetching device data: $e');
    }
  }

  Future<void> _fetchSettings() async {
    try {
      final settings = await _dataSource.getSettings();
      if (mounted) {
        setState(() {
          _mode = settings['mode'] ?? 'manual';
        });
      }
    } catch (e) {
      debugPrint('Error fetching settings: $e');
    }
  }

  Future<void> _toggleMode(bool val) async {
    if (_isUpdatingMode) return;
    final newMode = val ? 'auto' : 'manual';
    
    setState(() => _isUpdatingMode = true);
    try {
      await _dataSource.updateSettings({'mode': newMode});
      setState(() => _mode = newMode);
      _showSuccess('Mode sistem diubah ke ${newMode.toUpperCase()}');
    } catch (e) {
      _showError('Gagal mengubah mode: $e');
    } finally {
      if (mounted) setState(() => _isUpdatingMode = false);
    }
  }

  Future<void> _toggleDevice(String deviceType, bool val) async {
    if (_mode == 'auto') {
      _showError('Nonaktifkan Mode Otomatis untuk kontrol manual!');
      return;
    }

    setState(() => _localToggles[deviceType] = val);
    _toggleTimers[deviceType]?.cancel();

    final action = val ? 'on' : 'off';
    try {
      await _dataSource.controlDevice(deviceType, action);
      _showSuccess('${deviceType.toUpperCase()} berhasil diubah ke $action');
      
      _toggleTimers[deviceType] = Timer(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() => _localToggles.remove(deviceType));
        }
      });
      _fetchData(); 
    } catch (e) {
      setState(() => _localToggles.remove(deviceType));
      _showError('Gagal mengirim perintah: $e');
    }
  }

  bool _isOnline() {
    if (_data?.latestSensor == null) return false;
    final now = DateTime.now();
    return now.difference(_data!.latestSensor!.timestamp).inSeconds < 30;
  }

  List<DeviceEntity> _getDevices() {
    final sensor = _data?.latestSensor;
    final bool online = _isOnline();
    
    DeviceStatus getActuatorStatus(String actuatorHealth) {
      if (!online) return DeviceStatus.inactive;
      if (actuatorHealth != "OK" && actuatorHealth != "") return DeviceStatus.error;
      return DeviceStatus.active;
    }

    return [
      DeviceEntity(
        id: '0', 
        name: 'ESP32 Controller', 
        status: online ? DeviceStatus.active : DeviceStatus.inactive, 
        type: 'esp32', 
        isOn: online
      ),
      DeviceEntity(
        id: '1', 
        name: 'Kipas Utama', 
        status: getActuatorStatus(sensor?.health.contains("FAN") == true ? "FAULT" : "OK"), 
        type: 'fan', 
        isOn: _localToggles.containsKey('fan') ? _localToggles['fan']! : (sensor?.relayFan ?? false)
      ),
      DeviceEntity(
        id: '2', 
        name: 'Pompa Mist', 
        status: getActuatorStatus(sensor?.health.contains("PUMP") == true ? "FAULT" : "OK"), 
        type: 'mist', 
        isOn: _localToggles.containsKey('mist') ? _localToggles['mist']! : (sensor?.relayPump ?? false)
      ),
      DeviceEntity(
        id: '3', 
        name: 'Bohlam UV', 
        status: online ? DeviceStatus.active : DeviceStatus.inactive, 
        type: 'bulb', 
        isOn: _localToggles.containsKey('bulb') ? _localToggles['bulb']! : false
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool online = _isOnline();
    final devices = _getDevices();
    final double soilVal = (_data?.latestSensor?.soil ?? 4095).toDouble();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _fetchData();
            await _fetchSettings();
          },
          color: AppTheme.primaryGold,
          backgroundColor: const Color(0xFF1A1A1A),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // Header Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "Kontrol\nPerangkat",
                            style: TextStyle(
                              color: AppTheme.primaryGold,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          _buildMiniStatus(online),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Mode Switch Container
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mode: ${_mode.toUpperCase()}",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _mode == 'auto' ? "Otomatis oleh sistem" : "Kontrol Manual Aktif",
                              style: TextStyle(color: _mode == 'auto' ? AppTheme.primaryGold : Colors.white38, fontSize: 11),
                            ),
                          ],
                        ),
                        Switch(
                          value: _mode == 'auto',
                          onChanged: _isUpdatingMode ? null : _toggleMode,
                          activeColor: AppTheme.primaryGold,
                          activeTrackColor: AppTheme.primaryGold.withOpacity(0.2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Moisture Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildMoistureDashboard(soilVal, online),
                ),
              ),

              // Grid Section Header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    "STATUS PERANGKAT",
                    style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                ),
              ),

              // Device Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return DeviceCard(
                        device: devices[index],
                        onToggle: (val) => _toggleDevice(devices[index].type, val),
                      );
                    },
                    childCount: devices.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStatus(bool online) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: online ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        online ? "CONNECTED" : "DISCONNECTED",
        style: TextStyle(color: online ? Colors.green : Colors.red, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMoistureDashboard(double val, bool online) {
    double percentage = 100 - ((val / 4095) * 100);
    percentage = percentage.clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: online 
              ? [AppTheme.primaryGold, const Color(0xFFB8860B)]
              : [Colors.grey.shade800, Colors.grey.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: online ? AppTheme.primaryGold.withOpacity(0.3) : Colors.black26,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kelembaban Tempe",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      online ? percentage.toStringAsFixed(0) : "--",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      " %",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (!online)
                  const Text(
                    "SENSOR DISCONNECTED",
                    style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          Container(
            height: 70,
            width: 70,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              value: online ? (percentage / 100) : 0,
              strokeWidth: 6,
              backgroundColor: Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
