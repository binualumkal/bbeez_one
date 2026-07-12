import 'package:bbeez_one/platform/database/database_manager.dart';
import 'package:bbeez_one/platform/repositories/domain_repository.dart';
import 'package:bbeez_one/platform/repositories/hive/hive_domain_repository.dart';
import 'package:bbeez_one/platform/repositories/hive/hive_institution_repository.dart';
import 'package:bbeez_one/platform/repositories/hive/hive_record_repository.dart';
import 'package:bbeez_one/platform/repositories/hive/hive_record_type_repository.dart';
import 'package:bbeez_one/platform/repositories/hive/hive_settings_repository.dart';
import 'package:bbeez_one/platform/repositories/institution_repository.dart';
import 'package:bbeez_one/platform/repositories/record_repository.dart';
import 'package:bbeez_one/platform/repositories/record_type_repository.dart';
import 'package:bbeez_one/platform/repositories/settings_repository.dart';

class ServiceLocator {
  final Map<Type, Object> _services = <Type, Object>{};

  void registerSingleton<T extends Object>(T instance) {
    _services[T] = instance;
  }

  T get<T extends Object>() {
    final service = _services[T];
    if (service == null) {
      throw StateError('Service of type $T is not registered');
    }
    return service as T;
  }

  bool contains<T extends Object>() => _services.containsKey(T);
}

final ServiceLocator serviceLocator = ServiceLocator();

T locate<T extends Object>() => serviceLocator.get<T>();

void setupServiceLocator() {
  if (serviceLocator.contains<DatabaseManager>()) {
    return;
  }

  final databaseManager = DatabaseManager.instance;
  serviceLocator.registerSingleton<DatabaseManager>(databaseManager);

  final settingsRepository = HiveSettingsRepository();
  serviceLocator.registerSingleton<SettingsRepository>(settingsRepository);

  final recordRepository = HiveRecordRepository(
    databaseManager: databaseManager,
    settingsRepository: settingsRepository,
  );
  serviceLocator.registerSingleton<RecordRepository>(recordRepository);

  final recordTypeRepository = HiveRecordTypeRepository(
    databaseManager: databaseManager,
    recordRepository: recordRepository,
  );
  serviceLocator.registerSingleton<RecordTypeRepository>(recordTypeRepository);

  final institutionRepository = HiveInstitutionRepository(
    databaseManager: databaseManager,
    recordTypeRepository: recordTypeRepository,
    recordRepository: recordRepository,
  );
  serviceLocator
      .registerSingleton<InstitutionRepository>(institutionRepository);

  final domainRepository = HiveDomainRepository(
    databaseManager: databaseManager,
    institutionRepository: institutionRepository,
    recordTypeRepository: recordTypeRepository,
    recordRepository: recordRepository,
  );
  serviceLocator.registerSingleton<DomainRepository>(domainRepository);
}
