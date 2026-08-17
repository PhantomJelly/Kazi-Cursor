import 'package:flutter/material.dart';
import 'package:kazi/home_dashboard/screens/worker_jobs_screen.dart';
import 'package:kazi/profile/screens/worker_profile_screen.dart';
import 'package:kazi/settings/screens/settings_screen.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';

class WorkerAppShell extends StatefulWidget {
  const WorkerAppShell({super.key});

  @override
  State<WorkerAppShell> createState() => _WorkerAppShellState();
}

class _WorkerAppShellState extends State<WorkerAppShell> {
  int _currentIndex = 1;

  static const _screens = [
    WorkerJobsScreen(),
    WorkerProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KaziColors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: KaziColors.grey15, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: KaziColors.white,
          selectedItemColor: KaziColors.primary,
          unselectedItemColor: KaziColors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              activeIcon: Icon(Icons.work),
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
