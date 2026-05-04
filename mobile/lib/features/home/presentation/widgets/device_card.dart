import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/device_entity.dart';
import 'dart:math' as math;

class DeviceCard extends StatefulWidget {
  final DeviceEntity device;
  final Function(bool) onToggle;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onToggle,
  });

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.device.isOn) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(DeviceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.device.isOn != oldWidget.device.isOn) {
      if (widget.device.isOn) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData icon;

    switch (widget.device.status) {
      case DeviceStatus.active:
        statusColor = Colors.green;
        statusText = widget.device.isOn ? "BERJALAN" : "SIAGA";
        break;
      case DeviceStatus.error:
        statusColor = AppTheme.accentRed;
        statusText = "TIDAK TERDETEKSI";
        break;
      case DeviceStatus.inactive:
      default:
        statusColor = Colors.grey;
        statusText = "OFFLINE";
        break;
    }

    switch (widget.device.type) {
      case 'fan':
        icon = Icons.cyclone;
        break;
      case 'mist':
        icon = Icons.water_drop;
        break;
      case 'bulb':
        icon = Icons.lightbulb;
        break;
      case 'esp32':
        icon = Icons.developer_board;
        break;
      default:
        icon = Icons.device_hub;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.device.isOn ? AppTheme.primaryGold.withOpacity(0.6) : Colors.white10,
          width: 1.5,
        ),
        boxShadow: widget.device.isOn
            ? [
                BoxShadow(
                  color: AppTheme.primaryGold.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAnimatedIcon(icon),
              if (widget.device.type != 'esp32')
                Switch(
                  value: widget.device.isOn,
                  onChanged: widget.device.status == DeviceStatus.error ? null : widget.onToggle,
                  activeColor: AppTheme.primaryGold,
                  activeTrackColor: AppTheme.primaryGold.withOpacity(0.3),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.white10,
                ),
            ],
          ),
          const Spacer(),
          Text(
            widget.device.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildPulseIndicator(statusColor),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget iconWidget = Icon(
          icon,
          color: widget.device.isOn ? AppTheme.primaryGold : Colors.white38,
          size: 26,
        );

        if (!widget.device.isOn) return _buildIconWrapper(iconWidget);

        // Animations based on type
        switch (widget.device.type) {
          case 'fan':
            return _buildIconWrapper(Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: iconWidget,
            ));
          case 'mist':
            return _buildIconWrapper(Transform.scale(
              scale: 1.0 + (math.sin(_controller.value * 2 * math.pi) * 0.15),
              child: iconWidget,
            ));
          case 'bulb':
            return _buildIconWrapper(Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGold.withOpacity(0.3 + (math.sin(_controller.value * 2 * math.pi) * 0.2)),
                    blurRadius: 15,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: iconWidget,
            ));
          case 'esp32':
             return _buildIconWrapper(Transform.scale(
              scale: 1.0 + (math.sin(_controller.value * 2 * math.pi) * 0.05),
              child: Icon(icon, color: widget.device.status == DeviceStatus.active ? Colors.green : Colors.grey, size: 26),
            ));
          default:
            return _buildIconWrapper(iconWidget);
        }
      },
    );
  }

  Widget _buildIconWrapper(Widget child) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: widget.device.isOn 
            ? AppTheme.primaryGold.withOpacity(0.15) 
            : Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }

  Widget _buildPulseIndicator(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
