import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/env.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/notifications/notifications_cubit.dart';
import '../../../../core/support/support_request_type.dart';

/// Wraps the admin shell (`AdminHubPage`) to raise a live, in-app-only
/// notification (`NotificationsCubit.notifyNewSupportRequest`) the
/// instant a seller submits a new Support & Feedback request — via
/// Supabase Realtime (`supabase/migrations/0016_support_requests_realtime.sql`),
/// not a scheduled OS alarm like every other notification type in this
/// app. Deliberate scope, chosen over a real push-notification setup
/// (would need Firebase Cloud Messaging + a Supabase Edge Function):
/// this only fires while an admin's app is actually open and this
/// widget is mounted — nothing arrives if the app is closed. Subscribed
/// for the lifetime of the admin session (`AdminHubPage` stays mounted
/// underneath whatever admin sub-page gets pushed on top of it, so this
/// keeps listening across the whole session, torn down only on logout).
class SupportRequestRealtimeGate extends StatefulWidget {
  final Widget child;

  const SupportRequestRealtimeGate({super.key, required this.child});

  @override
  State<SupportRequestRealtimeGate> createState() => _SupportRequestRealtimeGateState();
}

class _SupportRequestRealtimeGateState extends State<SupportRequestRealtimeGate> {
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    if (!Env.isConfigured) return;
    _channel = Supabase.instance.client
        .channel('admin-support-requests')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'support_requests',
          callback: (payload) {
            final typeValue = payload.newRecord['type'] as String?;
            final label = supportRequestTypeFromRow(typeValue ?? '').label;
            getIt<NotificationsCubit>().notifyNewSupportRequest(requestTypeLabel: label);
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    final channel = _channel;
    if (channel != null) {
      Supabase.instance.client.removeChannel(channel);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
