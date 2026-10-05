import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<List<Map<String, dynamic>>> pendingRequests() async {
    final rows = await _client
        .from('research_requests')
        .select()
        .eq('status', 'pending_review')
        .order('created_at');
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<void> moderateRequest({
    required String requestId,
    required bool approve,
    String? note,
  }) async {
    await _client.functions.invoke('moderate-request', body: {
      'request_id': requestId,
      'action': approve ? 'approve' : 'reject',
      if (note != null && note.isNotEmpty) 'note': note,
    });
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
}