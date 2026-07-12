import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bbeez_one/platform/models/domain_model.dart';
import 'package:bbeez_one/platform/models/institution_model.dart';
import 'package:bbeez_one/platform/models/record_model.dart';
import 'package:bbeez_one/platform/models/record_type_model.dart';
import 'package:bbeez_one/platform/models/secret_field_model.dart';

class DatabaseManager {
  DatabaseManager._();

  static final DatabaseManager instance = DatabaseManager._();

  Future<void>? _initialization;
  String? _databasePath;

  Future<void> initialize() {
    _initialization ??= _initializeInternal();
    return _initialization!;
  }

  Future<void> _initializeInternal() async {
    final dir = await getApplicationDocumentsDirectory();
    _databasePath = dir.path;

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DomainModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(InstitutionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RecordTypeModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(RecordModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(SecretFieldAdapter());
    }

    await Future.wait([
      getDomainBox(),
      getInstitutionBox(),
      getRecordTypeBox(),
      getRecordBox(),
    ]);
  }

  Future<Box<DomainModel>> getDomainBox() async {
    await initialize();
    return _openBox<DomainModel>('domains');
  }

  Future<Box<InstitutionModel>> getInstitutionBox() async {
    await initialize();
    return _openBox<InstitutionModel>('institutions');
  }

  Future<Box<RecordTypeModel>> getRecordTypeBox() async {
    await initialize();
    return _openBox<RecordTypeModel>('recordTypes');
  }

  Future<Box<RecordModel>> getRecordBox() async {
    await initialize();
    return _openBox<RecordModel>('records');
  }

  Future<Box<T>> _openBox<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<T>(name);
    }
    return Hive.openBox<T>(name, path: _databasePath);
  }

  Future<void> closeAll() async {
    await Future.wait([
      _closeBoxIfOpen('domains'),
      _closeBoxIfOpen('institutions'),
      _closeBoxIfOpen('recordTypes'),
      _closeBoxIfOpen('records'),
    ]);
  }

  Future<void> _closeBoxIfOpen(String name) async {
    if (Hive.isBoxOpen(name)) {
      await Hive.box(name).close();
    }
  }
}
