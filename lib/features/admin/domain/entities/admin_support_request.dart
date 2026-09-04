import 'package:equatable/equatable.dart';

import '../../../support_feedback/domain/entities/support_request.dart';

/// A `support_requests` row as seen by Admin → Support & Feedback —
/// same shape as the seller-facing `SupportRequest`, plus who sent it
/// (`senderName`/`senderEmail`, joined in from `profiles`, both readable
/// by an admin per `supabase/migrations/0004_admin_reads_support_requests.sql`).
class AdminSupportRequest extends Equatable {
  final String id;
  final SupportRequestType type;
  final String message;
  final String? attachmentUrl;
  final String? voiceNoteUrl;
  final DateTime createdAt;
  final String senderId;
  final String senderName;
  final String senderEmail;

  const AdminSupportRequest({
    required this.id,
    required this.type,
    required this.message,
    this.attachmentUrl,
    this.voiceNoteUrl,
    required this.createdAt,
    required this.senderId,
    required this.senderName,
    required this.senderEmail,
  });

  @override
  List<Object?> get props =>
      [id, type, message, attachmentUrl, voiceNoteUrl, createdAt, senderId, senderName, senderEmail];
}
