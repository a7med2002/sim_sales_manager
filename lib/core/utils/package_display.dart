/// "name — simType" wherever a package is shown, or just [name] when
/// [simType] is empty/unset (packages saved before this field existed —
/// it's required going forward, but nullable at the data layer since it
/// can't be backfilled for old rows).
String packageDisplayLabel(String name, String? simType) {
  final trimmed = simType?.trim();
  return (trimmed == null || trimmed.isEmpty) ? name : '$name — $trimmed';
}
