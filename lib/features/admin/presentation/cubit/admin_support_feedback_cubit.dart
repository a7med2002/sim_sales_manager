import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/support/support_request_type.dart';
import '../../domain/entities/admin_support_request.dart';

class AdminSupportFeedbackState extends Equatable {
  final List<AdminSupportRequest> requests;
  final bool isLoading;
  final String? errorMessage;

  const AdminSupportFeedbackState({this.requests = const [], this.isLoading = true, this.errorMessage});

  AdminSupportFeedbackState copyWith({List<AdminSupportRequest>? requests, bool? isLoading, String? errorMessage}) {
    return AdminSupportFeedbackState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [requests, isLoading, errorMessage];
}

/// Admin → Support & Feedback: every seller's submitted request, newest
/// first, with who sent it. Reads `support_requests` directly via
/// Supabase (no Drift — same reasoning as the other admin cubits: this
/// isn't a seller's own offline-first data), made possible by
/// `supabase/migrations/0004_admin_reads_support_requests.sql` (the
/// table's original RLS was owner-only with no admin override). Sender
/// name/email come from a second query against `profiles` (already
/// admin-readable), joined here client-side by `owner_id` rather than a
/// Postgres join — simpler than writing a view for two small tables.
class AdminSupportFeedbackCubit extends Cubit<AdminSupportFeedbackState> {
  final SupabaseClient _client;

  AdminSupportFeedbackCubit({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client,
      super(const AdminSupportFeedbackState()) {
    load();
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final requestRows = await _client.from('support_requests').select();
      final profileRows = await _client.from('profiles').select('id, display_name, email');
      final profilesById = {for (final p in profileRows) p['id'] as String: p};

      final requests = requestRows.map((row) {
        final ownerId = row['owner_id'] as String;
        final profile = profilesById[ownerId];
        return AdminSupportRequest(
          id: row['id'] as String,
          type: supportRequestTypeFromRow(row['type'] as String),
          message: row['body'] as String,
          attachmentUrl: row['attachment_url'] as String?,
          voiceNoteUrl: row['voice_note_url'] as String?,
          createdAt: DateTime.parse(row['created_at'] as String),
          senderId: ownerId,
          senderName: (profile?['display_name'] as String?) ?? '',
          senderEmail: (profile?['email'] as String?) ?? '',
        );
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(state.copyWith(requests: requests, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  /// A short-lived signed URL for a private `support-attachments` object
  /// path (the bucket has no public read access) — used to render a
  /// photo inline (`Image.network`) or stream a voice note inline (an
  /// `AudioPlayer` playing straight from the URL) in
  /// `AdminSupportRequestDetailSheet`. Returns null on failure (the
  /// bucket/object might not exist, or the network could be down).
  Future<String?> signedAttachmentUrl(String objectPath) async {
    try {
      return await _client.storage.from('support-attachments').createSignedUrl(objectPath, 60 * 10);
    } catch (_) {
      return null;
    }
  }
}
