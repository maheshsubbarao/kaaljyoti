import 'package:supabase_flutter/supabase_flutter.dart';

// --- MODELS ---
class ResearchRequest {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  ResearchRequest({required this.id, required this.title, required this.description, required this.createdAt});
  factory ResearchRequest.fromMap(Map<String, dynamic> m) {
    return ResearchRequest(
      id: m['id']?.toString() ?? '',
      title: m['title']?.toString() ?? 'Untitled',
      description: m['description']?.toString() ?? '',
      createdAt: DateTime.tryParse(m['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class AdminChartReport {
  final String id;
  final String mkCode;
  final String reasonLabel;
  final String details;
  final DateTime createdAt;
  AdminChartReport({required this.id, required this.mkCode, required this.reasonLabel, required this.details, required this.createdAt});
  factory AdminChartReport.fromMap(Map<String, dynamic> m) {
    return AdminChartReport(
      id: m['id']?.toString() ?? '',
      mkCode: m['mk_code']?.toString() ?? m['mahakosh_code']?.toString() ?? '',
      reasonLabel: m['reason']?.toString() ?? m['reason_label']?.toString() ?? 'Report',
      details: m['details']?.toString() ?? '',
      createdAt: DateTime.tryParse(m['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class AdminCommentReport {
  final String id;
  final String mkCode;
  final String reasonLabel;
  final String bodySnapshot;
  final String details;
  final DateTime createdAt;
  AdminCommentReport({required this.id, required this.mkCode, required this.reasonLabel, required this.bodySnapshot, required this.details, required this.createdAt});
  factory AdminCommentReport.fromMap(Map<String, dynamic> m) {
    return AdminCommentReport(
      id: m['id']?.toString() ?? '',
      mkCode: m['mk_code']?.toString() ?? '',
      reasonLabel: m['reason']?.toString() ?? m['reason_label']?.toString() ?? 'Report',
      bodySnapshot: m['body_snapshot']?.toString() ?? m['body']?.toString() ?? '',
      details: m['details']?.toString() ?? '',
      createdAt: DateTime.tryParse(m['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class AppStats {
  const AppStats({
    required this.devicesTotal,
    required this.devicesActive30d,
    required this.kundlisCreatedTotal,
    required this.kundlisCurrent,
    required this.kundlisCurrentActive30d,
    required this.syncedCreatedTotal,
    required this.syncedCurrent,
  });
  final int devicesTotal;
  final int devicesActive30d;
  final int kundlisCreatedTotal;
  final int kundlisCurrent;
  final int kundlisCurrentActive30d;
  final int syncedCreatedTotal;
  final int syncedCurrent;
  
  factory AppStats.fromMap(Map<String, dynamic> m) {
    return AppStats(
      devicesTotal: (m['devices_total'] as num?)?.toInt() ?? 0,
      devicesActive30d: (m['devices_active_30d'] as num?)?.toInt() ?? 0,
      kundlisCreatedTotal: (m['kundlis_created_total'] as num?)?.toInt() ?? 0,
      kundlisCurrent: (m['kundlis_current'] as num?)?.toInt() ?? 0,
      kundlisCurrentActive30d: (m['kundlis_current_active_30d'] as num?)?.toInt() ?? 0,
      syncedCreatedTotal: (m['synced_created_total'] as num?)?.toInt() ?? 0,
      syncedCurrent: (m['synced_current'] as num?)?.toInt() ?? 0,
    );
  }
}

// --- REPOSITORY ---
class AdminRepository {
  AdminRepository(this._client);
  final SupabaseClient _client;

  Future<bool> isAdmin() async {
    if (_client.auth.currentUser == null) return false;
    try {
      final result = await _client.rpc('is_admin');
      return result as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<List<ResearchRequest>> pendingRequests() async {
    try {
      final rows = await _client.from('research_requests').select().eq('status', 'pending_review').order('created_at');
      return (rows as List).map((e) => ResearchRequest.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<AdminChartReport>> pendingChartReports() async {
    try {
      final rows = await _client.from('chart_reports').select().eq('status', 'pending').order('created_at');
      return (rows as List).map((e) => AdminChartReport.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<AdminCommentReport>> pendingCommentReports() async {
    try {
      final rows = await _client.from('comment_reports').select().eq('status', 'pending').order('created_at');
      return (rows as List).map((e) => AdminCommentReport.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<AppStats?> appStats() async {
    try {
      final result = await _client.rpc('app_stats');
      if (result is Map<String, dynamic>) return AppStats.fromMap(result);
      if (result is List && result.isNotEmpty) return AppStats.fromMap(result.first as Map<String, dynamic>);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> moderateRequest({required String requestId, required bool approve, String? note}) async {
    await _client.functions.invoke('moderate-request', body: {
      'request_id': requestId,
      'action': approve ? 'approve' : 'reject',
      if (note != null && note.isNotEmpty) 'note': note,
    });
  }

  Future<void> moderateChartReport({required String reportId, required bool action, String? note}) async {
    await _client.functions.invoke('moderate-chart-report', body: {
      'report_id': reportId,
      'action': action ? 'withdraw' : 'dismiss',
      if (note != null && note.isNotEmpty) 'note': note,
    });
  }

  // THIS WAS MISSING - NOW FIXED!
  Future<void> moderateCommentReport({required String reportId, required bool remove, String? note}) async {
    await _client.functions.invoke('moderate-comment-report', body: {
      'report_id': reportId,
      'remove': remove,
      if (note != null && note.isNotEmpty) 'note': note,
    });
  }
}
