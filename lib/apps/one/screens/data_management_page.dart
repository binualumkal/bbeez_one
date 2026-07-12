import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bbeez_one/platform/database/database_manager.dart';
import 'package:bbeez_one/platform/core/service_locator.dart';
import 'package:bbeez_one/platform/repositories/domain_repository.dart';
import 'package:bbeez_one/platform/repositories/institution_repository.dart';
import 'package:bbeez_one/platform/repositories/record_repository.dart';
import 'package:bbeez_one/platform/repositories/record_type_repository.dart';
import 'package:bbeez_one/platform/repositories/settings_repository.dart';
import 'package:bbeez_one/platform/security/biometric_service.dart';
import 'package:bbeez_one/platform/backup/backup_service.dart';
import 'package:bbeez_one/platform/services/notification_service.dart';
import 'package:bbeez_one/platform/themes/app_theme.dart';
import 'package:bbeez_one/apps/one/widgets/common_appbar.dart';
import 'package:bbeez_one/platform/security/security_service.dart';

class DataManagementPage extends StatefulWidget {
  const DataManagementPage({super.key});

  @override
  State<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends State<DataManagementPage> {
  static const _lastBackupKey = 'last_backup_date';

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _checkBackupReminder();
  }

  Future<void> _saveNotificationStatus(
    bool value,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'show_notification',
      value,
    );
  }

  Future<void> _checkBackupReminder() async {
    final prefs = await SharedPreferences.getInstance();

    final last = prefs.getString(
      _lastBackupKey,
    );

    if (last == null) return;

    final days = DateTime.now()
        .difference(
          DateTime.parse(
            last,
          ),
        )
        .inDays;

    if (days >= 30) {
      await _saveNotificationStatus(
        true,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            duration: Duration(
              seconds: 5,
            ),
            content: Text(
              '30 days completed. Please create a backup.',
            ),
          ),
        );
      });
    } else {
      await _saveNotificationStatus(
        false,
      );
    }
  }

  Future<void> _backup() async {
    try {
      // 1. Check if biometrics is enabled and authenticate
      final bioEnabled =
          await locate<SettingsRepository>().getBiometricEnabled();
      if (bioEnabled) {
        final authenticated = await BiometricService.authenticate();
        if (!authenticated) {
          _show('Authentication failed');
          return;
        }
      }

      setState(() {
        loading = true;
      });

      final file = await BackupService.backupDatabase();

      if (file == null) {
        _show('Set master password first');
        return;
      }

      await BackupService.shareBackup(
        file,
      );

      await locate<SettingsRepository>().resetBackupTracking();

      await _saveNotificationStatus(
        false,
      );

      _show(
        'Backup created',
      );
    } catch (e) {
      _show(
        'Backup failed',
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<String?> _showPasswordDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF061A44),
        title: const Text('Backup Password',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter password used for backup',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  Future<void> _restore() async {
    try {
      String? password;
      var allowLocalCredentials = false;

      // 1. Try biometric first to use local secure credentials
      final bioEnabled =
          await locate<SettingsRepository>().getBiometricEnabled();
      if (bioEnabled) {
        final authenticated = await BiometricService.authenticate();
        if (authenticated) {
          allowLocalCredentials = true;
        }
      }

      // 2. If biometric failed or local credentials aren't available, ask manually
      if (!allowLocalCredentials) {
        password = await _showPasswordDialog();
        if (password == null || password.isEmpty) return;
      }

      setState(() {
        loading = true;
      });

      final result = await BackupService.restoreDatabase(
        password ?? '',
        allowLocalCredentials: allowLocalCredentials,
      );

      if (result == 1) {
        _show('Restore cancelled');
        return;
      } else if (result == 2) {
        _show('Incorrect password or invalid file');
        return;
      } else if (result != 0) {
        _show('Restore failed');
        return;
      }

      if (password != null && password.isNotEmpty) {
        // 3. After successful restore using manual password, update master password
        await SecurityService.setNewPassword(password);
      }

      await locate<DatabaseManager>().initialize();

      _show(
        'Restore completed. Restart app.',
      );
    } catch (_) {
      _show(
        'Restore failed',
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _deleteAll() async {
    try {
      setState(() {
        loading = true;
      });

      await NotificationService.notifications.cancelAll();
      await locate<DomainRepository>().clear();
      await locate<InstitutionRepository>().clear();
      await locate<RecordTypeRepository>().clear();
      await locate<RecordRepository>().clear();

      _show(
        'All records deleted',
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _show(
    String msg,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          msg,
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      decoration: AppTheme.pageBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: commonAppBar(
          context,
          "Data Management",
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryAccent,
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      "Manage and protect your data",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    Icons.backup,
                    "Backup Data",
                    "Create and share encrypted backup",
                    () {
                      _backup();
                    },
                  ),
                  const SizedBox(height: 14),
                  _card(
                    Icons.restore,
                    "Restore Backup",
                    "Restore .bbz file",
                    () {
                      _restore();
                    },
                  ),
                  const SizedBox(height: 14),
                  _card(
                    Icons.delete_forever,
                    "Delete All Records",
                    "Permanently erase data",
                    () {
                      _confirmDelete();
                    },
                    red: true,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _card(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool red = false,
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
        leading: CircleAvatar(
          backgroundColor: red
              ? Colors.red.withValues(alpha: .2)
              : Colors.white.withValues(alpha: .1),
          child: Icon(
            icon,
            color: red ? Colors.redAccent : Colors.white,
          ),
        ),
        title: Text(
          title,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white54,
        ),
        onTap: onTap,
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF061A44),
        title: const Text(
          'Delete Data',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Delete all records permanently?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
