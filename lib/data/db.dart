import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlcipher_sqflite;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common/sqflite.dart' show inMemoryDatabasePath, OpenDatabaseOptions, Database;

import '../services/key_backup_service.dart';

class AppDb {
  AppDb._();
  static final AppDb instance = AppDb._();
  static const _dbName = 'kaaljyoti.db';
  
  Database? _db;
  final KeyBackupService _keyService = KeyBackupService();

  Future<Database> get database async {
    if (_db != null) return _db!;
    if (kIsWeb) {
      _db = await _openWeb();
      return _db!;
    }
    _db = await _openMobile();
    return _db!;
  }

  // Needed by app.dart - FIX 1
  Future<void> checkpoint() async {
    if (kIsWeb) return;
    try { await _db?.execute('PRAGMA wal_checkpoint(TRUNCATE)'); } catch (_) {}
  }

  Future<Database> _openWeb() async {
    var factory = databaseFactoryFfiWeb;
    final db = await factory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 11,
        onConfigure: (db) async {
          try { await db.execute('PRAGMA foreign_keys = ON'); } catch(_){}
        },
        onCreate: (db, version) async {
          await _createAllTables(db);
          try { await db.insert('dashboard_views', {'id':'default_view','name':'Default','position':0}); } catch(_){}
        },
        onOpen: (db) async {
          try { await db.delete('kundlis', where: 'is_ephemeral = 1'); } catch(_){}
        }
      ),
    );
    return db;
  }

  Future<Database> _openMobile() async {
    final dbPath = await sqlcipher_sqflite.getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    final passphrase = await _getOrCreatePassphrase();
    return await sqlcipher_sqflite.openDatabase(
      path,
      password: passphrase,
      version: 11,
      onConfigure: (db) async { 
        try { await db.execute('PRAGMA foreign_keys = ON'); } catch(_){}
      },
      onCreate: (db, v) async { 
        await _createAllTables(db); 
        try { await db.insert('dashboard_views', {'id':'default_view','name':'Default','position':0}); } catch(_){}
      },
    );
  }

  Future<void> _createAllTables(Database db) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS kundlis (id TEXT PRIMARY KEY, name TEXT NOT NULL, relation_tag TEXT NOT NULL DEFAULT 'Self', note TEXT, labels TEXT, birth_utc INTEGER NOT NULL, lat REAL NOT NULL, lon REAL NOT NULL, tz_name TEXT NOT NULL, utc_offset_min INTEGER NOT NULL, place_name TEXT NOT NULL, ayanamsa_id INTEGER, chart_style TEXT DEFAULT 'north', is_prashna INTEGER NOT NULL DEFAULT 0, is_ephemeral INTEGER NOT NULL DEFAULT 0, is_archived INTEGER NOT NULL DEFAULT 0, sync_enabled INTEGER NOT NULL DEFAULT 0, mahakosh_code TEXT, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)''');
    await db.execute(_createKundliEventsSql);
    await _createJournalEntries(db);
    await db.execute('''CREATE TABLE IF NOT EXISTS dashboard_views (id TEXT PRIMARY KEY, name TEXT NOT NULL, position INTEGER NOT NULL)''');
    await db.execute('''CREATE TABLE IF NOT EXISTS view_widgets (instance_id TEXT PRIMARY KEY, view_id TEXT NOT NULL, widget_id TEXT NOT NULL, position INTEGER NOT NULL, span TEXT NOT NULL DEFAULT 'half', config TEXT NOT NULL DEFAULT '{}')''');
    await db.execute('''CREATE TABLE IF NOT EXISTS mahakosh_bookmarks (mk_code TEXT PRIMARY KEY, payload TEXT NOT NULL, created_at INTEGER NOT NULL)''');
    await db.execute(_createExportTemplateSql);
  }

  // FIX 2 - Don't call generate(), create our own key
  Future<String> _getOrCreatePassphrase() async {
    try {
      var existing = await _keyService.read();
      if (existing != null && existing.isNotEmpty) return existing;
      final newKey = _randomKey();
      try { await _keyService.write(newKey); } catch(_){}
      return newKey;
    } catch (_) { 
      return _randomKey();
    }
  }

  String _randomKey() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return List.generate(32, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  static const _createKundliEventsSql = '''CREATE TABLE IF NOT EXISTS kundli_events (id TEXT PRIMARY KEY, kundli_id TEXT NOT NULL REFERENCES kundlis(id) ON DELETE CASCADE, title TEXT NOT NULL, event_utc INTEGER NOT NULL, lat REAL, lon REAL, tz_name TEXT, utc_offset_min INTEGER, place_name TEXT, note TEXT, created_at INTEGER NOT NULL)''';
  static const _createExportTemplateSql = '''CREATE TABLE IF NOT EXISTS export_templates (id TEXT PRIMARY KEY, name TEXT NOT NULL, config TEXT NOT NULL)''';
  
  Future<void> _createJournalEntries(Database db) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS journal_entries (id TEXT PRIMARY KEY, kundli_id TEXT NOT NULL REFERENCES kundlis(id) ON DELETE CASCADE, entry_utc INTEGER NOT NULL, title TEXT NOT NULL, content TEXT NOT NULL, tags TEXT, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)''');
  }
  
  Future<void> close() async { try { await _db?.close(); } finally { _db = null; } }
}