import 'package:bbeez_one/apps/one/screens/notes_page.dart';
import 'package:bbeez_one/apps/one/screens/support_page.dart';
import 'package:bbeez_one/platform/services/version_service.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'settings_page.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int currentIndex;

  late final List<Widget?> pages;

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;

    pages = [
      const HomeScreen(),
      null,
      null,
      null,
    ];

    // Check for updates after the user has entered the app
    // Delayed by 5 seconds so it doesn't happen immediately at login/start
    Future.delayed(const Duration(seconds: 5), () {
      VersionService.checkForUpdates();
    });
  }

  void loadPage(int index) {
    if (pages[index] != null) {
      return;
    }

    setState(() {
      switch (index) {
        case 1:
          pages[1] = const NotesPage();
          break;

        case 2:
          pages[2] = const SupportPage();
          break;

        case 3:
          pages[3] = const SettingsPage();
          break;
      }
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: currentIndex,
        children: pages
            .map(
              (p) => p ?? const SizedBox(),
            )
            .toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          loadPage(index);

          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
            ),
            activeIcon: Icon(
              Icons.home,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.note_alt_outlined,
            ),
            activeIcon: Icon(
              Icons.note_alt,
            ),
            label: "Notes",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.support_agent_outlined,
            ),
            activeIcon: Icon(
              Icons.support_agent,
            ),
            label: "Support",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_outlined,
            ),
            activeIcon: Icon(
              Icons.settings,
            ),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
