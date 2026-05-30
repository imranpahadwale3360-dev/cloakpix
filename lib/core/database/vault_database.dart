import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../crypto/secure_key_service.dart';
import '../../shared/models/security_event.dart';
import '../../shared/models/vault_item.dart';

class VaultDatabase {
  VaultDatabase({SecureKeyService? secureKeyService})
      : _secureKeyService = secureKeyService ?? SecureKeyService();

  final SecureKeyService _secureKeyService;
  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(directory.path, 'cloakpix_vault.db');
    final passphrase = await _secureKeyService.getOrCreateDatabasePassphrase();
    return openDatabase(
      dbPath,
      password: passphrase,
      version: 1,
      onCreate: _createSchema,
    );
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vault_items (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        encrypted_path TEXT NOT NULL,
        original_name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        deleted_at INTEGER,
        mime_type TEXT,
        size_bytes INTEGER NOT NULL DEFAULT 0,
        cloud_path TEXT,
        synced_at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE security_events (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        message TEXT NOT NULL,
        encrypted_media_path TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        item_id TEXT NOT NULL,
        action TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        last_error TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> upsertVaultItem(VaultItem item) async {
    final db = await database;
    await db.insert('vault_items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<VaultItem>> listVaultItems({
    VaultItemType? type,
    bool includeDeleted = false,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <Object?>[];
    if (type != null) {
      where.add('type = ?');
      args.add(type.name);
    }
    if (!includeDeleted) where.add('deleted_at IS NULL');
    final rows = await db.query(
      'vault_items',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'created_at DESC',
    );
    return rows.map(VaultItem.fromMap).toList();
  }

  Future<List<VaultItem>> listTrash() async {
    final db = await database;
    final rows = await db.query(
      'vault_items',
      where: 'deleted_at IS NOT NULL',
      orderBy: 'deleted_at DESC',
    );
    return rows.map(VaultItem.fromMap).toList();
  }

  Future<void> softDeleteItem(String id) async {
    final db = await database;
    await db.update(
      'vault_items',
      {'deleted_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> restoreItem(String id) async {
    final db = await database;
    await db.update('vault_items', {'deleted_at': null}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<VaultItem>> expiredTrash({Duration retention = const Duration(days: 30)}) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(retention).millisecondsSinceEpoch;
    final rows = await db.query(
      'vault_items',
      where: 'deleted_at IS NOT NULL AND deleted_at < ?',
      whereArgs: [cutoff],
    );
    return rows.map(VaultItem.fromMap).toList();
  }

  Future<void> removeItemRecord(String id) async {
    final db = await database;
    await db.delete('vault_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertSecurityEvent(SecurityEvent event) async {
    final db = await database;
    await db.insert('security_events', event.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SecurityEvent>> listSecurityEvents() async {
    final db = await database;
    final rows = await db.query('security_events', orderBy: 'created_at DESC');
    return rows.map(SecurityEvent.fromMap).toList();
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query('app_settings', where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
