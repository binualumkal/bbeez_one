import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:bbeez_one/platform/core/service_locator.dart';
import 'package:bbeez_one/platform/repositories/domain_repository.dart';
import 'package:bbeez_one/platform/repositories/institution_repository.dart';
import 'package:bbeez_one/platform/repositories/record_repository.dart';
import 'package:bbeez_one/platform/repositories/record_type_repository.dart';
import 'package:bbeez_one/platform/models/record_model.dart';
import 'package:bbeez_one/platform/models/secret_field_model.dart';
import 'package:bbeez_one/platform/services/notification_service.dart';
import 'package:bbeez_one/platform/security/security_service.dart';

class BackupService {
  /// BACKUP DATABASE (.bbz)
  /// Exports all Hive boxes as JSON

  static Future<File?> backupDatabase() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/backups');

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');

    final backupFile = File(
      '${backupDir.path}/bbeez_backup_$timestamp.bbz',
    );

    try {
      final domainRepository = locate<DomainRepository>();
      final institutionRepository = locate<InstitutionRepository>();
      final recordTypeRepository = locate<RecordTypeRepository>();
      final recordRepository = locate<RecordRepository>();

      // Export all data as JSON
      final domains = (await domainRepository.getAll())
          .map((d) => {'name': d.name})
          .toList();

      final institutions = (await institutionRepository.getAll())
          .map((i) => {'name': i.name, 'domainName': i.domainName})
          .toList();

      final recordTypes = (await recordTypeRepository.getAll())
          .map((rt) => {
                'name': rt.name,
                'institutionName': rt.institutionName,
                'domainName': rt.domainName
              })
          .toList();

      final records = (await recordRepository.getAll())
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
        'version': 2,
        'timestamp': DateTime.now().toIso8601String(),
        'domains': domains,
        'institutions': institutions,
        'recordTypes': recordTypes,
        'records': records,
      };

      final jsonString = jsonEncode(backupData);
      final bytes = utf8.encode(jsonString);
      final encryptedBytes = await SecurityService.encryptBackupBytes(
        Uint8List.fromList(bytes),
      );
      if (encryptedBytes == null) return null;

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

  static Future<int> restoreDatabase(
    String password, {
    bool allowLocalCredentials = false,
  }) async {
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
      final decryptedBytes = await SecurityService.decryptBackupBytes(
        encryptedBytes,
        password: password,
        allowLocalCredentials: allowLocalCredentials,
      );

      if (decryptedBytes == null) {
        return 2; // Wrong password or corrupted file
      }

      final jsonString = utf8.decode(decryptedBytes);
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      final domainRepository = locate<DomainRepository>();
      final institutionRepository = locate<InstitutionRepository>();
      final recordTypeRepository = locate<RecordTypeRepository>();
      final recordRepository = locate<RecordRepository>();

      // Clear existing data (and cancel all notifications)
      await NotificationService.notifications.cancelAll();
      await domainRepository.clear();
      await institutionRepository.clear();
      await recordTypeRepository.clear();
      await recordRepository.clear();

      // Restore domains
      for (final domain in backupData['domains'] ?? []) {
        await domainRepository.saveByName(domain['name'] as String);
      }

      // Restore institutions
      for (final inst in backupData['institutions'] ?? []) {
        await institutionRepository.saveByName(
          name: inst['name'] as String,
          domainName: inst['domainName'] as String,
        );
      }

      // Restore record types
      for (final rt in backupData['recordTypes'] ?? []) {
        await recordTypeRepository.saveByName(
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

        await recordRepository.saveImported(record);

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
