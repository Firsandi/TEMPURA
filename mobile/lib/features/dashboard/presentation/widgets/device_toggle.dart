import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DeviceToggle extends StatelessWidget {
  final String name;
  final bool status;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  const DeviceToggle({
    super.key,
    required this.name,
    required this.status,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status ? AppTheme.primaryGold.withOpacity(0.3) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: status ? AppTheme.primaryGold.withOpacity(0.1) : Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: status ? AppTheme.primaryGold : AppTheme.textGrey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: status ? AppTheme.textLight : AppTheme.textGrey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: status,
            onChanged: onChanged,
            activeColor: AppTheme.primaryGold,
            activeTrackColor: AppTheme.primaryGold.withOpacity(0.3),
            inactiveThumbColor: AppTheme.textGrey,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }
}
