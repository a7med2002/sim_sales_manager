/// What a notification is about — drives its icon/tap-target in the
/// inbox and, for a couple of types, whether a later event should
/// cancel it before it ever fires (see `NotificationsCubit`).
enum NotificationType {
  /// A line's `expiryDate` is 3 days away. [relatedEntityId] is the
  /// Line's id.
  lineExpiringSoon,

  /// A line's `expiryDate` is today. [relatedEntityId] is the Line's id.
  lineExpired,

  /// A seller-set "remind me" for a customer's outstanding balance.
  /// [relatedEntityId] is the Customer's id — cancelled automatically if
  /// the customer's total owed reaches zero before it fires.
  customerDebtReminder,

  /// A company's `availableToSell` dropped to zero or below.
  /// [relatedEntityId] is the Company's id.
  companyLowBalance,

  /// A shipment was recorded with an unpaid remainder — what's owed to
  /// that supplier. [relatedEntityId] is the Company's id.
  companyOwedAlert,

  /// Admin-only: a seller submitted a new Support & Feedback request.
  /// Raised live via `SupportRequestRealtimeGate`'s Supabase Realtime
  /// subscription, not scheduled ahead of time like every other type
  /// here — see its doc comment for why this only works while the admin
  /// app is open. [relatedEntityId] is unused (there's no per-request
  /// detail route to jump to yet, just the Support & Feedback list).
  newSupportRequest,
}

String notificationTypeToRow(NotificationType type) => type.name;

NotificationType? notificationTypeFromRow(String value) {
  for (final type in NotificationType.values) {
    if (type.name == value) return type;
  }
  return null;
}
