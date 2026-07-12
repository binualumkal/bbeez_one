import 'package:flutter/material.dart';

import '../widgets/common_appbar.dart';
import 'change_password_page.dart';
import 'data_management_page.dart';

import '../services/biometric_service.dart';
import '../services/database_service.dart';
import '../services/app_lock_service.dart';
import '../services/security_service.dart';
import '../theme/app_theme.dart';
import 'dart:io';

import '../pages/profile_page.dart';
import '../services/profile_service.dart';

import 'about_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState
    extends State<SettingsPage> {
  bool biometricEnabled = false;
  bool privacyScreenEnabled = false;
  int autoLockSeconds = 50;


  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {

    final enabled =
    await DatabaseService
        .getBiometricEnabled();

    final privacyEnabled = await DatabaseService.getPrivacyScreenEnabled();

    final lockSeconds =
        AppLockService.instance.timeout.inSeconds;

    if (!mounted) return;

    setState(() {
      biometricEnabled =
          enabled;
      privacyScreenEnabled = privacyEnabled;
      autoLockSeconds = lockSeconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: commonAppBar(
        context,
        "Settings",
      ),

      body: Container(

        decoration:
        AppTheme.pageBackground,

        child: SafeArea(
          child: ListView(
            padding:
            const EdgeInsets.all(18),

            children: [

              /// USER PROFILE
              FutureBuilder(
                future: ProfileService.getProfile(),

                builder: (
                    context,
                    snapshot,
                    ) {

                  final profile =
                      snapshot.data ??
                          {
                            'name':
                            'User Profile',

                            'image':
                            '',
                          };

                  final image =
                  profile['image']!;

                  final name =
                  profile['name']!;

                  return GestureDetector(

                    onTap: () async {

                      await Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder:
                              (_) =>
                          const ProfilePage(),
                        ),
                      );

                      setState(() {});
                    },

                    child: Container(

                      padding:
                      const EdgeInsets.all(
                          18),

                      decoration:
                      BoxDecoration(

                        color:
                        Colors.white
                            .withValues(alpha: .05),

                        borderRadius:
                        BorderRadius
                            .circular(
                            24),

                        border:
                        Border.all(

                          color:
                          Colors.white
                              .withValues(alpha: .08),
                        ),
                      ),

                      child: Row(

                        children: [

                          Container(

                            width: 70,
                            height: 70,

                            decoration:
                            const BoxDecoration(
                              shape:
                              BoxShape.circle,
                            ),

                            child:
                            CircleAvatar(

                              radius:
                              35,

                              backgroundImage:
                              image.isNotEmpty
                                  ? FileImage(
                                File(
                                    image),
                              )
                                  : null,

                              backgroundColor:
                              Colors.white
                                  .withValues(alpha: .08),

                              child:
                              image.isEmpty
                                  ? const Icon(
                                Icons.person,

                                color:
                                Colors
                                    .white,

                                size:
                                34,
                              )
                                  : null,
                            ),
                          ),

                          const SizedBox(
                            width: 18,
                          ),

                          Expanded(

                            child:
                            Column(

                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                              children: [

                                Text(

                                  name.isEmpty
                                      ? "User Profile"
                                      : name,

                                  style:
                                  const TextStyle(

                                    color:
                                    Colors
                                        .white,

                                    fontSize:
                                    22,

                                    fontWeight:
                                    FontWeight
                                        .bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 6,
                                ),

                                const Text(

                                  "Manage account & preferences",

                                  style:
                                  TextStyle(
                                    color:
                                    Colors
                                        .white70,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(

                            Icons
                                .arrow_forward_ios,

                            color:
                            Colors.white70,

                            size:
                            18,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 28,
              ),

              sectionTitle(
                  "SECURITY"),

              _buildSwitchTile(
                icon: Icons.fingerprint,
                title: "Biometric Lock",
                value: biometricEnabled,

                onChanged: (value) async {
                  final messenger = ScaffoldMessenger.of(context);

                  if (value) {

                    final available =
                    await BiometricService
                        .isBiometricAvailable();

                    if (!available) {

                      if (!mounted) return;

                      messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Biometric authentication not available',
                          ),
                        ),
                      );

                      return;
                    }

                    final authenticated =
                    await BiometricService
                        .authenticate();

                    if (!authenticated) {

                      if (!mounted) return;

                      messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Authentication failed',
                          ),
                        ),
                      );

                      return;
                    }
                  }

                  await DatabaseService
                      .setBiometricEnabled(
                      value);

                  if (!mounted) return;

                  setState(() {
                    biometricEnabled =
                        value;
                  });

                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Biometric Enabled'
                            : 'Biometric Disabled',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(
                  height: 12),

              _buildSwitchTile(
                icon: Icons.security_rounded,
                title: "Privacy Screen",
                value: privacyScreenEnabled,
                onChanged: (value) async {
                  final messenger = ScaffoldMessenger.of(context);
                  await DatabaseService.setPrivacyScreenEnabled(value);
                  await SecurityService.setSecure(value);
                  if (!mounted) return;
                  setState(() {
                    privacyScreenEnabled = value;
                  });
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        value ? 'Privacy Screen Enabled' : 'Privacy Screen Disabled',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(
                  height: 12),

              _buildDropdownTile(
                icon: Icons.timer_outlined,
                title: "Auto-Lock Timeout",
                value: autoLockSeconds,
                options: [15, 30, 50, 60, 120, 300, 600],
                onChanged: (value) async {
                  if (value != null) {
                    await AppLockService.instance.updateTimeout(value);
                    setState(() {
                      autoLockSeconds = value;
                    });
                  }
                },
              ),

              const SizedBox(
                  height: 12),

              _buildTile(
                icon:
                Icons.lock_reset,

                title:
                "Change Master Password",

                onTap: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder:
                          (_) =>
                      const ChangePasswordPage(),
                    ),
                  );
                },
              ),

              const SizedBox(
                  height: 30),

              sectionTitle("DATA"),

              _buildTile(
                icon: Icons.storage_rounded,
                title: "Data Management",

                onTap: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) =>
                      const DataManagementPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),


              sectionTitle("ABOUT"),

              _buildTile(
                icon: Icons.info_outline,
                title: "About App",
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white70,
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AboutPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(
      String title) {
    return Padding(
      padding:
      const EdgeInsets.only(
          bottom: 12),

      child: Text(
        title,

        style:
        const TextStyle(
          color:
          Colors.white70,

          fontSize: 13,

          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin:
      const EdgeInsets.only(
          bottom: 12),

      decoration:
      BoxDecoration(
        color:
        Colors.white
            .withValues(alpha: .05),

        borderRadius:
        BorderRadius.circular(
            20),

        border:
        Border.all(
          color: Colors
              .white
              .withValues(alpha: .08),
        ),
      ),

      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
        ),

        title: Text(
          title,

          style:
          const TextStyle(
            color:
            Colors.white,
          ),
        ),

        trailing:
        trailing ??
            const Icon(
              Icons
                  .arrow_forward_ios,

              color:
              Colors.white70,

              size: 16,
            ),

        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool>
    onChanged,
  }) {
    return Container(
      margin:
      const EdgeInsets.only(
          bottom: 12),

      decoration:
      BoxDecoration(
        color:
        Colors.white
            .withValues(alpha: .05),

        borderRadius:
        BorderRadius.circular(
            20),

        border:
        Border.all(
          color: Colors
              .white
              .withValues(alpha: .08),
        ),
      ),

      child:
      SwitchListTile(
        value: value,

        onChanged:
        onChanged,

        secondary:
        Icon(
          icon,
          color:
          Colors.white,
        ),

        title:
        Text(
          title,

          style:
          const TextStyle(
            color:
            Colors.white,
          ),
        ),

        activeThumbColor:
        const Color(
            0xFF14F1FF),
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required int value,
    required List<int> options,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: .08),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: options.contains(value) ? value : options.first,
            dropdownColor: AppTheme.bgBottom,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white70,
            ),
            items: options.map((int val) {
              String label = val < 60 ? "$val sec" : "${val ~/ 60} min";
              return DropdownMenuItem<int>(
                value: val,
                child: Text(label),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}