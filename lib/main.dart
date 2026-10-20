import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app.dart';
import 'charts/chart_tuning.dart';
import 'core/astro/ephemeris_service.dart';
import 'core/constants.dart';
import 'data/settings_repository.dart';

Future<void> main() async {
  if (kSentryDsn.isNotEmpty && !kDebugMode) {
    await SentryFlutter.init(
      (options) {
        options.dsn = kSentryDsn;
        options.tracesSampleRate = 0;
        options.beforeSend = (event, hint) {
          final t = event.throwable;
          final msg = t?.toString() ?? '';
          final offlineNoise = msg.contains('SocketException') || 
                               msg.contains('AuthRetryableFetchException') ||
                               t is AuthRetryableFetchException;
          return offlineNoise ? null : event;
        };
      },
      appRunner: _run,
    );
  } else {
    await _run();
  }
}

Future<void> _run() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIX FOR WEB + APK DATABASE - ADD THIS BLOCK
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  // END FIX - For APK it will use native factory automatically

  GoogleFonts.config.allowRuntimeFetching = true; // FIXED FROM false

  try {
    await EphemerisService.init().timeout(const Duration(seconds: 30));
  } catch (e) {
    debugPrint('Ephemeris init failed/timeout: $e - will retry later');
    try {
      await EphemerisService.init();
    } catch (e2) {
      debugPrint('Second retry also failed: $e2');
    }
  }

  try {
    tzdata.initializeTimeZones();
  } catch (_) {}

  if (!EphemerisService.isReady) {
    try {
      await EphemerisService.init();
    } catch (_) {}
  }

  try {
    chartTuning.value = await SettingsRepository().chartText()
       .timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint('Settings load failed: $e');
  }

  if (kBackendConfigured) {
    try {
      await Supabase.initialize(url: kSupabaseUrl, anonKey: kSupabaseAnonKey)
         .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  runApp(const ProviderScope(child: KaalJyotiApp()));
}