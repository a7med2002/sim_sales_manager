import 'dart:math';

final _random = Random.secure();

/// A random UUID v4, generated client-side. Needed because every
/// tenant-scoped row is created locally first (offline-first — see
/// CLAUDE.md) and only pushed to Supabase later; the id has to already
/// be a valid `uuid` value by then since that's the Postgres column
/// type, so a plain counter/timestamp id wouldn't do.
String generateUuidV4() {
  final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 10

  String hex(int start, int end) => bytes.sublist(start, end).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
