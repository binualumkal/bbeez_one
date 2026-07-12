import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/record_model.dart';
import '../models/secret_field_model.dart';
import 'database_service.dart';
import 'encryption_service.dart';
import 'notification_service.dart';

class BackupService {

  /// BACKUP DATABASE (.bbz)
  /// Exports all Hive boxes as JSON

  static Future<File?> backupDatabase() async {
    final password = await DatabaseService.getPassword();
    if (password.isEmpty) {
      return null;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/backups');

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-');

    final backupFile = File(
      '${backupDir.path}/bbeez_backup_$timestamp.bbz',
    );

    try {
      // Export all data as JSON
      final domains = DatabaseService.domainBox.values
          .map((d) => {'name': d.name})
          .toList();

      final institutions = DatabaseService.institutionBox.values
          .map((i) => {'name': i.name, 'domainName': i.domainName})
          .toList();

      final recordTypes = DatabaseService.recordTypeBox.values
          .map((rt) => {
                'name': rt.name,
                'institutionName': rt.institutionName,
                'domainName': rt.domainName
              })
          .toList();

      final records = DatabaseService.recordBox.values
          .map((r) => {
                'domainName': r.domainName,
                'institutionName': r.institutionName,
                'recordTypeName': r.recordTypeName,
                'fields': r.fields
                    .map((f) => {
                          'label': f.label,
                          'value': f.value,
                          'value2': f.value2,
                          'isHidden': f.isHidden,
                        })
                    .toList(),
                'searchText': r.searchText,
                'isFavorite': r.isFavorite,
                'expiryDate': r.expiryDate?.toIso8601String(),
              })
          .toList();

      final backupData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'domains': domains,
        'institutions': institutions,
        'recordTypes': recordTypes,
        'records': records,
      };

      final jsonString = jsonEncode(backupData);
      final bytes = utf8.encode(jsonString);
      final encryptedBytes = EncryptionService.encryptBytes(bytes, password);

      return await backupFile.writeAsBytes(encryptedBytes);
    } catch (e) {
      return null;
    }
  }

  /// SHARE BACKUP

  static Future<void> shareBackup(File file) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'BBeez Backup',
      ),
    );
  }

  /// RESTORE DATABASE

  static Future<int> restoreDatabase(String password) async {
    // Returns: 0 = Success, 1 = File not picked, 2 = Decryption failed, 3 = Error

    final result = await FilePicker.pickFiles(
      type: Platform.isIOS ? FileType.any : FileType.custom,
      allowedExtensions: Platform.isIOS ? null : ['bbz'],
    );

    if (result == null) {
      return 1;
    }

    final selectedFile = File(result.files.single.path!);

    try {
      final encryptedBytes = await selectedFile.readAsBytes();
      final decryptedBytes =
          EncryptionService.decryptBytes(encryptedBytes, password);

      if (decryptedBytes == null) {
        return 2; // Wrong password or corrupted file
      }

      final jsonString = utf8.decode(decryptedBytes);
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Clear existing data (and cancel all notifications)
      await DatabaseService.clearDatabase();

      // Restore domains
      for (final domain in backupData['domains'] ?? []) {
        await DatabaseService.addDomain(domain['name'] as String);
      }

      // Restore institutions
      for (final inst in backupData['institutions'] ?? []) {
        await DatabaseService.addInstitution(
          name: inst['name'] as String,
          domainName: inst['domainName'] as String,
        );
      }

      // Restore record types
      for (final rt in backupData['recordTypes'] ?? []) {
        await DatabaseService.addRecordType(
          name: rt['name'] as String,
          institutionName: rt['institutionName'] as String,
          domainName: rt['domainName'] as String,
        );
      }

      // Restore records
      for (final recordData in backupData['records'] ?? []) {
        final fieldsData = recordData['fields'] ?? [];
        final fields = (fieldsData as List).map((f) {
          final field = SecretField()
            ..label = f['label'] as String
            ..value = f['value'] as String?
            ..value2 = f['value2'] as String?
            ..isHidden = f['isHidden'] as bool? ?? true;
          return field;
        }).toList();

        final record = RecordModel()
          ..domainName = recordData['domainName'] as String
          ..institutionName = recordData['institutionName'] as String
          ..recordTypeName = recordData['recordTypeName'] as String
          ..fields = fields
          ..searchText = recordData['searchText'] as String
          ..isFavorite = recordData['isFavorite'] as bool? ?? false
          ..expiryDate = recordData['expiryDate'] != null 
              ? DateTime.parse(recordData['expiryDate'] as String)
              : null;

        await DatabaseService.recordBox.add(record);

        // Re-schedule notification if expiry date is set
        if (record.expiryDate != null && record.key != null) {
          try {
            await NotificationService.scheduleRecordExpiry(
              record.key as int,
              record.institutionName,
              record.expiryDate!,
            );
          } catch (e) {
            debugPrint("Failed to re-schedule notification: $e");
          }
        }
      }

      return 0;
    } catch (e) {
      return 3;
    }
  }
}

