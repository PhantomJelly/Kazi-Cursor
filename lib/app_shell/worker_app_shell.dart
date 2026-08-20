import 'package:flutter/material.dart';
import 'package:kazi/core_workflow/services/inquiry_store.dart';
import 'package:kazi/home_dashboard/screens/worker_jobs_screen.dart';
import 'package:kazi/profile/screens/worker_profile_screen.dart';
import 'package:kazi/settings/screens/settings_screen.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
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
          onTap: (index) {
            setState(() => _currentIndex = index);
            if (index == 0) {
              InquiryStore.instance.refresh();
            }
          },
          backgroundColor: KaziColors.white,
          selectedItemColor: KaziColors.primary,
          unselectedItemColor: KaziColors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.work_outline),
              activeIcon: const Icon(Icons.work),
              label: t(context, 'nav.jobs'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: t(context, 'nav.profile'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: t(context, 'nav.settings'),
            ),
          ],
        ),
      ),
    );
  }
}
