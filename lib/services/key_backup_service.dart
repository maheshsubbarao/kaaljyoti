import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

class KeyBackupService {
  static const _channel = MethodChannel('kaaljyoti/blockstore');
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'kaaljyoti_db_passphrase';
  static String? lastReadOutcome;

  Future<String?> read() async {
    if (!Platform.isAndroid) return null;
    try {
      final local = await _storage.read(key: _keyName);
      if (local != null && local.isNotEmpty) {
        lastReadOutcome = null;
        return local;
      }
    } catch (e) {
      lastReadOutcome = 'keystore error $e';
    }
    try {
      final value = await _channel.invokeMethod<String>('read');
      if (value != null && value.isNotEmpty) {
        try { await _storage.write(key: _keyName, value: value); } catch (_) {}
        lastReadOutcome = null;
        return value;
      }
    } catch (e) {
      lastReadOutcome = 'blockstore error $e';
    }
    lastReadOutcome ??= 'empty';
    return null;
  }

  Future<bool> write(String passphrase) async {
    if (!Platform.isAndroid) return false;
    bool ok = false;
    try {
      await _storage.write(key: _keyName, value: passphrase);
      ok = true;
    } catch (_) {}
    try {
      final b = await _channel.invokeMethod<bool>('write', {'value': passphrase}) ?? false;
      ok = ok || b;
    } catch (_) {}
    return ok;
  }
}