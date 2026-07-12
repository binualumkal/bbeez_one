# Migration Guide: Isar to Hive

## Quick Reference

### Before (Isar)
```dart
// Models
@collection
class DomainModel {
  Id id = Isar.autoIncrement;
  late String name;
}

// Database Access
await isar.domainModels.where().findAll();
await isar.writeTxn(() async { 
  await isar.domainModels.put(domain);
});
record.id  // Access ID
```

### After (Hive)
```dart
// Models
@HiveType(typeId: 0)
class DomainModel extends HiveObject {
  @HiveField(0)
  late String name;
}

// Database Access
domainBox.values.toList();
await domainBox.add(domain);
record.key  // Access ID
```

## Type ID Mapping

| Model | HiveType ID |
|-------|------------|
| DomainModel | 0 |
| InstitutionModel | 1 |
| RecordTypeModel | 2 |
| RecordModel | 3 |
| SecretField | 4 |

⚠️ **IMPORTANT**: Never change these IDs once set, as they're used for serialization!

## Common Patterns

### Query All Records
```dart
// Before: await isar.recordModels.where().findAll();
// After:
final records = DatabaseService.recordBox.values.toList();
```

### Query with Filter
```dart
// Before:
await isar.recordModels
  .filter()
  .domainNameEqualTo('PERSONAL')
  .findAll();

// After:
recordBox.values
  .where((r) => r.domainName == 'PERSONAL')
  .toList();
```

### Delete Cascading
```dart
// Example: Delete domain and all children
final domain = domainBox.get(domainId);
final domainName = domain.name;

// Delete records
final recordsToDelete = recordBox.values
  .where((r) => r.domainName == domainName)
  .toList();
for (final record in recordsToDelete) {
  await record.delete();
}

// Delete domain
await domain.delete();
```

### Working with Keys
```dart
// Hive uses dynamic keys, not strictly numeric
final record = recordBox.get(recordKey);

// Check if item has been saved to box
if (record.key != null) {
  // Record is already in Hive
}

// Add new record (auto-assigns key)
await recordBox.add(newRecord);  // Now newRecord.key is set

// Update existing record
await record.save();  // Updates in place, keeps same key
```

## Migration Checklist for New Features

When adding new models to the database:

1. **Create Model**
   ```dart
   import 'package:hive/hive.dart';
   
   part 'new_model.g.dart';
   
   @HiveType(typeId: X)  // Get next available ID!
   class NewModel extends HiveObject {
     @HiveField(0)
     late String field1;
   }
   ```

2. **Register Adapter** (in database_service.dart)
   ```dart
   if (!Hive.isAdapterRegistered(X)) {
     Hive.registerAdapter(NewModelAdapter());
   }
   ```

3. **Create Box** (in database_service.dart)
   ```dart
   static late Box<NewModel> newModelBox;
   
   // In init():
   newModelBox = await Hive.openBox<NewModel>('newModels', path: dir.path);
   ```

4. **Generate Code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Update Pages** if accessing the model
   - Remember to use `.key` instead of `.id`
   - Handle `record.key == null` for new records

## Debugging Tips

### Check Hive Boxes Contents
```dart
// Print all domains
DatabaseService.domainBox.values.forEach((d) {
  print('${d.key}: ${d.name}');
});
```

### Clear All Boxes (Debug Only)
```dart
await DatabaseService.clearDatabase();
```

### Box Storage Location
```dart
final appDir = await getApplicationDocumentsDirectory();
// Hive boxes stored in: ${appDir.path}/*.hive
```

## Performance Notes

- **Hive is faster for small-to-medium datasets** (which BBeez uses)
- No transaction support like Isar, but operations are atomic per item
- Iterating over large boxes can be memory-intensive; filter before iterating
- Backup/restore is now JSON-based (text format, not binary)

## Common Pitfalls to Avoid

❌ **DON'T:**
- Change HiveType IDs after release
- Use `.id` instead of `.key`
- Forget to extend `HiveObject` in models
- Forget to register adapters
- Call `delete()` on new models that haven't been added

✅ **DO:**
- Use `.key` for record identification
- Check `record.key != null` before passing to functions
- Create items with `await box.add(item)` (auto-assigns key)
- Update items with `await item.save()` (keeps same key)

---

**Last Updated**: July 1, 2026
**Version**: 1.0.4
