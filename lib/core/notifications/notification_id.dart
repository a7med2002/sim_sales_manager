/// `flutter_local_notifications` schedules/cancels by a plain 32-bit
/// int id, not a string — this derives a stable one from our own
/// string row id (a uuid) so a later cancel can recompute the same int
/// without needing a separate lookup table. `& 0x7fffffff` keeps it a
/// positive 32-bit value (Android's notification id is a Java `int`).
int notificationOsId(String rowId) => rowId.hashCode & 0x7fffffff;
