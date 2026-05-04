import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user.dart';
import 'monitoring_page.dart';
import 'batch_list_page.dart';
import '../../../home/presentation/pages/device_page.dart';
import '../../../home/presentation/pages/profile_page.dart';
import '../../../auth/presentation/pages/login_page.dart';

class MainPage extends StatefulWidget {
  final User user;
  const MainPage({super.key, required this.user});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MonitoringPage(user: widget.user),
      const BatchListPage(),
      const DevicePage(),
      ProfilePage(
        user: widget.user,
        onLogout: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: AppTheme.primaryGold,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "MONITORING"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: "BATCH"),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: "PERANGKAT"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "PROFIL"),
        ],
      ),
    );
  }
}
