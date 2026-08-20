import 'package:flutter/material.dart';
import 'package:kazi/home_dashboard/screens/customer_search_screen.dart';
import 'package:kazi/home_dashboard/services/worker_directory_store.dart';
import 'package:kazi/profile/screens/customer_profile_screen.dart';
import 'package:kazi/settings/screens/settings_screen.dart';
import 'package:kazi/l10n/kazi_l10n.dart';
import 'package:kazi/shared/theme/kazi_colors.dart';

class CustomerAppShell extends StatefulWidget {
  const CustomerAppShell({super.key});

  @override
  State<CustomerAppShell> createState() => _CustomerAppShellState();
}

class _CustomerAppShellState extends State<CustomerAppShell> {
  int _currentIndex = 0;

  static const _screens = [
    CustomerSearchScreen(),
    CustomerProfileScreen(),
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
              WorkerDirectoryStore.instance.refresh();
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
              icon: const Icon(Icons.search_outlined),
              activeIcon: const Icon(Icons.search),
              label: t(context, 'nav.search'),
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
