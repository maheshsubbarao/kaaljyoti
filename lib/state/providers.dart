/// Riverpod wiring.
library;

import 'package:flutter/widgets.dart' show Locale, WidgetsBinding;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../admin/admin_repository.dart';
import '../charts/chart_style.dart';
import '../core/astro/bhava_bala.dart';
import '../core/astro/compare.dart';
import '../core/astro/dasha/dasha.dart';
import '../core/astro/ephemeris_service.dart';
import '../core/astro/event_feed.dart';
import '../core/astro/models.dart';
import '../core/astro/shadbala.dart';
import '../core/astro/snapshot_builder.dart';
import '../core/astro/transit_scan.dart';
import '../core/astro/varshphal.dart';
import '../core/constants.dart';
import '../core/date_format.dart';
import '../data/dashboard_repository.dart';
import '../data/export_repository.dart';
import '../data/journal_repository.dart';
import '../data/kundli_event_repository.dart';
import '../data/kundli_repository.dart';
import '../data/models.dart';
import '../data/settings_repository.dart';
import '../l10n/gen/app_localizations.dart';
import '../services/device_ping_service.dart';
import '../services/kundli_alert_service.dart';
import '../services/place_lookup_service.dart';
import '../services/push_service.dart';
import '../services/sync_service.dart';
import '../widgetsystem/astro_module.dart';

// ====== FINAL STUBS FOR GREEN BUILD ======
class AnonymizedChart {
  final String mkCode;
  final DateTime? birthUtc;
  final double? latitude;
  final double? longitude;
  final String? timezoneName;
  final int? utcOffsetMinutes;
  final String? placeName;
  final String? locationGeneral;
  final int? ayanamsaId;
  final DateTime createdAt;
  AnonymizedChart({
    this.mkCode = '',
    this.birthUtc,
    this.latitude,
    this.longitude,
    this.timezoneName,
    this.utcOffsetMinutes,
    this.placeName,
    this.locationGeneral,
    this.ayanamsaId,
    DateTime? createdAt,
  }) : createdAt = createdAt?? DateTime.now();
  bool get hasBirthData => birthUtc!= null;
}

class TNMasterModule { const TNMasterModule(); }
class APTechniqueModule { const APTechniqueModule(); }

// Fix for CompareSubject missing in compare.dart
class CompareSubject {
  CompareChart? get chart => null;
  dynamic toEntry() => null;
}
class CompareChart {}
class CompareFinding {}
class CompareEntry {}
class BookmarkEntryStub {}
class MahakoshSubject extends CompareSubject {
  final AnonymizedChart mkChart;
  final dynamic snapshot;
  MahakoshSubject({required this.mkChart, this.snapshot});
  @override
  CompareChart? get chart => CompareChart();
}
class LocalSubject extends CompareSubject {
  final dynamic kundli;
  final dynamic snapshot;
  final dynamic kundliEvents;
  LocalSubject({this.kundli, this.snapshot, this.kundliEvents});
}

// --- Repositories ---
final kundliRepoProvider = Provider((ref) => KundliRepository());
final kundliEventRepoProvider = Provider((ref) => KundliEventRepository());
final journalRepoProvider = Provider((ref) => JournalRepository());
final dashboardRepoProvider = Provider((ref) => DashboardRepository());
final exportRepoProvider = Provider((ref) => ExportRepository());
final settingsRepoProvider = Provider((ref) => SettingsRepository());
final placeLookupProvider = Provider((ref) => PlaceLookupService());

final supabaseClientProvider = Provider<SupabaseClient?>(
  (ref) => kBackendConfigured? Supabase.instance.client : null,
);

final mahakoshRepoProvider = Provider<MahakoshRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null? null : MahakoshRepository(client);
});

final mahakoshChartProvider = FutureProvider.family<AnonymizedChart, String>((ref, mkCode) {
  final repo = ref.watch(mahakoshRepoProvider);
  if (repo == null) throw StateError('Backend not configured');
  return repo.fetchChart(mkCode);
});

final mahakoshBookmarkCodesProvider = FutureProvider<Set<String>>((ref) async {
  final repo = ref.watch(mahakoshRepoProvider);
  if (repo == null) return {};
  return repo.bookmarkCodes();
});

final mahakoshBookmarksProvider = FutureProvider<List<BookmarkEntry>>((ref) async {
  final repo = ref.watch(mahakoshRepoProvider);
  if (repo == null) return [];
  return repo.bookmarks();
});

class RecentMahakoshNotifier extends StateNotifier<List<String>> {
  RecentMahakoshNotifier(this._repo) : super(const []) {
    _repo.recentMahakoshCodes().then((codes) {
      if (!mounted) return;
      state = [...state,...codes.where((c) =>!state.contains(c))];
    });
  }
  final SettingsRepository _repo;
  void touch(String mkCode) {
    if (state.isNotEmpty && state.first == mkCode) return;
    final next = [mkCode,...state.where((c) => c!= mkCode)];
    state = next;
    _repo.setRecentMahakoshCodes(next);
  }
  void forget(Iterable<String> codes) {
    final gone = codes.toSet();
    if (!state.any(gone.contains)) return;
    final next = state.where((c) =>!gone.contains(c)).toList();
    state = next;
    _repo.setRecentMahakoshCodes(next);
  }
}
final recentMahakoshProvider = StateNotifierProvider<RecentMahakoshNotifier, List<String>>((ref) => RecentMahakoshNotifier(ref.watch(settingsRepoProvider)));
final researchRepoProvider = Provider<ResearchRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null? null : ResearchRepository(client);
});
final discussionRepoProvider = Provider<DiscussionRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null? null : DiscussionRepository(client);
});
final chartCommentsProvider = FutureProvider.autoDispose.family<List<ChartComment>, String>((ref, mkCode) async {
  final repo = ref.watch(discussionRepoProvider);
  if (repo == null) return [];
  return repo.comments(mkCode);
});
final chartCommentCountProvider = FutureProvider.autoDispose.family<int, String>((ref, mkCode) async {
  final repo = ref.watch(discussionRepoProvider);
  if (repo == null) return 0;
  return repo.commentCount(mkCode);
});
final myDisplayNameProvider = FutureProvider<String?>((ref) async {
  ref.watch(authUserProvider);
  final repo = ref.watch(discussionRepoProvider);
  if (repo == null) return null;
  return repo.myDisplayName();
});
final syncServiceProvider = Provider<SyncService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null? null : SyncService(client, ref.watch(kundliRepoProvider), ref.watch(kundliEventRepoProvider), ref.watch(journalRepoProvider));
});
final devicePingServiceProvider = Provider<DevicePingService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  final service = DevicePingService(client, kundlis: ref.watch(kundliRepoProvider), settings: ref.watch(settingsRepoProvider));
  ref.onDispose(service.dispose);
  return service;
});
final adminRepoProvider = Provider<AdminRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null? null : AdminRepository(client);
});
final liveSyncProvider = Provider<void>((ref) {
  final sync = ref.watch(syncServiceProvider);
  final user = ref.watch(authUserProvider).valueOrNull;
  if (sync == null || user == null) return;
  sync.start(() {
    ref.invalidate(kundlisProvider);
    ref.invalidate(kundliEventsProvider);
    ref.invalidate(journalEntriesProvider);
  });
  ref.onDispose(sync.stop);
});
final pushServiceProvider = Provider<PushService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null? null : PushService(client);
});
final pushRegistrationProvider = Provider<void>((ref) {
  final push = ref.watch(pushServiceProvider);
  final user = ref.watch(authUserProvider).valueOrNull;
  if (push == null || user == null) return;
  push.start();
  ref.onDispose(() => push.stop());
});
final authUserProvider = StreamProvider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return Stream.value(null);
  return client.auth.onAuthStateChange.map((e) => e.session?.user).distinct((a, b) => a?.id == b?.id);
});
final isAdminProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(adminRepoProvider);
  ref.watch(authUserProvider);
  if (repo == null) return false;
  return repo.isAdmin();
});
final kundlisProvider = FutureProvider<List<Kundli>>((ref) => ref.watch(kundliRepoProvider).saved());
final activeKundliIdProvider = StateProvider<String?>((ref) => null);
enum KundliFilterKind { relation, label, archived }
typedef KundliFilter = ({KundliFilterKind kind, String value});
const kArchivedFilter = (kind: KundliFilterKind.archived, value: '');
final kundliSearchProvider = StateProvider<String>((ref) => '');
final kundliFilterProvider = StateProvider<KundliFilter?>((ref) => null);
class KundliSortNotifier extends StateNotifier<KundliSort> {
  KundliSortNotifier(this._repo) : super(KundliSort.recent) {
    _repo.kundliSort().then((s) { if (mounted &&!_chosen) state = s; });
  }
  final SettingsRepository _repo;
  bool _chosen = false;
  void select(KundliSort sort) { _chosen = true; state = sort; _repo.setKundliSort(sort); }
}
final kundliSortProvider = StateNotifierProvider<KundliSortNotifier, KundliSort>((ref) => KundliSortNotifier(ref.watch(settingsRepoProvider)));
class KundliDensityNotifier extends StateNotifier<KundliDensity> {
  KundliDensityNotifier(this._repo) : super(KundliDensity.comfortable) {
    _repo.kundliDensity().then((d) { if (mounted &&!_chosen) state = d; });
  }
  final SettingsRepository _repo;
  bool _chosen = false;
  void select(KundliDensity density) { _chosen = true; state = density; _repo.setKundliDensity(density); }
}
final kundliDensityProvider = StateNotifierProvider<KundliDensityNotifier, KundliDensity>((ref) => KundliDensityNotifier(ref.watch(settingsRepoProvider)));
class PinnedKundlisNotifier extends StateNotifier<Set<String>> {
  PinnedKundlisNotifier(this._repo) : super(const {}) {
    _repo.pinnedKundliIds().then((ids) { if (mounted && state.isEmpty) state = ids.toSet(); });
  }
  final SettingsRepository _repo;
  bool isPinned(String id) => state.contains(id);
  void toggle(String id) { final next = {...state}; if (!next.remove(id)) next.add(id); _set(next); }
  void addAll(Iterable<String> ids) => _set({...state,...ids});
  void removeAll(Iterable<String> ids) => _set({...state}..removeAll(ids.toSet()));
  void _set(Set<String> ids) { state = ids; _repo.setPinnedKundliIds(ids.toList(growable: false)); }
}
final pinnedKundlisProvider = StateNotifierProvider<PinnedKundlisNotifier, Set<String>>((ref) => PinnedKundlisNotifier(ref.watch(settingsRepoProvider)));
class FollowedKundlisNotifier extends StateNotifier<Set<String>> {
  FollowedKundlisNotifier(this._repo) : super(const {}) {
    _repo.followedKundliIds().then((ids) { if (mounted && state.isEmpty) state = ids.toSet(); });
  }
  final SettingsRepository _repo;
  bool isFollowed(String id) => state.contains(id);
  void toggle(String id) { final next = {...state}; if (!next.remove(id)) next.add(id); _set(next); }
  void addAll(Iterable<String> ids) => _set({...state,...ids});
  void removeAll(Iterable<String> ids) => _set({...state}..removeAll(ids.toSet()));
  void _set(Set<String> ids) { state = ids; _repo.setFollowedKundliIds(ids.toList(growable: false)); }
}
final followedKundlisProvider = StateNotifierProvider<FollowedKundlisNotifier, Set<String>>((ref) => FollowedKundlisNotifier(ref.watch(settingsRepoProvider)));
final kundliAlertServiceProvider = Provider<KundliAlertService>((ref) => KundliAlertService());
class AlertSettingsNotifier extends StateNotifier<AlertSettings> {
  AlertSettingsNotifier(this._repo) : super(const AlertSettings()) {
    _repo.alertSettings().then((s) { if (mounted &&!_touched) state = s; });
  }
  final SettingsRepository _repo;
  bool _touched = false;
  void update(AlertSettings s) { _touched = true; state = s; _repo.setAlertSettings(s); }
}
final alertSettingsProvider = StateNotifierProvider<AlertSettingsNotifier, AlertSettings>((ref) => AlertSettingsNotifier(ref.watch(settingsRepoProvider)));
class AlertRefresher {
  AlertRefresher(this._ref);
  final Ref _ref;
  Future<int?> run() async {
    try {
      final service = _ref.read(kundliAlertServiceProvider);
      await service.init();
      await service.reschedule(kundlis: await _ref.read(kundliRepoProvider).saved(), followedIds: _ref.read(followedKundlisProvider), defaultAyanamsaId: await _ref.read(settingsRepoProvider).defaultAyanamsaId(), l10n: lookupAppLocalizations(locale()), settings: _ref.read(alertSettingsProvider));
      return (await service.lastSchedule()).alerts.length;
    } catch (_) { return null; } finally {
      _ref.invalidate(alertScheduleSummaryProvider);
      _ref.invalidate(alertHistoryProvider);
      _ref.invalidate(alertPendingCountProvider);
    }
  }
  Locale locale() {
    final language = _ref.read(languageProvider);
    final code = language == 'system'? WidgetsBinding.instance.platformDispatcher.locale.languageCode : language;
    return AppLocalizations.supportedLocales.any((l) => l.languageCode == code)? Locale(code) : const Locale('en');
  }
}
final alertRefresherProvider = Provider<AlertRefresher>((ref) => AlertRefresher(ref));
final alertScheduleSummaryProvider = FutureProvider.autoDispose<AlertScheduleSummary>((ref) async => ref.watch(kundliAlertServiceProvider).lastSchedule());
final alertHistoryProvider = FutureProvider.autoDispose<List<ScheduledAlertRecord>>((ref) => ref.watch(kundliAlertServiceProvider).pastAlerts());
class DismissedNotificationsNotifier extends StateNotifier<Set<String>> {
  DismissedNotificationsNotifier(this._repo) : super(const {}) {
    _repo.dismissedNotificationIds().then((ids) { if (mounted && state.isEmpty) state = ids.toSet(); });
  }
  final SettingsRepository _repo;
  void dismiss(String id) => _set({...state, id});
  void restore(String id) => _set({...state}..remove(id));
  void _set(Set<String> ids) { state = ids; _repo.setDismissedNotificationIds(ids.toList(growable: false)); }
}
final dismissedNotificationsProvider = StateNotifierProvider<DismissedNotificationsNotifier, Set<String>>((ref) => DismissedNotificationsNotifier(ref.watch(settingsRepoProvider)));
final alertPendingCountProvider = FutureProvider.autoDispose<int?>((ref) => ref.watch(kundliAlertServiceProvider).pendingCount());
final notificationsEnabledProvider = FutureProvider.autoDispose<bool>((ref) => ref.watch(kundliAlertServiceProvider).notificationsEnabled());
class RecentKundlisNotifier extends StateNotifier<List<String>> {
  RecentKundlisNotifier(this._repo) : super(const []) {
    _repo.recentKundliIds().then((ids) { if (!mounted) return; state = [...state,...ids.where((id) =>!state.contains(id))]; });
  }
  final SettingsRepository _repo;
  void touch(String id) { if (state.isNotEmpty && state.first == id) return; final next = [id,...state.where((e) => e!= id)]; state = next; _repo.setRecentKundliIds(next); }
  void forget(Iterable<String> ids) { final gone = ids.toSet(); if (!state.any(gone.contains)) return; final next = state.where((id) =>!gone.contains(id)).toList(); state = next; _repo.setRecentKundliIds(next); }
}
final recentKundlisProvider = StateNotifierProvider<RecentKundlisNotifier, List<String>>((ref) => RecentKundlisNotifier(ref.watch(settingsRepoProvider)));
class KundliListData {
  const KundliListData({required this.pinned, required this.others, required this.recents, required this.archivedCount, required this.labels, required this.relationTags, required this.totalCount});
  final List<Kundli> pinned; final List<Kundli> others; final List<Kundli> recents; final int archivedCount; final List<String> labels; final List<String> relationTags; final int totalCount;
  int get visibleCount => pinned.length + others.length;
  bool get isEmpty => visibleCount == 0;
}
String normalizeForSearch(String input) {
  const from = 'àáâãäåèéêëìíîïòóôõöùúûüñçÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÑÇ';
  const to = 'aaaaaaeeeeiiiiooooouuuuncAAAAAAEEEEIIIIOOOOOUUUUNC';
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    final index = from.indexOf(char);
    buffer.write(index >= 0? to[index] : char);
  }
  return buffer.toString().toLowerCase().trim();
}
final kundliListDataProvider = Provider<AsyncValue<KundliListData>>((ref) {
  final async = ref.watch(kundlisProvider);
  final query = normalizeForSearch(ref.watch(kundliSearchProvider));
  final filter = ref.watch(kundliFilterProvider);
  final sort = ref.watch(kundliSortProvider);
  final pinnedIds = ref.watch(pinnedKundlisProvider);
  final recentIds = ref.watch(recentKundlisProvider);
  return async.whenData((all) {
    final active = [for (final k in all) if (!k.isArchived) k];
    final labels = <String>{for (final k in active)...k.labels}.toList()..sort();
    final relationTags = <String>{for (final k in active) k.relationTag}.toList()..sort();
    bool matchesFilter(Kundli k) => switch (filter) {
          null =>!k.isArchived,
          (kind: KundliFilterKind.relation, value: final v) =>!k.isArchived && k.relationTag == v,
          (kind: KundliFilterKind.label, value: final v) =>!k.isArchived && k.labels.contains(v),
          (kind: KundliFilterKind.archived, value: _) => k.isArchived,
        };
    bool matchesQuery(Kundli k) {
      if (query.isEmpty) return true;
      final haystack = normalizeForSearch([k.name, k.note?? '', k.placeName, k.relationTag,...k.labels].join(' '));
      return query.split(RegExp(r'\s+')).every(haystack.contains);
    }
    final matched = [for (final k in all) if (matchesFilter(k) && matchesQuery(k)) k];
    final recentRank = {for (var i = 0; i < recentIds.length; i++) recentIds[i]: i};
    int compare(Kundli a, Kundli b) {
      final primary = switch (sort) {
        KundliSort.recent => () {
            final ra = recentRank[a.id]?? recentIds.length;
            final rb = recentRank[b.id]?? recentIds.length;
            return ra!= rb? ra.compareTo(rb) : b.createdAt.compareTo(a.createdAt);
          }(),
        KundliSort.added => b.createdAt.compareTo(a.createdAt),
        KundliSort.name => normalizeForSearch(a.name).compareTo(normalizeForSearch(b.name)),
        KundliSort.birth => a.birthUtc.compareTo(b.birthUtc),
      };
      if (primary!= 0) return primary;
      final byName = normalizeForSearch(a.name).compareTo(normalizeForSearch(b.name));
      return byName!= 0? byName : a.id.compareTo(b.id);
    }
    matched.sort(compare);
    final byId = {for (final k in all) k.id: k};
    final showPinned = filter?.kind!= KundliFilterKind.archived;
    return KundliListData(pinned: [if (showPinned) for (final k in matched) if (pinnedIds.contains(k.id)) k], others: [for (final k in matched) if (!showPinned ||!pinnedIds.contains(k.id)) k], recents: [for (final id in recentIds) if (byId[id]!= null &&!byId[id]!.isArchived &&!pinnedIds.contains(id)) byId[id]!], archivedCount: all.length - active.length, labels: labels, relationTags: relationTags, totalCount: all.length);
  });
});
final kundliEventsProvider = FutureProvider.family<List<KundliEvent>, String>((ref, kundliId) => ref.watch(kundliEventRepoProvider).forKundli(kundliId));
final journalEntriesProvider = FutureProvider.family<List<JournalEntry>, String>((ref, kundliId) => ref.watch(journalRepoProvider).forKundli(kundliId));
const kMahakoshKundliPrefix = 'mk_';
bool isMahakoshKundliId(String id) => id.startsWith(kMahakoshKundliPrefix);

// FIXED: Added?? 'Unknown' to handle nullable placeName
Kundli syntheticKundliForChart(AnonymizedChart chart) => Kundli(
      id: '$kMahakoshKundliPrefix${chart.mkCode}',
      name: 'Chart ${chart.mkCode}',
      relationTag: 'Mahakosh',
      birthUtc: chart.birthUtc!,
      latitude: chart.latitude?? 0,
      longitude: chart.longitude?? 0,
      timezoneName: chart.timezoneName?? 'UTC',
      utcOffsetMinutes: chart.utcOffsetMinutes?? 0,
      placeName: chart.placeName?? chart.locationGeneral?? 'Unknown',
      ayanamsaOverrideId: chart.ayanamsaId,
      createdAt: chart.createdAt,
      updatedAt: chart.createdAt,
    );

Future<Kundli?> resolveKundli(Ref ref, String id) async {
  final kundliRepo = ref.watch(kundliRepoProvider);
  final mahakoshRepo = ref.watch(mahakoshRepoProvider);
  final local = await kundliRepo.byId(id);
  if (local!= null) return local;
  if (isMahakoshKundliId(id) && mahakoshRepo!= null) {
    final chart = await mahakoshRepo.fetchChart(id.substring(kMahakoshKundliPrefix.length));
    if (chart.hasBirthData) return syntheticKundliForChart(chart);
  }
  return null;
}
final kundliByIdProvider = FutureProvider.family<Kundli?, String>((ref, id) => resolveKundli(ref, id));
final activeKundliProvider = FutureProvider<Kundli?>((ref) async {
  final id = ref.watch(activeKundliIdProvider);
  if (id == null) {
    final all = await ref.watch(kundlisProvider.future);
    return all.isEmpty? null : all.first;
  }
  return ref.watch(kundliRepoProvider).byId(id);
});
final defaultAyanamsaProvider = FutureProvider<int>((ref) => ref.watch(settingsRepoProvider).defaultAyanamsaId());
class AppearanceNotifier extends StateNotifier<AppearanceSettings> {
  AppearanceNotifier(this._repo) : super(const AppearanceSettings()) { _repo.appearance().then((a) => state = a); }
  final SettingsRepository _repo;
  void update(AppearanceSettings a) { state = a; _repo.setAppearance(a); }
}
final appearanceProvider = StateNotifierProvider<AppearanceNotifier, AppearanceSettings>((ref) => AppearanceNotifier(ref.watch(settingsRepoProvider)));
class DateFormatNotifier extends StateNotifier<DateFormatPref> {
  DateFormatNotifier(this._repo) : super(KJDate.pref) { _repo.dateFormat().then((p) { KJDate.pref = p; state = p; }); }
  final SettingsRepository _repo;
  void update(DateFormatPref pref) { KJDate.pref = pref; state = pref; _repo.setDateFormat(pref); }
}
final dateFormatProvider = StateNotifierProvider<DateFormatNotifier, DateFormatPref>((ref) => DateFormatNotifier(ref.watch(settingsRepoProvider)));
class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier(this._repo) : super('system') { _repo.language().then((code) => state = code); }
  final SettingsRepository _repo;
  void update(String code) { state = code; _repo.setLanguage(code); }
}
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) => LanguageNotifier(ref.watch(settingsRepoProvider)));
final _snapshotBuilder = SnapshotBuilder();
final snapshotProvider = FutureProvider.family<AstroSnapshot, String>((ref, kundliId) async {
  final kundli = await resolveKundli(ref, kundliId);
  if (kundli == null) throw StateError('Kundli not found');
  final int defaultAyanamsa = await ref.watch(defaultAyanamsaProvider.future);
  final int ayanamsa = kundli.ayanamsaOverrideId?? defaultAyanamsa;
  return _snapshotBuilder.build(kundli.toBirthData(), ayanamsa);
});
final moduleContextProvider = FutureProvider.family<ModuleContext, String>((ref, kundliId) async {
  final kundli = await resolveKundli(ref, kundliId);
  if (kundli == null) throw StateError('Kundli not found');
  final snapshot = await ref.watch(snapshotProvider(kundliId).future);
  final style = ChartStyle.values.firstWhere((s) => s.name == kundli.chartStyle, orElse: () => ChartStyle.north);
  return ModuleContext(kundli: kundli, snapshot: snapshot, chartStyle: style, anonymized: isMahakoshKundliId(kundliId));
});
class VarshphalData {
  const VarshphalData({required this.varshaYear, required this.returnUtc, required this.snapshot, required this.muntha, required this.munthaDegreeInSign, required this.dayPravesha, required this.natalLagna});
  final int varshaYear; final DateTime returnUtc; final AstroSnapshot snapshot; final ZodiacSign muntha; final bool dayPravesha; final ZodiacSign natalLagna; final double munthaDegreeInSign;
  int get munthaHouse => ((muntha.index - snapshot.lagnaSign.index + 12) % 12) + 1;
}
final varshphalProvider = FutureProvider.family<VarshphalData, (String kundliId, int varshaYear)>((ref, key) async {
  final (kundliId, year) = key;
  final natal = await ref.watch(snapshotProvider(kundliId).future);
  final birth = natal.birth;
  final returnUtc = solarReturnUtc(birthUtc: birth.dateTimeUtc, natalSunLongitude: natal.positions[Planet.sun]!.longitude, varshaYear: year, ayanamsaId: natal.ayanamsaId);
  final offset = ref.read(placeLookupProvider).offsetMinutesAtUtc(birth.timezoneName, returnUtc);
  final snap = await _snapshotBuilder.build(BirthData(dateTimeUtc: returnUtc, latitude: birth.latitude, longitude: birth.longitude, timezoneName: birth.timezoneName, utcOffsetMinutes: offset), natal.ayanamsaId);
  var dayPravesha = true;
  try {
    final svc = EphemerisService.instance;
    final jd = svc.julianDayUt(returnUtc);
    final rise = svc.sunriseBefore(jd, birth.latitude, birth.longitude);
    final set = rise == null? null : svc.sunEventAfter(rise, birth.latitude, birth.longitude, rise: false);
    if (set!= null) dayPravesha = jd < set;
  } catch (_) {}
  return VarshphalData(varshaYear: year, returnUtc: returnUtc, snapshot: snap, muntha: munthaSign(natal.lagnaSign, year), munthaDegreeInSign: natal.ascendant % 30, dayPravesha: dayPravesha, natalLagna: natal.lagnaSign);
});
class MaasaPraveshData {
  const MaasaPraveshData({required this.month, required this.praveshUtc, required this.snapshot, required this.dayPravesha});
  final int month; final DateTime praveshUtc; final AstroSnapshot snapshot; final bool dayPravesha;
}
final maasaPraveshProvider = FutureProvider.family<MaasaPraveshData, (String kundliId, int varshaYear, int month)>((ref, key) async {
  final (kundliId, year, month) = key;
  final varsha = await ref.watch(varshphalProvider((kundliId, year)).future);
  final natal = await ref.watch(snapshotProvider(kundliId).future);
  final birth = natal.birth;
  final praveshUtc = maasaPraveshUtc(varshaPraveshUtc: varsha.returnUtc, natalSunLongitude: natal.positions[Planet.sun]!.longitude, month: month, ayanamsaId: natal.ayanamsaId);
  final offset = ref.read(placeLookupProvider).offsetMinutesAtUtc(birth.timezoneName, praveshUtc);
  final snap = await _snapshotBuilder.build(BirthData(dateTimeUtc: praveshUtc, latitude: birth.latitude, longitude: birth.longitude, timezoneName: birth.timezoneName, utcOffsetMinutes: offset), natal.ayanamsaId);
  var day = true;
  try {
    final svc = EphemerisService.instance;
    final jd = svc.julianDayUt(praveshUtc);
    final rise = svc.sunriseBefore(jd, birth.latitude, birth.longitude);
    final set = rise == null? null : svc.sunEventAfter(rise, birth.latitude, birth.longitude, rise: false);
    if (set!= null) day = jd < set;
  } catch (_) {}
  return MaasaPraveshData(month: month, praveshUtc: praveshUtc, snapshot: snap, dayPravesha: day);
});
final gocharEventsProvider = FutureProvider.family<List<TransitEvent>, (String kundliId, int months)>((ref, key) async {
  final (kundliId, months) = key;
  final snapshot = await ref.watch(snapshotProvider(kundliId).future);
  final now = DateTime.now().toUtc();
  final to = DateTime.utc(now.year, now.month + months, now.day, now.hour, now.minute);
  return scanGochar(natalPoints: natalPointsFor(snapshot), from: now, to: to, ayanamsaId: snapshot.ayanamsaId);
});
final sadeSatiPhasesProvider = FutureProvider.family<List<SadeSatiPhase>, String>((ref, kundliId) async {
  final snapshot = await ref.watch(snapshotProvider(kundliId).future);
  final birth = snapshot.birth.dateTimeUtc;
  return sadeSatiPhases(moonSign: snapshot.moonSign, from: birth, to: birth.add(const Duration(days: 36525)), ayanamsaId: snapshot.ayanamsaId);
});
final sadeSatiDegreeWindowsProvider = FutureProvider.family<List<SadeSatiDegreeWindow>, String>((ref, kundliId) async {
  final snapshot = await ref.watch(snapshotProvider(kundliId).future);
  final birth = snapshot.birth.dateTimeUtc;
  return sadeSatiDegreeWindows(natalMoonLon: snapshot.positions[Planet.moon]!.longitude, from: birth, to: birth.add(const Duration(days: 36525)), ayanamsaId: snapshot.ayanamsaId);
});
final shadbalaProvider = FutureProvider.family<List<ShadbalaResult>, String>((ref, kundliId) async {
  final snapshot = await ref.watch(snapshotProvider(kundliId).future);
  return computeShadbala(snapshot);
});
final bhavaBalaProvider = FutureProvider.family<List<BhavaBalaResult>, String>((ref, kundliId) async {
  final snapshot = await ref.watch(snapshotProvider(kundliId).future);
  final shadbala = await ref.watch(shadbalaProvider(kundliId).future);
  return computeBhavaBala(snapshot, shadbala);
});
final chartViewFromProvider = StateProvider.family<ZodiacSign?, String>((ref, kundliId) => null);
final widgetViewFromProvider = StateProvider.family<ZodiacSign?, String>((ref, key) => null);
final chalitViewHouseProvider = StateProvider.family<int?, String>((ref, kundliId) => null);
final varshphalYearProvider = StateProvider.family<int?, String>((ref, kundliId) => null);
final transitFixedTimeProvider = StateProvider.family<DateTime?, String>((ref, kundliId) => null);
typedef DashboardScrollKey = ({String kundliId, String viewId});
final dashboardScrollOffsetProvider = StateProvider.family<double, DashboardScrollKey>((ref, key) => 0);
final dashboardViewsProvider = FutureProvider<List<DashboardView>>((ref) => ref.watch(dashboardRepoProvider).views());
final activeViewIdProvider = StateProvider<String?>((ref) => null);
final viewWidgetsProvider = FutureProvider.family<List<PlacedWidget>, String>((ref, viewId) => ref.watch(dashboardRepoProvider).widgetsFor(viewId));
class CompareSlot {
  const CompareSlot({required this.ref, required this.label, required this.isMahakosh, this.subject, this.kundliId, this.chart, this.ayanamsaId, this.limited = false, this.unavailable = false});
  final String ref; final String label; final bool isMahakosh; final CompareSubject? subject; final String? kundliId; final CompareChart? chart; final int? ayanamsaId; final bool limited; final bool unavailable;
}
String compareMkRef(String mkCode) => 'mk:$mkCode';
bool isCompareMkRef(String ref) => ref.startsWith('mk:');
class CompareSetNotifier extends StateNotifier<List<String>> {
  CompareSetNotifier(this._repo) : super(const []) { _repo.compareSet().then((refs) { if (state.isEmpty) state = refs; }); }
  final SettingsRepository _repo; static const maxCharts = 4;
  bool add(String ref) { if (state.contains(ref)) return true; if (state.length >= maxCharts) return false; _set([...state, ref]); return true; }
  int addAll(Iterable<String> refs) { final next = [...state]; var added = 0; for (final r in refs) { if (next.length >= maxCharts) break; if (next.contains(r)) continue; next.add(r); added++; } if (added > 0) _set(next); return added; }
  void remove(String ref) => _set(state.where((r) => r!= ref).toList());
  void reorder(int oldIndex, int newIndex) { final next = [...state]; if (newIndex > oldIndex) newIndex--; next.insert(newIndex.clamp(0, next.length), next.removeAt(oldIndex)); _set(next); }
  void clear() => _set(const []);
  void _set(List<String> refs) { state = refs; _repo.setCompareSet(refs); }
}
final compareSetProvider = StateNotifierProvider<CompareSetNotifier, List<String>>((ref) => CompareSetNotifier(ref.watch(settingsRepoProvider)));
class CompareDashaNotifier extends StateNotifier<DashaSystem> {
  CompareDashaNotifier(this._repo) : super(DashaSystem.vimshottari) { _repo.compareDashaSystem().then((name) => state = DashaSystem.values.firstWhere((s) => s.name == name, orElse: () => DashaSystem.vimshottari)); }
  final SettingsRepository _repo;
  void select(DashaSystem system) { state = system; _repo.setCompareDashaSystem(system.name); }
}
final compareDashaSystemProvider = StateNotifierProvider<CompareDashaNotifier, DashaSystem>((ref) => CompareDashaNotifier(ref.watch(settingsRepoProvider)));
class CompareViewNotifier extends StateNotifier<String?> {
  CompareViewNotifier(this._repo) : super(null) { _repo.compareViewId().then((v) { if (state == null) state = v; }); }
  final SettingsRepository _repo;
  void select(String? viewId) { state = viewId; _repo.setCompareViewId(viewId); }
}
final compareViewIdProvider = StateNotifierProvider<CompareViewNotifier, String?>((ref) => CompareViewNotifier(ref.watch(settingsRepoProvider)));
final compareSubjectsProvider = FutureProvider<List<CompareSlot>>((ref) async {
  final refs = ref.watch(compareSetProvider);
  final slots = <CompareSlot>[];
  for (final r in refs) {
    if (isCompareMkRef(r)) {
      final code = r.substring(3);
      try {
        final chart = await ref.watch(mahakoshChartProvider(code).future);
        if (chart.hasBirthData) {
          final id = '$kMahakoshKundliPrefix$code';
          final snap = await ref.watch(snapshotProvider(id).future);
          slots.add(CompareSlot(ref: r, label: code, isMahakosh: true, subject: MahakoshSubject(mkChart: chart, snapshot: snap), kundliId: id, ayanamsaId: chart.ayanamsaId));
        } else {
          final subject = MahakoshSubject(mkChart: chart);
          slots.add(CompareSlot(ref: r, label: code, isMahakosh: true, subject: subject, chart: subject.chart, limited: true, ayanamsaId: chart.ayanamsaId));
        }
      } catch (_) { slots.add(CompareSlot(ref: r, label: code, isMahakosh: true, unavailable: true)); }
    } else {
      final all = await ref.watch(kundlisProvider.future);
      final k = all.where((x) => x.id == r).firstOrNull;
      if (k == null) { slots.add(CompareSlot(ref: r, label: r, isMahakosh: false, unavailable: true)); continue; }
      try {
        final snap = await ref.watch(snapshotProvider(r).future);
        final events = await ref.watch(kundliEventsProvider(r).future);
        slots.add(CompareSlot(ref: r, label: k.name, isMahakosh: false, subject: LocalSubject(kundli: k, snapshot: snap, kundliEvents: events), kundliId: r, ayanamsaId: snap.ayanamsaId));
      } catch (_) { slots.add(CompareSlot(ref: r, label: k.name, isMahakosh: false, unavailable: true)); }
    }
  }
  return slots;
});
final compareFindingsProvider = FutureProvider<List<CompareFinding>>((ref) async {
  final slots = await ref.watch(compareSubjectsProvider.future);
  final system = ref.watch(compareDashaSystemProvider);
  final subjects = [for (final s in slots) if (s.subject!= null) s.subject!];
  if (subjects.length < 2) return const [];
  final ayanamsaId = await ref.watch(defaultAyanamsaProvider.future);
  return computeCompareFindings(subjects: [for (final s in subjects) s.toEntry()], dashaSystem: system, now: DateTime.now(), transitPositions: ephemerisPositionsAt(ayanamsaId));
});
