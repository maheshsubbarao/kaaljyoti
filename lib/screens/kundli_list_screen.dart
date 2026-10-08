library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/date_format.dart';
import '../core/theme/theme.dart';
import '../core/theme/tokens.dart';
import '../core/theme/type_scale.dart';
import '../data/models.dart';
import '../data/settings_repository.dart';
import '../l10n/astro_l10n.dart';
import '../services/location_service.dart';
import '../state/providers.dart';
import '../ui/common.dart';

final kundliMultiSelectProvider = StateProvider<Set<String>?>((ref) => null);
const _searchThreshold = 8;
const _recentsThreshold = 12;
const _sectionHeaderThreshold = 30;
const _recentsShown = 8;

class KundliListScreen extends ConsumerWidget {
  const KundliListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final data = ref.watch(kundliListDataProvider);
    final user = ref.watch(authUserProvider).value;
    final selection = ref.watch(kundliMultiSelectProvider);

    return KJScaffold(
      section: KJSection.kundlis,
      appBar: selection!= null
         ? _selectAppBar(context, ref, selection)
          : AppBar(
              title: Text(l10n.kundlisTitle),
              actions: [
                // NEW: IMPORT BUTTON
                IconButton(
                  icon: const Icon(Icons.file_upload_outlined),
                  tooltip: 'Import JyotishAppCharts.txt',
                  onPressed: () => _importJyotishAppCharts(context, ref),
                ),
                const _ListOptionsButton(),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () => context.push('/notifications'),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: KJSpace.md),
                  child: GestureDetector(
                    onLongPress: () => _castPrashna(context, ref),
                    child: FilledButton(
                      onPressed: () => context.push('/new'),
                      style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: KJSpace.lg + 2,
                              vertical: KJSpace.sm)),
                      child: Text(l10n.plusNew),
                    ),
                  ),
                ),
              ],
            ),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(message: l10n.klLoadError('$e')),
        data: (list) => list.totalCount == 0
           ? _firstRun(context, user)
            : _Library(data: list, showSignIn: user == null),
      ),
    );
  }

  // NEW IMPORT LOGIC - NO EPhemeris calc, just save raw
Future<void> _importJyotishAppCharts(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final content = await rootBundle.loadString('assets/JyotishAppCharts.txt');
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    
    messenger.showSnackBar(SnackBar(content: Text('Found ${lines.length} charts! Importing...')));
    
    int imported = 0;
    final repo = ref.read(kundliRepoProvider);
    
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      
      // Format: Name|DD-MM-YYYY|HH:MM|Lat|Lon|Place  OR Name:::...
      var parts = line.split('|');
      if (parts.length < 2) parts = line.split(':::');
      if (parts.length < 2) parts = line.split('\t');
      
      final name = parts[0].trim();
      if (name.isEmpty) continue;
      
      try {
        String dateStr = parts.length > 1 ? parts[1].trim() : '';
        String timeStr = parts.length > 2 ? parts[2].trim() : '12:00';
        double lat = 23.0;
        double lon = 82.0;
        String place = 'India';
        
        if (parts.length > 3) lat = double.tryParse(parts[3].trim()) ?? lat;
        if (parts.length > 4) lon = double.tryParse(parts[4].trim()) ?? lon;
        if (parts.length > 5) place = parts[5].trim();
        if (parts.length == 4) place = parts[3].trim();
        
        // Parse date DD-MM-YYYY or DD/MM/YYYY or YYYY-MM-DD
        DateTime? localDt;
        if (dateStr.isNotEmpty) {
          dateStr = dateStr.replaceAll('/', '-').replaceAll('.', '-');
          var dParts = dateStr.split('-');
          if (dParts.length == 3) {
            int day, month, year;
            if (dParts[0].length == 4) {
              year = int.parse(dParts[0]); month = int.parse(dParts[1]); day = int.parse(dParts[2]);
            } else {
              day = int.parse(dParts[0]); month = int.parse(dParts[1]); year = int.parse(dParts[2]);
              if (year < 100) year += 1900;
            }
            var tParts = timeStr.split(':');
            int hour = int.tryParse(tParts[0]) ?? 12;
            int minute = tParts.length > 1 ? int.tryParse(tParts[1]) ?? 0 : 0;
            localDt = DateTime(year, month, day, hour, minute);
          }
        }
        localDt ??= DateTime(1990, 1, 1, 12, 0);
        
        // Create kundli - using IST offset +330 min
        await repo.create(
          name: name,
          relationTag: 'Imported',
          birthUtc: localDt.toUtc(),
          latitude: lat,
          longitude: lon,
          timezoneName: 'Asia/Kolkata',
          utcOffsetMinutes: 330,
          placeName: place,
        );
        imported++;
        
        if (imported % 50 == 0) {
          messenger.showSnackBar(SnackBar(content: Text('Imported $imported/${lines.length}...')));
        }
      } catch (e) {
        debugPrint('Failed $name: $e');
      }
    }
    
    ref.invalidate(kundlisProvider);
    ref.invalidate(kundliListDataProvider);
    messenger.showSnackBar(SnackBar(content: Text('Success! Imported $imported charts to Home!')));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Import failed: $e')));
  }
}

  Widget _firstRun(BuildContext context, Object? user) {
    final l10n = context.l10n;
    return Column(
      children: [
        Expanded(
          child: EmptyState(
            leading: Image.asset('assets/emblem.png', width: 64, height: 64),
            message: l10n.klEmpty,
            actionLabel: l10n.newKundli,
            onAction: () => context.push('/new'),
          ),
        ),
        if (user == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                KJSpace.xxxl, 0, KJSpace.xxxl, KJSpace.xxl),
            child: Column(
              children: [
                Text(
                  l10n.klRestoreNudge,
                  textAlign: TextAlign.center,
                  style: KJType.caption(size: 12.5, color: KJColors.inkSoft),
                ),
                TextButton(
                  onPressed: () => context.push('/signin'),
                  child: Text(l10n.signIn),
                ),
              ],
            ),
          ),
      ],
    );
  }

  PreferredSizeWidget _selectAppBar(
      BuildContext context, WidgetRef ref, Set<String> selection) {
    final l10n = context.l10n;
    final canCompare = selection.length >= 2;
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () =>
            ref.read(kundliMultiSelectProvider.notifier).state = null,
      ),
      title: Text(l10n.klSelected('${selection.length}')),
      actions: [
        _selectAction(
          icon: Icons.push_pin_outlined,
          tooltip: l10n.klPin,
          onPressed: selection.isEmpty
             ? null
              : () => _bulkPin(context, ref, selection),
        ),
        _selectAction(
          icon: Icons.notifications_active_outlined,
          tooltip: l10n.klFollowAlerts,
          onPressed: selection.isEmpty
             ? null
              : () => _bulkFollow(context, ref, selection),
        ),
        _selectAction(
          icon: Icons.sell_outlined,
          tooltip: l10n.klLabels,
          onPressed: selection.isEmpty
             ? null
              : () => _bulkLabel(context, ref, selection),
        ),
        Consumer(builder: (context, ref, _) {
          final archived = _selectionArchived(ref, selection);
          return _selectAction(
            icon:
                archived? Icons.unarchive_outlined : Icons.archive_outlined,
            tooltip: archived? l10n.klUnarchive : l10n.klArchive,
            onPressed: selection.isEmpty
               ? null
                : () =>
                    _bulkArchive(context, ref, selection, archived:!archived),
          );
        }),
        _selectAction(
          icon: Icons.delete_outline,
          tooltip: l10n.delete,
          onPressed: selection.isEmpty
             ? null
              : () => _bulkDelete(context, ref, selection),
        ),
        Padding(
          padding: const EdgeInsets.only(right: KJSpace.sm),
          child: FilledButton(
            onPressed: canCompare
               ? () {
                    ref.read(compareSetProvider.notifier).clear();
                    ref
                       .read(compareSetProvider.notifier)
                       .addAll(selection.toList());
                    ref.read(kundliMultiSelectProvider.notifier).state = null;
                    context.push('/compare');
                  }
                : null,
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: KJSpace.md, vertical: KJSpace.sm)),
            child: Text(l10n.klCompareN('${selection.length}')),
          ),
        ),
      ],
    );
  }

  Widget _selectAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) =>
      IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      );

  void _bulkPin(BuildContext context, WidgetRef ref, Set<String> selection) {
    final pins = ref.read(pinnedKundlisProvider.notifier);
    final allPinned = selection.every(pins.isPinned);
    if (allPinned) {
      pins.removeAll(selection);
    } else {
      pins.addAll(selection);
    }
    ref.read(kundliMultiSelectProvider.notifier).state = null;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(allPinned
         ? context.l10n.klUnpinnedN('${selection.length}')
          : context.l10n.klPinnedN('${selection.length}')),
    ));
  }

  void _bulkFollow(BuildContext context, WidgetRef ref, Set<String> selection) {
    final eligible = selection.where((id) =>!isMahakoshKundliId(id)).toSet();
    if (eligible.isEmpty) return;
    final follows = ref.read(followedKundlisProvider.notifier);
    final allFollowed = eligible.every(follows.isFollowed);
    if (allFollowed) {
      follows.removeAll(eligible);
    } else {
      follows.addAll(eligible);
      unawaited(ref.read(kundliAlertServiceProvider).ensurePermission());
    }
    ref.read(kundliMultiSelectProvider.notifier).state = null;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(allFollowed
         ? context.l10n.klAlertsOffN('${eligible.length}')
          : context.l10n.klAlertsOnN('${eligible.length}')),
    ));
  }

  Future<void> _bulkLabel(
      BuildContext context, WidgetRef ref, Set<String> selection) async {
    final all = ref.read(kundliListDataProvider).value;
    if (all == null) return;
    final label = await showLabelPicker(context, existing: all.labels);
    if (label == null || label.isEmpty) return;

    final repo = ref.read(kundliRepoProvider);
    for (final id in selection) {
      final k = await repo.byId(id);
      if (k == null || k.labels.contains(label)) continue;
      await repo.update(k.copyWith(labels: [...k.labels, label]));
    }
    ref.invalidate(kundlisProvider);
    ref.read(kundliMultiSelectProvider.notifier).state = null;
  }

  bool _selectionArchived(WidgetRef ref, Set<String> selection) {
    if (selection.isEmpty) return false;
    final all = ref.watch(kundlisProvider).value?? const <Kundli>[];
    final byId = {for (final k in all) k.id: k};
    return selection.every((id) => byId[id]?.isArchived?? false);
  }

  Future<void> _bulkArchive(
    BuildContext context,
    WidgetRef ref,
    Set<String> selection, {
    required bool archived,
  }) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final container = ProviderScope.containerOf(context, listen: false);
    final ids = {...selection};
    ref.read(kundliMultiSelectProvider.notifier).state = null;
    await setKundlisArchived(container, ids, archived: archived);
    messenger.showSnackBar(SnackBar(
      content: Text(archived
         ? l10n.klArchivedN('${ids.length}')
          : l10n.klUnarchivedN('${ids.length}')),
      action: SnackBarAction(
        label: l10n.klUndo,
        onPressed: () =>
            setKundlisArchived(container, ids, archived:!archived),
      ),
    ));
  }

  Future<void> _bulkDelete(
      BuildContext context, WidgetRef ref, Set<String> selection) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.klDeleteNTitle('${selection.length}')),
        content: Text(l10n.klDeleteNBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ctx.l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text(ctx.l10n.delete, style: TextStyle(color: KJColors.maroon)),
          ),
        ],
      ),
    );
    if (confirmed!= true) return;

    final repo = ref.read(kundliRepoProvider);
    final sync = ref.read(syncServiceProvider);
    for (final id in selection) {
      await repo.delete(id);
      sync?.deleteRemote(id);
    }
    ref.read(devicePingServiceProvider)?.pingSoon();
    ref.read(pinnedKundlisProvider.notifier).removeAll(selection);
    ref.read(followedKundlisProvider.notifier).removeAll(selection);
    ref.read(recentKundlisProvider.notifier).forget(selection);
    ref.invalidate(kundlisProvider);
    ref.read(kundliMultiSelectProvider.notifier).state = null;
  }

  Future<void> _castPrashna(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(
      content: Text(l10n.klCastingPrashna),
      duration: const Duration(seconds: 10),
    ));
    try {
      final place = await LocationService().currentPlace();
      final now = DateTime.now();
      final kundli = await ref.read(kundliRepoProvider).create(
            name: l10n.klPrashnaName(
                DateFormat('d MMM, HH:mm', l10n.localeName).format(now)),
            relationTag: 'Prashna',
            birthUtc: now.toUtc(),
            latitude: place.latitude,
            longitude: place.longitude,
            timezoneName: place.timezoneName,
            utcOffsetMinutes: now.timeZoneOffset.inMinutes,
            placeName: place.displayName,
            isPrashna: true,
            isEphemeral: true,
          );
      messenger.hideCurrentSnackBar();
      ref.invalidate(kundlisProvider);
      if (context.mounted) context.push('/kundli/${kundli.id}');
    } on LocationDenied catch (denied) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(
        content: Text(denied.permanently
           ? l10n.klLocationDisabled
            : l10n.klLocationUnavailable),
      ));
      if (context.mounted) context.push('/new?prashna=1');
    } catch (_) {
      messenger.hideCurrentSnackBar();
      if (context.mounted) context.push('/new?prashna=1');
    }
  }
}

class _Library extends ConsumerWidget {
  const _Library({required this.data, required this.showSignIn});

  final KundliListData data;
  final bool showSignIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final density = ref.watch(kundliDensityProvider);
    final sort = ref.watch(kundliSortProvider);
    final query = ref.watch(kundliSearchProvider);
    final filter = ref.watch(kundliFilterProvider);
    final searching = query.trim().isNotEmpty || filter!= null;

    final showSearch = data.totalCount >= _searchThreshold;
    final showRecents = data.totalCount >= _recentsThreshold &&
       !searching &&
        data.recents.isNotEmpty;
    final grouped = sort == KundliSort.name &&
        data.others.length >= _sectionHeaderThreshold;

    return CustomScrollView(
      slivers: [
        if (showSearch) const SliverToBoxAdapter(child: _SearchField()),
        if (data.labels.isNotEmpty ||
            data.relationTags.length > 1 ||
            data.archivedCount > 0)
          SliverToBoxAdapter(child: _FilterChips(data: data)),
        if (showRecents)
          SliverToBoxAdapter(child: _RecentsStrip(recents: data.recents)),
        if (showSignIn) SliverToBoxAdapter(child: _signInBanner(context)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                KJSpace.lg, KJSpace.xs, KJSpace.lg, KJSpace.md),
            child: Text(
              searching
                 ? l10n.klShowingCount(
                      '${data.visibleCount}', '${data.totalCount}')
                  : l10n.savedEncrypted(data.totalCount),
              style: KJType.meta(size: 11.5, color: KJColors.inkSoft),
            ),
          ),
        ),
        if (data.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              message: l10n.klNoMatches,
              actionLabel: l10n.klClearFilters,
              onAction: () {
                ref.read(kundliSearchProvider.notifier).state = '';
                ref.read(kundliFilterProvider.notifier).state = null;
              },
            ),
          ),
        if (data.pinned.isNotEmpty)...[
          SliverToBoxAdapter(child: _SectionLabel(label: l10n.klPinned)),
          SliverList.builder(
            itemCount: data.pinned.length,
            itemBuilder: (_, i) =>
                _KundliRow(kundli: data.pinned[i], density: density),
          ),
          if (data.others.isNotEmpty)
            SliverToBoxAdapter(child: _SectionLabel(label: l10n.klAllKundlis)),
        ],
        if (grouped)
         ..._groupedSlivers(data.others, density)
        else
          SliverList.builder(
            itemCount: data.others.length,
            itemBuilder: (_, i) =>
                _KundliRow(kundli: data.others[i], density: density),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, KJSpace.md, 0, 96),
            child: Center(
              child: Text(l10n.klLongPressPrashna,
                  style: KJType.meta(size: 10.5, color: KJColors.inkSoft)),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _groupedSlivers(List<Kundli> kundlis, KundliDensity density) {
    final groups = <String, List<Kundli>>{};
    for (final k in kundlis) {
      groups.putIfAbsent(initialFor(k.name), () => []).add(k);
    }
    return [
      for (final entry in groups.entries)
        SliverMainAxisGroup(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _LetterHeaderDelegate(entry.key),
            ),
            SliverList.builder(
              itemCount: entry.value.length,
              itemBuilder: (_, i) =>
                  _KundliRow(kundli: entry.value[i], density: density),
            ),
          ],
        ),
    ];
  }

  Widget _signInBanner(BuildContext context) => Card(
        margin:
            const EdgeInsets.fromLTRB(KJSpace.lg, 0, KJSpace.lg, KJSpace.md),
        child: Padding(
          padding: const EdgeInsets.all(KJSpace.md + 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.signInBanner,
                  style: KJType.body(size: 13),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/signin'),
                child: Text(context.l10n.signIn),
              ),
            ],
          ),
        ),
      );
}

String initialFor(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '#';
  final first = trimmed[0].toUpperCase();
  return RegExp(r'[A-Z]').hasMatch(first)? first : '#';
}

class _LetterHeaderDelegate extends SliverPersistentHeaderDelegate {
  _LetterHeaderDelegate(this.letter);
  final String letter;

  static const _height = 30.0;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) =>
      Container(
        height: _height,
        color: KJColors.paper,
        padding: const EdgeInsets.symmetric(horizontal: KJSpace.lg),
        alignment: Alignment.centerLeft,
        child: KJSectionLabel(letter),
      );

  @override
  bool shouldRebuild(_LetterHeaderDelegate old) => old.letter!= letter;
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
            KJSpace.lg, KJSpace.xs, KJSpace.lg, KJSpace.sm),
        child: KJSectionLabel(label),
      );
}

class _SearchField extends ConsumerStatefulWidget {
  const _SearchField();

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final TextEditingController _controller =
      TextEditingController(text: ref.read(kundliSearchProvider));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(kundliSearchProvider, (_, next) {
      if (next!= _controller.text) _controller.text = next;
    });
    final query = ref.watch(kundliSearchProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          KJSpace.lg, KJSpace.sm, KJSpace.lg, KJSpace.xs),
      child: TextField(
        controller: _controller,
        onChanged: (v) => ref.read(kundliSearchProvider.notifier).state = v,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: context.l10n.klSearchHint,
          isDense: true,
          prefixIcon:
              Icon(Icons.search, size: KJIcon.lg, color: KJColors.inkSoft),
          suffixIcon: query.isEmpty
             ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: KJIcon.md),
                  tooltip: context.l10n.klClearSearch,
                  onPressed: () {
                    _controller.clear();
                    ref.read(kundliSearchProvider.notifier).state = '';
                  },
                ),
        ),
      ),
    );
  }
}

class _FilterChips extends ConsumerWidget {
  const _FilterChips({required this.data});
  final KundliListData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final active = ref.watch(kundliFilterProvider);

    void select(KundliFilter? filter) =>
        ref.read(kundliFilterProvider.notifier).state = filter;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: KJSpace.lg),
        children: [
          _chip(
            label: l10n.klFilterAll,
            selected: active == null,
            onTap: () => select(null),
          ),
          for (final tag in data.relationTags)
            _chip(
              label: relationTagLabel(l10n, tag),
              selected: active?.kind == KundliFilterKind.relation &&
                  active?.value == tag,
              onTap: () =>
                  select((kind: KundliFilterKind.relation, value: tag)),
            ),
          for (final label in data.labels)
            _chip(
              label: label,
              selected: active?.kind == KundliFilterKind.label &&
                  active?.value == label,
              onTap: () => select((kind: KundliFilterKind.label, value: label)),
              icon: Icons.sell_outlined,
            ),
          if (data.archivedCount > 0)
            _chip(
              label: l10n.klArchived('${data.archivedCount}'),
              selected: active?.kind == KundliFilterKind.archived,
              onTap: () => select(active?.kind == KundliFilterKind.archived
                 ? null
                  : kArchivedFilter),
              icon: Icons.archive_outlined,
            ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) =>
      Padding(
        padding: const EdgeInsets.only(right: KJSpace.sm),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: KJSpace.md, vertical: KJSpace.sm),
            decoration: BoxDecoration(
              color: selected
                 ? KJColors.maroon.withValues(alpha: KJTint.soft)
                  : KJColors.paperAlt,
              borderRadius: KJRadius.all(KJRadius.pill),
              border: Border.all(
                  color: selected
                     ? KJColors.maroon.withValues(alpha: KJTint.muted)
                      : KJColors.hairline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon!= null)...[
                  Icon(icon,
                      size: KJIcon.inline,
                      color: selected? KJColors.maroon : KJColors.inkSoft),
                  KJSpace.gapW(KJSpace.xs),
                ],
                Text(
                  label,
                  style: KJType.chip(
                      size: 12,
                      color: selected? KJColors.maroon : KJColors.inkSoft),
                ),
              ],
            ),
          ),
        ),
      );
}

class _RecentsStrip extends ConsumerWidget {
  const _RecentsStrip({required this.recents});
  final List<Kundli> recents;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shown = recents.take(_recentsShown).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              KJSpace.lg, KJSpace.sm, KJSpace.lg, KJSpace.sm),
          child: KJSectionLabel(context.l10n.klRecent),
        ),
        SizedBox(
          height: 78,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: KJSpace.lg),
            itemCount: shown.length,
            itemBuilder: (_, i) {
              final k = shown[i];
              return GestureDetector(
                onTap: () => openKundli(context, ref, k.id),
                child: SizedBox(
                  width: 64,
                  child: Column(
                    children: [
                      KundliAvatar(name: k.name, size: 44),
                      KJSpace.gap(KJSpace.xs + 2),
                      Text(
                        k.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style:
                            KJType.caption(size: 11, color: KJColors.inkSoft),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ListOptionsButton extends ConsumerWidget {
  const _ListOptionsButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final sort = ref.watch(kundliSortProvider);
    final density = ref.watch(kundliDensityProvider);

    return PopupMenuButton<void Function()>(
      icon: const Icon(Icons.sort),
      tooltip: l10n.klListOptions,
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        PopupMenuItem(enabled: false, child: KJSectionLabel(l10n.klSortLabel)),
        for (final option in KundliSort.values)
          CheckedPopupMenuItem(
            value: () => ref.read(kundliSortProvider.notifier).select(option),
            checked: sort == option,
            child: Text(sortLabel(l10n, option)),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
            enabled: false, child: KJSectionLabel(l10n.klDensityLabel)),
        for (final option in KundliDensity.values)
          CheckedPopupMenuItem(
            value: () =>
                ref.read(kundliDensityProvider.notifier).select(option),
            checked: density == option,
            child: Text(densityLabel(l10n, option)),
          ),
      ],
    );
  }
}

String sortLabel(AppLocalizations l10n, KundliSort sort) => switch (sort) {
      KundliSort.recent => l10n.klSortRecent,
      KundliSort.added => l10n.klSortAdded,
      KundliSort.name => l10n.klSortName,
      KundliSort.birth => l10n.klSortBirth,
    };

String densityLabel(AppLocalizations l10n, KundliDensity density) =>
    switch (density) {
      KundliDensity.compact => l10n.klDensityCompact,
      KundliDensity.comfortable => l10n.klDensityComfortable,
      KundliDensity.detailed => l10n.klDensityDetailed,
    };

Future<void> setKundlisArchived(
  ProviderContainer container,
  Iterable<String> ids, {
  required bool archived,
}) async {
  final repo = container.read(kundliRepoProvider);
  final changed = <String>[];
  for (final id in ids) {
    final k = await repo.byId(id);
    if (k == null || k.isArchived == archived) continue;
    await repo.update(k.copyWith(isArchived: archived));
    changed.add(id);
  }
  if (changed.isEmpty) return;
  if (archived) {
    container.read(pinnedKundlisProvider.notifier).removeAll(changed);
    container.read(recentKundlisProvider.notifier).forget(changed);
  }
  container.invalidate(kundlisProvider);
  for (final id in changed) {
    container.invalidate(kundliByIdProvider(id));
  }
  container.read(syncServiceProvider)?.pushAll();
}

void openKundli(BuildContext context, WidgetRef ref, String id) {
  ref.read(activeKundliIdProvider.notifier).state = id;
  ref.read(recentKundlisProvider.notifier).touch(id);
  context.push('/kundli/$id');
}

class KundliAvatar extends StatelessWidget {
  const KundliAvatar({super.key, required this.name, this.size = 40});

  final String name;
  final double size;

  static List<Color> _palette() => [
        KJColors.maroon,
        KJColors.forest,
        KJColors.transit,
        KJColors.ink,
      ];

  @override
  Widget build(BuildContext context) {
    final palette = _palette();
    final seed = name.codeUnits.fold<int>(0, (a, b) => a + b);
    final color = palette[seed % palette.length];
    final letter = initialFor(name);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: KJTint.soft),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: KJTint.medium)),
      ),
      child: Text(
        letter,
        style: KJTheme.serif(size: size * 0.4, color: color),
      ),
    );
  }
}

class _KundliRow extends ConsumerWidget {
  const _KundliRow({required this.kundli, required this.density});

  final Kundli kundli;
  final KundliDensity density;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selection = ref.watch(kundliMultiSelectProvider);
    final selecting = selection!= null;
    final isSelected = selection?.contains(kundli.id)?? false;
    final isPinned = ref.watch(pinnedKundlisProvider).contains(kundli.id);
    final isFollowed = ref.watch(followedKundlisProvider).contains(kundli.id);
    final compact = density == KundliDensity.compact;

    void toggleSelection() {
      final current = {...?ref.read(kundliMultiSelectProvider)};
      if (!current.remove(kundli.id)) current.add(kundli.id);
      ref.read(kundliMultiSelectProvider.notifier).state = current;
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(KJSpace.lg, 0, KJSpace.lg, KJSpace.sm),
      color:
          isSelected? KJColors.maroon.withValues(alpha: KJTint.faint) : null,
      child: InkWell(
        borderRadius: KJRadius.all(KJRadius.lg),
        onLongPress: () =>
            ref.read(kundliMultiSelectProvider.notifier).state = {kundli.id},
        onTap: selecting
           ? toggleSelection
            : () => openKundli(context, ref, kundli.id),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: KJSpace.md,
              vertical: compact? KJSpace.sm : KJSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (selecting)
                    Padding(
                      padding: const EdgeInsets.only(right: KJSpace.sm),
                      child: Icon(
                        isSelected
                           ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: KJIcon.lg,
                        color: isSelected? KJColors.maroon : KJColors.inkSoft,
                      ),
                    ),
                  KundliAvatar(name: kundli.name, size: compact? 32 : 40),
                  KJSpace.gapW(KJSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          kundli.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: KJTheme.serif(size: compact? 15 : 17),
                        ),
                        if (!compact)...[
                          const SizedBox(height: 2),
                          Text(
                            _secondaryLine(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                KJType.data(size: 12, color: KJColors.inkSoft),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isFollowed)
                    Padding(
                      padding: const EdgeInsets.only(left: KJSpace.xs),
                      child: Tooltip(
                        message: l10n.klFollowingAlerts,
                        child: Icon(Icons.notifications_active,
                            size: KJIcon.sm - 2, color: KJColors.maroon),
                      ),
                    ),
                  if (isPinned)
                    Padding(
                      padding: const EdgeInsets.only(left: KJSpace.xs),
                      child: Icon(Icons.push_pin,
                          size: KJIcon.sm - 2, color: KJColors.maroon),
                    ),
                  KJSpace.gapW(KJSpace.sm),
                  KJTag(relationTagLabel(l10n, kundli.relationTag)),
                  KJSpace.gapW(KJSpace.sm),
                  Tooltip(
                    message: kundli.syncEnabled? l10n.synced : l10n.deviceOnly,
                    child: Icon(
                      kundli.syncEnabled
                         ? Icons.cloud_done_outlined
                          : Icons.cloud_off_outlined,
                      size: KJIcon.sm,
                      color: kundli.syncEnabled
                         ? KJColors.inkSoft
                          : KJColors.inkSoft.withValues(alpha: KJTint.dim),
                    ),
                  ),
                ],
              ),
              if (density == KundliDensity.detailed)..._detail(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  String _secondaryLine() {
    final note = kundli.note?.trim();
    if (note!= null && note.isNotEmpty) return note;
    return KJDate.dateDotTime(kundli.toBirthData().localDateTime);
  }

  List<Widget> _detail(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final note = kundli.note?.trim();
    final snapshot = ref.watch(snapshotProvider(kundli.id));

    return [
      if (note!= null && note.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: KJSpace.xs),
          child: Text(
            KJDate.dateDotTime(kundli.toBirthData().localDateTime),
            style: KJType.data(size: 12, color: KJColors.inkSoft),
          ),
        ),
      KJSpace.gap(KJSpace.sm),
      Wrap(
        spacing: KJSpace.sm,
        runSpacing: KJSpace.xs + 2,
        children: [
          snapshot.when(
            data: (s) => KJTag('${l10n.labelLagna} ${s.lagnaSign.label(l10n)}',
                maroon: true),
            loading: () => KJTag('${l10n.labelLagna} …'),
            error: (_, __) => KJTag('${l10n.labelLagna}?'),
          ),
          snapshot.when(
            data: (s) => KJTag('${l10n.planetMoon} ${s.moonSign.label(l10n)}'),
            loading: () => KJTag('${l10n.planetMoon} …'),
            error: (_, __) => KJTag('${l10n.planetMoon}?'),
          ),
          for (final label in kundli.labels) KJTag(label),
          if (kundli.isPrashna) KJTag(l10n.tagPrashna),
          if (kundli.isSharedToMahakosh)
            KJTag(l10n.klMahakoshTag(kundli.mahakoshCode!)),
        ],
      ),
    ];
  }
}

Future<String?> showLabelPicker(BuildContext context,
    {required List<String> existing}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      final l10n = ctx.l10n;
      return AlertDialog(
        title: Text(l10n.klAddLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(hintText: l10n.klLabelHint),
              onSubmitted: (v) =>
                  Navigator.pop(ctx, v.trim().isEmpty? null : v.trim()),
            ),
            if (existing.isNotEmpty)...[
              KJSpace.gap(KJSpace.lg),
              KJSectionLabel(l10n.klExistingLabels, padded: true),
              Wrap(
                spacing: KJSpace.sm,
                runSpacing: KJSpace.sm,
                children: [
                  for (final label in existing)
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx, label),
                      child: KJTag(label),
                    ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              final v = controller.text.trim();
              Navigator.pop(ctx, v.isEmpty? null : v);
            },
            child: Text(l10n.add),
          ),
        ],
      );
    },
  );
}