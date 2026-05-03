class DashboardDataModel {
  final BatchModel? batch;
  final SensorDataModel? latestSensor;
  final String fermentationStatus;
  final List<SensorDataModel> sensorHistory;
  final List<ProductionHistoryModel> productionRuns;
  final Map<String, dynamic> stats;

  DashboardDataModel({
    this.batch,
    this.latestSensor,
    this.fermentationStatus = 'Fase Awal',
    this.sensorHistory = const [],
    this.productionRuns = const [],
    this.stats = const {},
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      batch: json['batch'] != null ? BatchModel.fromJson(json['batch']) : null,
      latestSensor: json['latest_sensor'] != null ? SensorDataModel.fromJson(json['latest_sensor']) : null,
      fermentationStatus: json['fermentation_status'] ?? 'Fase Awal',
      sensorHistory: (json['sensor_history'] as List?)
          ?.map((e) => SensorDataModel.fromJson(e))
          .toList() ?? [],
      productionRuns: (json['production_runs'] as List?)
          ?.map((e) => ProductionHistoryModel.fromJson(e))
          .toList() ?? [],
      stats: json['stats'] ?? {},
    );
  }
}

class ProductionHistoryModel {
  final int id;
  final int batchId;
  final int runNumber;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;

  ProductionHistoryModel({
    required this.id,
    required this.batchId,
    required this.runNumber,
    required this.startTime,
    this.endTime,
    required this.status,
  });

  factory ProductionHistoryModel.fromJson(Map<String, dynamic> json) {
    return ProductionHistoryModel(
      id: json['history_id'],
      batchId: json['batch_id'],
      runNumber: json['run_number'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      status: json['status'],
    );
  }
}

class BatchModel {
  final int id;
  final String namaBatch;
  final String status;
  final int jumlahBungkus;
  final double jumlahKedelai;
  final int jumlahRagi;
  final DateTime createdAt;
  final DateTime? endTimestamp;

  BatchModel({
    required this.id,
    required this.namaBatch,
    required this.status,
    required this.jumlahBungkus,
    required this.jumlahKedelai,
    required this.jumlahRagi,
    required this.createdAt,
    this.endTimestamp,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: json['batch_id'],
      namaBatch: json['nama_batch'] ?? '',
      status: json['status_batch'],
      jumlahBungkus: json['jumlah_bungkus'] ?? 0,
      jumlahKedelai: (json['jumlah_kedelai'] as num?)?.toDouble() ?? 0.0,
      jumlahRagi: json['jumlah_ragi'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      endTimestamp: json['end_timestamp'] != null ? DateTime.parse(json['end_timestamp']) : null,
    );
  }
}

class SensorDataModel {
  final double temp;
  final double hum;
  final int soil;
  final DateTime timestamp;

  SensorDataModel({required this.temp, required this.hum, required this.soil, required this.timestamp});

  factory SensorDataModel.fromJson(Map<String, dynamic> json) {
    return SensorDataModel(
      temp: (json['suhu'] as num).toDouble(),
      hum: (json['kelembaban'] as num).toDouble(),
      soil: json['soil_moisture'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class DeviceStatusModel {
  final int id;
  final String name;
  final bool status;

  DeviceStatusModel({required this.id, required this.name, required this.status});

  factory DeviceStatusModel.fromJson(Map<String, dynamic> json) {
    return DeviceStatusModel(
      id: json['device_id'],
      name: json['device_name'],
      status: json['status'],
    );
  }
}
