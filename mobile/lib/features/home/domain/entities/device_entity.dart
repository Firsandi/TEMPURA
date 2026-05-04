enum DeviceStatus { active, inactive, error }

class DeviceEntity {
  final String id;
  final String name;
  final DeviceStatus status;
  final String type; // fan, mist, bulb
  final bool isOn;

  DeviceEntity({
    required this.id,
    required this.name,
    required this.status,
    required this.type,
    required this.isOn,
  });

  DeviceEntity copyWith({
    String? id,
    String? name,
    DeviceStatus? status,
    String? type,
    bool? isOn,
  }) {
    return DeviceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      type: type ?? this.type,
      isOn: isOn ?? this.isOn,
    );
  }
}
