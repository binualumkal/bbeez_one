import 'dart:io';
import 'package:flutter/material.dart';

import '../screens/profile_page.dart';
import '../screens/change_password_page.dart';
import '../screens/settings_page.dart';
import '../screens/about_page.dart';
import '../screens/login_screen.dart';
import 'package:bbeez_one/platform/services/profile_service.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  String _name = 'BBeez User';
  String _imagePath = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileService.getProfile();
    if (mounted) {
      setState(() {
        _name = profile['name'] ?? 'BBeez User';
        if (_name.isEmpty) _name = 'BBeez User';
        _imagePath = profile['image'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * .78,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Profile Header
            Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white10,
                  backgroundImage:
                      _imagePath.isNotEmpty && File(_imagePath).existsSync()
                          ? FileImage(File(_imagePath))
                          : null,
                  child: _imagePath.isEmpty || !File(_imagePath).existsSync()
                      ? const Icon(Icons.person,
                          size: 45, color: Colors.white24)
                      : null,
                ),
                const SizedBox(height: 14),
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(indent: 20, endIndent: 20),
            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _item(
                    context,
                    Icons.person_outline,
                    'Profile',
                    const ProfilePage(),
                    onReturn: _loadProfile,
                  ),
                  _item(
                    context,
                    Icons.shield_outlined,
                    'Security',
                    const ChangePasswordPage(),
                  ),
                  _item(
                    context,
                    Icons.settings_outlined,
                    'Settings',
                    const SettingsPage(),
                  ),
                  _item(
                    context,
                    Icons.info_outline,
                    'About',
                    const AboutPage(),
                  ),
                ],
              ),
            ),

            const Divider(),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                ),
                leading: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                    (_) => false,
                  );
                },
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            const Text(
              'Designed & Developed\nfor BBeez Digital • © Binu Alumkal',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                height: 1.5,
              ),
            ),

            const SizedBox(
              height: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    Widget page, {
    VoidCallback? onReturn,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            18,
          ),
        ),
        leading: Icon(icon),
        title: Text(title),
        onTap: () {
          Navigator.pop(
            context,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
          ).then((_) {
            if (onReturn != null) onReturn();
          });
        },
      ),
    );
  }
}
